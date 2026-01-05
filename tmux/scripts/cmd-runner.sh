#!/bin/bash
# Command runner - reads commands from config and runs selected one

GLOBAL_FILE="$HOME/.config/tmux/commands"
LOCAL_FILE="./.tmux-commands"

# Handle Ctrl+C gracefully
trap 'echo -e "\nCancelled."; exit 0' INT

# Check for project-local commands first, then global
if [[ -f "$LOCAL_FILE" ]]; then
    CMD_FILE="$LOCAL_FILE"
elif [[ -f "$GLOBAL_FILE" ]]; then
    CMD_FILE="$GLOBAL_FILE"
else
    mkdir -p "$(dirname "$GLOBAL_FILE")"
    echo "# Commands - Format: description | command" > "$GLOBAL_FILE"
    CMD_FILE="$GLOBAL_FILE"
fi

# Build the list with options at the top
list=$(echo -e "+ Add command (global)\n+ Add command (project)\n- Delete command\n- Edit commands file\n---"
cat "$CMD_FILE" 2>/dev/null | grep -v '^#' | grep -v '^$')

# Show fzf picker
selected=$(echo "$list" | fzf --reverse \
    --header="Run Command [$CMD_FILE] (Esc to close)" \
    --border=rounded \
    --margin=1,2 \
    --padding=1 \
    --preview='echo {} | grep -q "^[+-]" && echo "Action" || echo {} | cut -d"|" -f2 | xargs -I {} echo "Command: {}"' \
    --preview-window=down:1:wrap)

[[ -z "$selected" ]] && exit 0

# Handle add command (global)
if [[ "$selected" == "+ Add command (global)" ]]; then
    target="$GLOBAL_FILE"
    echo "Adding to: $target"
    echo "(Press Ctrl+C to cancel, or leave empty)"
    echo ""
    read -p "Description: " desc
    [[ -z "$desc" ]] && echo "Cancelled." && exit 0

    read -p "Command: " cmd
    [[ -z "$cmd" ]] && echo "Cancelled." && exit 0

    echo "$desc | $cmd" >> "$target"
    echo ""
    echo "Added: $desc | $cmd"
    read -p "Press enter to close..."
    exit 0
fi

# Handle add command (project)
if [[ "$selected" == "+ Add command (project)" ]]; then
    target="$LOCAL_FILE"

    if [[ ! -f "$target" ]]; then
        echo "# Project commands - Format: description | command" > "$target"
    fi

    echo "Adding to: $target"
    echo "(Press Ctrl+C to cancel, or leave empty)"
    echo ""
    read -p "Description: " desc
    [[ -z "$desc" ]] && echo "Cancelled." && exit 0

    read -p "Command: " cmd
    [[ -z "$cmd" ]] && echo "Cancelled." && exit 0

    echo "$desc | $cmd" >> "$target"
    echo ""
    echo "Added: $desc | $cmd"
    read -p "Press enter to close..."
    exit 0
fi

# Handle delete command
if [[ "$selected" == "- Delete command" ]]; then
    # Show commands for deletion
    to_delete=$(cat "$CMD_FILE" 2>/dev/null | grep -v '^#' | grep -v '^$' | fzf --reverse \
        --header="Select command to delete (Esc to cancel)" \
        --border=rounded \
        --margin=1,2 \
        --padding=1)

    if [[ -n "$to_delete" ]]; then
        # Escape special chars for sed
        escaped=$(echo "$to_delete" | sed 's/[\/&]/\\&/g')
        sed -i '' "/^${escaped}$/d" "$CMD_FILE"
        echo "Deleted: $to_delete"
        read -p "Press enter to close..."
    fi
    exit 0
fi

# Handle edit commands file
if [[ "$selected" == "- Edit commands file" ]]; then
    ${EDITOR:-nvim} "$CMD_FILE"
    exit 0
fi

# Skip separator
[[ "$selected" == "---" ]] && exit 0

# Extract and run command
cmd=$(echo "$selected" | cut -d'|' -f2 | xargs)

clear
echo "Running: $cmd"
echo "Directory: $(pwd)"
echo "----------------------------------------"
eval "$cmd"

echo ""
echo "----------------------------------------"
read -p "Press enter to close..."
