#!/usr/bin/env python3
"""Repaint kitty, tmux, sketchybar and borders from a single kitty theme.

    python3 theme/apply.py Catppuccin-Mocha
    python3 theme/apply.py --list

Themes come from kitty's own catalogue, so the values are upstream rather than
eyeballed. kitty caches that catalogue after the first `kitty +kitten themes`
run; this reads the cache directly.

How it works: theme/current.json records which hex value is currently playing
which role (background, accent, alert and so on). Every colour in the four
configs is one of those roles, so repainting is a role-by-role substitution
rather than a rewrite. That keeps hand edits to the configs intact.
"""

import colorsys
import json
import pathlib
import re
import sys
import zipfile

# Fully opaque. Blur stays off regardless: it samples a wide radius, so bright
# patches in the wallpaper smear across the whole window, and that smear was
# what read as fog. Drop this below 1.0 to let the desktop back through; the
# text lift below exists to pay for the contrast that costs.
OPACITY = 0.9
LIFT = 0.0
# Ceiling on how light text may get, once LIFT is non-zero. Past about 0.96
# every theme's text lands on the same near-white and they stop being
# distinguishable from each other.
TEXT_CAP = 0.96

# Minimum contrast between text and background. Anything below roughly 14:1
# reads as haze on a non-retina panel, which is what made every mid-dark theme
# look foggy no matter how opaque the window was. Purple-Custom, the one that
# always looked crisp, measures 15.79:1, so that is the bar. Set to 0 to leave
# themes exactly as shipped.
CONTRAST_FLOOR = 15.8
# Minimum contrast for the syntax colours. This matters more than the plain
# foreground floor above, because in code almost everything you read is syntax
# coloured. Kanagawa is deliberately muted and averages 5.57:1, roughly half of
# Purple-Custom's 7.06 and 1984_dark's 10.12, which is why it still read as
# hazy once the background alone had been solved.
SYNTAX_FLOOR = 0.0

# Which palette slot carries the window borders, the bar outline and the clock.
# None derives it: normally the theme's yellow, stepping to blue when the accent
# has already claimed yellow. Name a slot ("color4", "color6") to override when
# the derived one is wrong for a particular theme.
BORDER_SLOT = "color1"

# Target perceptual luma for the background, or None to leave it as shipped.
#
# This turned out to be the variable that actually decides whether a theme reads
# as crisp here, more than any contrast ratio. Purple-Custom sits at 2.5 and
# always looked right; the themes that read as foggy were at 15 to 52, and
# raising their foregrounds never fixed it because the background was the thing
# that mattered. Hue and saturation are held, so a theme keeps its tint.
BG_LUMA = 0.0

# Minimum contrast for dimmed text against the surface it sits on: inactive tmux
# window tabs, inactive kitty tabs, the swap icon in the bar.
#
# Off, because raising it costs more than it buys. At 5.0 the dimmed text stops
# being dim: it lands close enough to the plain text that the two stop
# separating, and the screen fills with mid-grey, which reads as fog. Dimness is
# doing real work here even when the raw ratio looks alarming. Try 3.0 for a
# middle ground rather than going back to 5.0.
MUTED_FLOOR = 0.0
# How light the text may be pushed while solving for it. The text is moved
# first, since it has more headroom than the background has room to darken.
FG_CEILING = 0.93

ROOT = pathlib.Path(__file__).resolve().parent.parent
STATE = ROOT / "theme" / "current.json"
CACHE = pathlib.Path.home() / "Library/Caches/kitty/kitty-themes.zip"

# Every file that carries a colour. Order does not matter.
TARGETS = [
    "sketchybar/sketchybarrc",
    "tmux/tmux.conf",
    "tmux/scripts/pr-status.sh",
    "tmux/scripts/git-branch.sh",
    "tmux/scripts/runtimes.sh",
    "borders/bordersrc",
    "sketchybar/plugins/battery.sh",
    "sketchybar/plugins/cpu.sh",
    "sketchybar/plugins/memswap.sh",
    "sketchybar/plugins/space_windows.sh",
    "sketchybar/plugins/wifi.sh",
    "nvim/lua/util/transparency.lua",
]


