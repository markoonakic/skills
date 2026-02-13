#!/bin/bash
#
# Ralph Loop - Autonomous Implementation Loop
#
# Key Principle: Each iteration gets a FRESH context window via headless mode.
# The spec files + implementation plan are the source of truth, not conversation history.
#
# Usage: ./ralph-loop.sh [phase-name]
#
# Options:
#   --max-iterations=N    Safety limit (default: 50)
#   --no-pause            Don't pause between iterations
#

set -e

# Default configuration
MAX_ITERATIONS=50
NO_PAUSE=false
PHASE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --max-iterations=*)
            MAX_ITERATIONS="${1#*=}"
            shift
            ;;
        --no-pause)
            NO_PAUSE=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Usage: ./ralph-loop.sh [--max-iterations=N] [--no-pause] <phase-name>"
            exit 1
            ;;
        *)
            PHASE="$1"
            shift
            ;;
    esac
done

# Auto-detect phase if not specified
if [[ -z "$PHASE" ]]; then
    if [[ -d "specs" ]]; then
        PHASE=$(ls -d specs/*/ 2>/dev/null | head -1 | sed 's|specs/||' | sed 's|/$||')
    fi
    if [[ -z "$PHASE" ]]; then
        echo "ERROR: No phase specified and couldn't auto-detect"
        echo "Usage: ./ralph-loop.sh <phase-name>"
        exit 1
    fi
fi

SPECS_DIR="specs/${PHASE}"
PROMPT_FILE="PROMPT.md"
ITERATION=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  RALPH LOOP - Autonomous Implementation${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Phase:     ${YELLOW}${PHASE}${NC}"
echo -e "Specs:     ${YELLOW}${SPECS_DIR}/${NC}"
echo -e "Max iter:  ${YELLOW}${MAX_ITERATIONS}${NC}"
echo ""

# Prerequisites check
if [[ ! -f "$PROMPT_FILE" ]]; then
    echo -e "${RED}ERROR: $PROMPT_FILE not found${NC}"
    echo "Run /ralph-init first to create the necessary files."
    exit 1
fi

if [[ ! -d "$SPECS_DIR" ]]; then
    echo -e "${RED}ERROR: Specs directory $SPECS_DIR not found${NC}"
    echo "Run /ralph-init first to create the necessary files."
    exit 1
fi

if [[ ! -f "$SPECS_DIR/spec.md" ]]; then
    echo -e "${RED}ERROR: $SPECS_DIR/spec.md not found${NC}"
    exit 1
fi

if [[ ! -f "$SPECS_DIR/implementation-plan.md" ]]; then
    echo -e "${RED}ERROR: $SPECS_DIR/implementation-plan.md not found${NC}"
    exit 1
fi

if [[ ! -f "$SPECS_DIR/context.md" ]]; then
    echo -e "${RED}ERROR: $SPECS_DIR/context.md not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"
echo ""

# Context budget check (rough estimate: ~4 chars per token)
TOTAL_CHARS=$(cat "$SPECS_DIR"/*.md "$PROMPT_FILE" 2>/dev/null | wc -c)
ESTIMATED_TOKENS=$((TOTAL_CHARS / 4))
if [[ $ESTIMATED_TOKENS -gt 15000 ]]; then
    echo -e "${YELLOW}WARNING: Specs estimated at ~${ESTIMATED_TOKENS} tokens (limit: 15,000)${NC}"
    echo "Consider consolidating specs to stay under budget."
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for completion marker
check_completion() {
    if grep -q "\[x\] COMPLETE" "$SPECS_DIR/implementation-plan.md" 2>/dev/null; then
        return 0
    fi
    # Check if all tasks are complete
    REMAINING=$(grep -c "^\- \[ \]" "$SPECS_DIR/implementation-plan.md" 2>/dev/null || echo "0")
    if [[ "$REMAINING" == "0" ]]; then
        return 0
    fi
    return 1
}

# Main loop
while [[ $ITERATION -lt $MAX_ITERATIONS ]]; do
    ITERATION=$((ITERATION + 1))

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ITERATION $ITERATION${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Check completion
    if check_completion; then
        echo -e "${GREEN}✅ Phase marked as COMPLETE!${NC}"
        echo "Ralph Loop finished successfully."
        exit 0
    fi

    # Count remaining
    REMAINING=$(grep -c "^\- \[ \]" "$SPECS_DIR/implementation-plan.md" 2>/dev/null || echo "0")
    echo -e "Remaining tasks: ${YELLOW}$REMAINING${NC}"
    echo ""

    # Run Claude in headless mode with fresh context
    echo -e "${BLUE}Starting Claude with fresh context...${NC}"
    echo ""

    claude -p "$(cat $PROMPT_FILE)"

    EXIT_CODE=$?

    if [[ $EXIT_CODE -ne 0 ]]; then
        echo ""
        echo -e "${RED}ERROR: Claude exited with code $EXIT_CODE${NC}"
        echo "Check the output above for errors."
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    echo ""
    echo -e "${YELLOW}Iteration $ITERATION complete.${NC}"

    if [[ "$NO_PAUSE" != true ]]; then
        echo "Press Enter to continue, or Ctrl+C to stop and review."
        read -r
    fi

    sleep 1
done

echo ""
echo -e "${YELLOW}⚠️  Reached maximum iterations ($MAX_ITERATIONS)${NC}"
echo "Check implementation-plan.md for remaining tasks."
exit 1
