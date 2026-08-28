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

import json
import pathlib
import re
import sys
import zipfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
STATE = ROOT / "theme" / "current.json"
CACHE = pathlib.Path.home() / "Library/Caches/kitty/kitty-themes.zip"

# Every file that carries a colour. Order does not matter.
TARGETS = [
    "sketchybar/sketchybarrc",
    "tmux/tmux.conf",
    "tmux/scripts/pr-status.sh",
    "tmux/scripts/git-branch.sh",
    "borders/bordersrc",
    "sketchybar/plugins/battery.sh",
    "sketchybar/plugins/cpu.sh",
    "sketchybar/plugins/memswap.sh",
    "sketchybar/plugins/space_windows.sh",
]


def scale(hex6, factor):
    """Darken (factor < 1) or lighten (factor > 1) a colour, staying in gamut."""
    r, g, b = (int(hex6[i:i + 2], 16) for i in (0, 2, 4))
    return "".join(f"{min(255, max(0, round(c * factor))):02x}" for c in (r, g, b))


def luma(hex6):
    r, g, b = (int(hex6[i:i + 2], 16) for i in (0, 2, 4))
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
        m = re.match(r"^\s*(background|foreground|color\d+)\s+(#[0-9a-fA-F]{6})\s*$", line)
        if m:
            colors[m.group(1)] = m.group(2)[1:].lower()
    for required in ("background", "foreground", "color1", "color2", "color3", "color5"):
        if required not in colors:
            sys.exit(f"theme {name!r} is missing {required}")
    return raw, colors


def roles_from(c):
    """Map a kitty palette onto the roles the configs actually use."""
    bg, fg = c["background"], c["foreground"]
    accent = c["color5"]
    yellow = c["color3"]

    # color0 is usually a raised surface, but some themes (kanagawa) make it
    # darker than the background, which would make every pill disappear.
    surface = c.get("color0", "")
    if not surface or luma(surface) <= luma(bg):
        surface = scale(bg, 1.6)

    return {
        "bg": bg,
        "surface": surface,
        "focus": scale(accent, 0.55),      # fill behind light text
        "accent": accent,                  # fill behind background-coloured text
        "accent_strong": scale(accent, 0.85),
        "accent_soft": accent,
        "accent_bright": scale(accent, 1.15),
        "fg": fg,
        "fg_alt": fg,
        "muted": c.get("color8") or scale(fg, 0.55),
        "gold": scale(yellow, 0.75),
        "gold_dim": scale(yellow, 0.3),
        "yellow": yellow,
        "green": c["color2"],
        "red": c["color1"],
        "pink": c.get("color13", accent),
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

    # kitty gets the upstream theme file verbatim.
    theme_file = ROOT / "kitty" / "themes" / f"{name}.conf"
    theme_file.write_text(theme_raw)
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