def rgb(hex6):
    return tuple(int(hex6[i:i + 2], 16) for i in (0, 2, 4))


def blend(a, b, t):
    """Mix colour a toward colour b by t (0..1).

    Derived colours are mixed toward the theme's own background or foreground
    rather than scaled. Multiplying the channels drains the saturation out of a
    pastel palette: on Catppuccin it turned the yellow into a muddy tan.
    """
    return "".join(f"{round(x + (y - x) * t):02x}" for x, y in zip(rgb(a), rgb(b)))


def relight(hex6, lightness, sat=1.0):
    """Re-light a colour, keeping its hue and saturation.

    Blending toward the background instead would desaturate: Catppuccin's pink
    accent came out #8a708a, a grey mauve, which is what made the bar look
    washed out. Dropping only the lightness keeps the colour crisp.
    """
    h, _, s_ = colorsys.rgb_to_hls(*[c / 255 for c in rgb(hex6)])
    r, g, b = colorsys.hls_to_rgb(h, lightness, min(1.0, s_ * sat))
    return "".join(f"{round(c * 255):02x}" for c in (r, g, b))


def wcag(hex6):
    """Relative luminance per WCAG, which is not the same as perceptual luma."""
    out = []
    for c in rgb(hex6):
        c /= 255
        out.append(c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * out[0] + 0.7152 * out[1] + 0.0722 * out[2]


def contrast(a, b):
    x, y = wcag(a), wcag(b)
    return (max(x, y) + 0.05) / (min(x, y) + 0.05)


def raise_to(color, bg, floor):
    """Lighten a colour until it clears `floor` against bg, holding hue.

    Saturation is preserved, so autumnRed stays recognisably autumnRed; it just
    stops disappearing into the background.
    """
    if floor <= 0 or contrast(color, bg) >= floor:
        return color
    h, l, sat = colorsys.rgb_to_hls(*[c / 255 for c in rgb(color)])
    while l < 0.88 and contrast(color, bg) < floor:
        l += 0.005
        r, g, b = colorsys.hls_to_rgb(h, l, sat)
        color = "".join(f"{round(x * 255):02x}" for x in (r, g, b))
    return color


def solve_contrast(bg, fg):
    """Raise text-on-background contrast to CONTRAST_FLOOR, keeping both hues.

    Lifts the text first and only then darkens the background, because the text
    has more headroom and the background carries more of a theme's identity.
    On Kanagawa this lands the background on #16161d, which is sumiInk0, one of
    its own colours: the theme already contained the answer.
    """
    if CONTRAST_FLOOR <= 0 or contrast(fg, bg) >= CONTRAST_FLOOR:
        return bg, fg
    fg = relight(fg, min(FG_CEILING, max(FG_CEILING, 0)))
    h, l, sat = colorsys.rgb_to_hls(*[c / 255 for c in rgb(bg)])
    while l > 0.015 and contrast(fg, bg) < CONTRAST_FLOOR:
        l -= 0.002
        r, g, b = colorsys.hls_to_rgb(h, l, sat)
        bg = "".join(f"{round(x * 255):02x}" for x in (r, g, b))
    return bg, fg


def luma(hex6):
    r, g, b = rgb(hex6)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def read_theme(name):
    if not CACHE.exists():
        sys.exit("no kitty theme cache. run: kitty +kitten themes --dump-theme Nord")
    z = zipfile.ZipFile(CACHE)
    paths = {n.split("/")[-1][:-5]: n for n in z.namelist() if n.endswith(".conf")}
    if name not in paths:
        sys.exit(f"unknown theme {name!r}. try --list")
    raw = z.read(paths[name]).decode()
    colors = {}
    for line in raw.splitlines():
        # Capture every colour key, not just background/foreground/colorN.
        # selection_background lives outside that set and is wanted below.
        m = re.match(r"^\s*(\w+)\s+(#[0-9a-fA-F]{6})\s*$", line)
        if m:
            colors[m.group(1)] = m.group(2)[1:].lower()
    for required in ("background", "foreground", "color1", "color2", "color3", "color5"):
        if required not in colors:
            sys.exit(f"theme {name!r} is missing {required}")
    return raw, colors


def lift(hex6, amount=None):
    """Brighten a colour to pay for what the desktop leakage costs in contrast.

    Only foreground-ish colours get this. Lifting the background too would keep
    the tint we are trying to spend the leakage budget on.
    """
    by = LIFT if amount is None else amount
    if by <= 0:
        return hex6
    h, l, s = colorsys.rgb_to_hls(*[c / 255 for c in rgb(hex6)])
    r, g, b = colorsys.hls_to_rgb(h, min(TEXT_CAP, l + by), s)
    return "".join(f"{round(x * 255):02x}" for x in (r, g, b))


def pick_accent(c):
    """Choose the colour that gives a theme its character.

    Any fixed ANSI slot is the same hue in every theme by definition: color5 is
    magenta everywhere, which is why every theme came out purple no matter which
    one was applied. Pick the most saturated of color1..color6 instead, skewed
    away from near-white and near-black so it works as a fill. That lands on
    blue for Catppuccin, gold for rose-pine, orange for Gruvbox and coral for
    everforest, which is what those themes actually look like.
    """
    best, score = c["color5"], -1.0
    for i in range(1, 7):
        v = c.get(f"color{i}")
        if not v:
            continue
        _, l, sat = colorsys.rgb_to_hls(*[x / 255 for x in rgb(v)])
        weighted = sat * (1 - abs(l - 0.62))
        if weighted > score:
            best, score = v, weighted
    return best


def pick_focus(c, accent):
    """The fill behind the focused workspace.

    Prefer selection_background: theme authors choose it specifically as a fill
    that sits behind their foreground text, which is exactly this job, and it is
    a real colour from the palette rather than one computed here. Kanagawa's is
    waveBlue2, Rose Pine's and everforest's are equally deliberate.

    Not every theme can supply it. Catppuccin and Gruvbox use a *light*
    selection with dark text on it, which would be unreadable under the light
    labels the bar uses, so those fall back to the re-lit accent.
    """
    sel = c.get("selection_background")
    if sel and luma(sel) < 115 and luma(c["foreground"]) - luma(sel) > 90:
        return sel
    return relight(accent, 0.32, 1.15)


def roles_from(c):
    """Map a kitty palette onto the roles the configs actually use."""
    bg = c["background"]
    if BG_LUMA is not None:
        h, l, sat = colorsys.rgb_to_hls(*[x / 255 for x in rgb(bg)])
        while l > 0.002 and luma(bg) > BG_LUMA:
            l -= 0.001
            r_, g_, b_ = colorsys.hls_to_rgb(h, l, sat)
            bg = "".join(f"{round(x * 255):02x}" for x in (r_, g_, b_))
    bg, fg = solve_contrast(bg, lift(c["foreground"]))
    # The accent is a fill with dark text on it, so it must not be lifted:
    # brightening it just washes it toward white. Only text and icons get lift.
    accent = raw_accent = pick_accent(c)
    # The warm accent carries the bar outline and window borders. If the theme's
    # signature colour is already that yellow, step across to the cool slot so
    # the two are still telling you different things.
    if BORDER_SLOT and c.get(BORDER_SLOT):
        yellow = c[BORDER_SLOT]
    else:
        yellow = c["color4"] if raw_accent == c["color3"] else c["color3"]

    # color0 is usually a raised surface, but some themes (kanagawa) make it
    # darker than the background, which would make every pill disappear.
    surface = c.get("color0", "")
    if not surface or luma(surface) <= luma(bg):
        surface = blend(bg, fg, 0.12)

    return {
        "bg": bg,
        "surface": surface,
        # A fill sitting behind light text has to be dark, so it is the accent
        # re-lit rather than blended: same hue, same saturation, less light. The
        # accent itself stays untouched, since it sits behind dark text instead.
        "focus": pick_focus(c, accent),
        "accent": accent,
        "accent_strong": relight(accent, 0.58),
        "accent_soft": accent,
        "accent_bright": relight(accent, 0.82),
        "fg": fg,
        "fg_alt": fg,
        "muted": raise_to(
            lift(c["color8"]) if c.get("color8") else blend(fg, bg, 0.45),
            surface, MUTED_FLOOR),
        # The warm accent carries the bar outline, the active window border and
        # the clock. Every theme ships one as color3, so take it directly.
        "gold": yellow,
        "gold_dim": relight(yellow, 0.18, 1.1),
        "yellow": raise_to(lift(yellow), bg, SYNTAX_FLOOR),
        "green": raise_to(lift(c["color2"]), bg, SYNTAX_FLOOR),
        "red": raise_to(lift(c["color1"]), bg, SYNTAX_FLOOR),
        "pink": accent,
    }


def apply(new_roles, name, theme_raw):
    old = json.loads(STATE.read_text())
    old_roles = old["roles"]

    # Build old-hex -> new-hex. Two roles can share a hex (fg and fg_alt after a
    # previous apply), so collapse and warn rather than silently picking one.
    swap = {}
    for role, old_hex in old_roles.items():
        new_hex = new_roles[role]
        if old_hex in swap and swap[old_hex] != new_hex:
            print(f"  note: {old_hex} served both roles, using {swap[old_hex]}")
            continue
        swap[old_hex] = new_hex

    pattern = re.compile("|".join(sorted(swap, key=len, reverse=True)), re.I)
    for rel in TARGETS:
        p = ROOT / rel
        text = p.read_text()
        painted = pattern.sub(lambda m: swap[m.group(0).lower()], text)
        if painted != text:
            p.write_text(painted)
            print(f"  repainted {rel}")

    # The palette block in sketchybarrc is generated wholesale, otherwise its
    # header keeps naming whichever theme came first.
    r = new_roles
    block = f"""# ===== {name} Palette =====
# Generated by theme/apply.py, so the bar, the terminal, tmux and the window
# borders all draw from one palette. Run `python3 theme/apply.py {name}`
# rather than editing these by hand.
export BAR_COLOR=0xff{r['bg']}
export ITEM_BG_COLOR=0xff{r['surface']}
export ITEM_BG_FOCUSED=0xff{r['focus']}
export ACCENT_COLOR=0xff{r['accent']}
export FG_COLOR=0xff{r['fg']}
export FG_MUTED=0xff{r['muted']}
export DARK=0xff{r['bg']}
export GOLD=0xff{r['gold']}
export GOLD_DIM=0xff{r['gold_dim']}
export GREEN=0xff{r['green']}
export RED=0xff{r['red']}
export YELLOW=0xff{r['yellow']}
export MAGENTA=0xff{r['accent_soft']}"""
    rc_path = ROOT / "sketchybar" / "sketchybarrc"
    rc = rc_path.read_text()
    rc, n = re.subn(r"^# ===== .*Palette =====\n(?:.*\n)*?export MAGENTA=\S+",
                    lambda _: block, rc, count=1, flags=re.M)
    if n != 1:
        sys.exit("could not find the palette block in sketchybarrc")
    rc_path.write_text(rc)

    # kitty's own text colours have to be lifted too, not just the ones the bars
    # use. The theme file used to be written through untouched, so `foreground`
    # stayed at its shipped value and every bit of terminal text ignored LIFT
    # entirely: the brightening was real but invisible where it mattered most.
    #
    # background and the selection colours are left alone. Lifting background
    # would undo the leakage work, and a lifted selection stops contrasting with
    # the text sitting on it. Syntax colours get a gentler lift than plain text,
    # since they carry meaning through hue and wash out faster.
    def repaint_theme(line):
        m = re.match(r"^(\s*)(\w+)(\s+)#([0-9a-fA-F]{6})(\s*)$", line)
        if not m:
            return line
        pad, key, gap, value, tail = m.groups()
        if key == "background":
            new_value = r["bg"]          # solved for the contrast floor
        elif key == "foreground":
            new_value = r["fg"]
        elif key in ("color7", "color15"):
            # Held to the floor rather than overwritten with the foreground.
            # Argonaut ships these as pure #ffffff while its foreground is a
            # warm #fffaf3, so forcing them equal was dimming white text.
            new_value = raise_to(value.lower(), r["bg"], CONTRAST_FLOOR)
        elif key == "cursor":
            new_value = lift(value.lower())
        elif key in ("selection_background", "selection_foreground"):
            return line
        elif re.fullmatch(r"color(?:[1-69]|1[0-4])", key):
            # color8 is deliberately excluded. It is the dim slot, comments and
            # de-emphasised text, and forcing it to the syntax floor turned
            # #444444 into #a9a9a9: comments as loud as code.
            # Every syntax colour is raised to the floor against the solved
            # background. This is the change that actually clears the haze in
            # code, since the plain foreground is a small share of what is on
            # screen in an editor.
            new_value = raise_to(lift(value.lower(), LIFT * 0.55), r["bg"], SYNTAX_FLOOR)
        else:
            return line
        return f"{pad}{key}{gap}#{new_value}{tail}"

    theme_file = ROOT / "kitty" / "themes" / f"{name}.conf"
    theme_file.write_text("\n".join(repaint_theme(l) for l in theme_raw.splitlines()) + "\n")
    kitty_conf = ROOT / "kitty" / "kitty.conf"
    kc = kitty_conf.read_text()
    kc = re.sub(r"^include \./themes/.*$", f"include ./themes/{name}.conf",
                kc, count=1, flags=re.M)
    # Code-Readability.conf overrides color8/10/11 with values hand-picked
    # against Purple-Custom's greys, so it actively hurts any other theme. It
    # rides along with that one only.
    line = ("include ./themes/Code-Readability.conf" if name == "Purple-Custom"
            else "# include ./themes/Code-Readability.conf")
    kc = re.sub(r"^#? ?include \./themes/Code-Readability\.conf$", line, kc, flags=re.M)

    # Fully opaque. 0.7 was invisible only because Purple-Custom's background is
    # luma 2.5, near black: the desktop showing through had nothing to lift.
    # Every other theme is ten to twenty times brighter, so any translucency at
    # all reads as a tint over the screen. Scaling it to background brightness
    # still left 5% coming through, and that was still visible.
    kc = re.sub(r"^background_opacity .*$", f"background_opacity {OPACITY}", kc, flags=re.M)
    kc = re.sub(r"^background_blur .*$", "background_blur 0", kc, flags=re.M)

    # The tab bar is set here rather than left to the theme file, for two
    # reasons: the themes mostly paint the active tab the same colour as the
    # background, which gives it nothing to stand out against, and these four
    # lines sit after the include so they win anyway. Mirroring sketchybar's
    # front_app keeps the two bars saying the same thing.
    tabs = {
        "active_tab_foreground": r["bg"],
        "active_tab_background": r["accent"],
        "inactive_tab_foreground": r["muted"],
        "inactive_tab_background": r["surface"],
    }
    for key, value in tabs.items():
        kc = re.sub(rf"^{key}\s+\S+$", f"{key:<23} #{value}", kc, flags=re.M)
    print(f"  background_opacity {OPACITY}, blur 0")
    kitty_conf.write_text(kc)
    print(f"  repainted kitty/kitty.conf -> themes/{name}.conf")

    STATE.write_text(json.dumps({"theme": name, "roles": new_roles}, indent=2) + "\n")


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    if sys.argv[1] == "--list":
        z = zipfile.ZipFile(CACHE)
        for n in sorted(x.split("/")[-1][:-5] for x in z.namelist() if x.endswith(".conf")):
            print(n)
        return
    name = sys.argv[1]
    raw, colors = read_theme(name)
    print(f"applying {name}")
    apply(roles_from(colors), name, raw)
    print("\nreload with:")
    print("  sketchybar --reload")
    print("  tmux source-file ~/.config/tmux/tmux.conf")
    print("  brew services restart borders")
    print("  kitty @ load-config")


if __name__ == "__main__":
    main()
