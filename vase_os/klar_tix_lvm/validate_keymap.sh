#!/bin/bash
# Keyboard Layout Validation Script
# Validates both console keymaps and X11 layouts using symbols-202511.json

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYMBOLS_JSON="${SCRIPT_DIR}/symbols-202511.json"

# Validate console keymap (for vconsole.conf)
validate_console_keymap() {
    local layout="$1"
    local keymap_dirs="/usr/share/kbd/keymaps"

    if [ ! -d "$keymap_dirs" ]; then
        echo -e "${RED}Error: Console keymap directory not found: $keymap_dirs${NC}"
        return 1
    fi

    # Search for the keymap file (with or without .map.gz extension)
    local found=$(find "$keymap_dirs" -type f \( -name "${layout}.map.gz" -o -name "${layout}.map" \) 2>/dev/null | head -1)

    if [ -n "$found" ]; then
        echo -e "${GREEN}✓ Console keymap found: $found${NC}"
        return 0
    else
        echo -e "${RED}✗ Console keymap '$layout' not found${NC}"
        echo -e "${YELLOW}Available Belgian keymaps:${NC}"
        find "$keymap_dirs" -type f -name "*be*.map.gz" 2>/dev/null | sed 's|.*/||; s|\.map\.gz||' | head -10
        return 1
    fi
}

# Validate X11 layout using JSON file (for GRUB ckbcomp)
validate_x11_layout_json() {
    local layout="$1"
    local variant="$2"

    if [ ! -f "$SYMBOLS_JSON" ]; then
        echo -e "${RED}Error: symbols JSON not found: $SYMBOLS_JSON${NC}"
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is not installed${NC}"
        return 1
    fi

    # Extract base layout name (remove anything after dash)
    local base_layout="${layout%%-*}"

    # Check if layout exists in JSON
    local layout_exists=$(jq -r "has(\"$base_layout\")" "$SYMBOLS_JSON")

    if [ "$layout_exists" != "true" ]; then
        echo -e "${RED}✗ X11 layout '$base_layout' not found in symbols database${NC}"
        return 1
    fi

    echo -e "${GREEN}✓ X11 layout found: $base_layout${NC}"

    # If variant specified, validate it
    if [ -n "$variant" ]; then
        local variant_exists=$(jq -r ".\"$base_layout\" | index(\"$variant\") != null" "$SYMBOLS_JSON")

        if [ "$variant_exists" = "true" ]; then
            echo -e "${GREEN}✓ X11 variant found: $variant${NC}"
            return 0
        else
            echo -e "${RED}✗ X11 variant '$variant' not found for layout '$base_layout'${NC}"
            echo -e "${YELLOW}Available variants for $base_layout:${NC}"
            jq -r ".\"$base_layout\"[]" "$SYMBOLS_JSON" | sed 's/^/  - /'
            return 1
        fi
    else
        # No variant specified, show available variants
        echo -e "${GREEN}✓ Using default variant for $base_layout${NC}"
        echo -e "${YELLOW}Available variants:${NC}"
        jq -r ".\"$base_layout\"[]" "$SYMBOLS_JSON" | sed 's/^/  - /' | head -5
        return 0
    fi
}

# Main validation function
validate_keyboard_layout() {
    local console_keymap="$1"
    local x11_layout="$2"
    local x11_variant="$3"
    local check_x11="${4:-true}"  # Default to checking X11

    echo "=================================="
    echo "Keyboard Layout Validation"
    echo "=================================="
    echo "X11 Layout:      $x11_layout"
    echo "X11 Variant:     ${x11_variant:-<default>}"
    if [ -n "$console_keymap" ]; then
        echo "Console Keymap:  $console_keymap"
    fi
    echo "=================================="
    echo ""

    local console_valid=1  # Default to valid if not checked
    local x11_valid=0

    # Validate console keymap only if provided
    if [ -n "$console_keymap" ]; then
        console_valid=0
        echo "Checking console keymap..."
        if validate_console_keymap "$console_keymap"; then
            console_valid=1
        fi
        echo ""
    fi

    # Validate X11 layout if requested
    if [ "$check_x11" = "true" ]; then
        echo "Checking X11 layout (for GRUB ckbcomp, SDDM, and KDE Plasma)..."
        if validate_x11_layout_json "$x11_layout" "$x11_variant"; then
            x11_valid=1
        fi
        echo ""
    fi

    # Summary
    echo "=================================="
    if [ $console_valid -eq 1 ] && ([ "$check_x11" = "false" ] || [ $x11_valid -eq 1 ]); then
        echo -e "${GREEN}✓ Validation PASSED${NC}"
        echo "=================================="
        return 0
    else
        echo -e "${RED}✗ Validation FAILED${NC}"
        echo "=================================="
        echo ""
        echo -e "${YELLOW}Recommendation:${NC}"
        echo "Check your keyboard configuration in klartix.conf:"
        echo "  KB_LAYOUT=\"$x11_layout\""
        echo "  KB_VARIANT=\"$x11_variant\""
        return 1
    fi
}

# If script is run directly (not sourced), validate provided arguments
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    CONSOLE_KEYMAP="${1:-}"
    X11_LAYOUT="${2:-}"
    X11_VARIANT="${3:-}"

    if [ -z "$CONSOLE_KEYMAP" ] || [ -z "$X11_LAYOUT" ]; then
        echo "Usage: $0 <console_keymap> <x11_layout> [x11_variant]"
        echo "Example: $0 be-latin1 be"
        echo "Example: $0 be-latin1 be nodeadkeys"
        exit 1
    fi

    validate_keyboard_layout "$CONSOLE_KEYMAP" "$X11_LAYOUT" "$X11_VARIANT"
    exit $?
fi
