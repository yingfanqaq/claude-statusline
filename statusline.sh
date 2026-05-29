#!/bin/bash
INPUT=$(cat)

py() { python3 -c "$1" 2>/dev/null; }

MODEL=$(py "import sys,json; d=json.load(sys.stdin); print(d.get('model',{}).get('display_name','') or d.get('model',''))" <<< "$INPUT")
CTX_USED=$(py "import sys,json; d=json.load(sys.stdin); print(d.get('context_window',{}).get('total_input_tokens',0))" <<< "$INPUT")
CTX_SIZE=$(py "import sys,json; d=json.load(sys.stdin); print(d.get('context_window',{}).get('context_window_size',0))" <<< "$INPUT")
CTX_PCT=$(py "import sys,json; d=json.load(sys.stdin); print(d.get('context_window',{}).get('used_percentage') or '')" <<< "$INPUT")
EFFORT=$(py "import sys,json; d=json.load(sys.stdin); print(d.get('effort',{}).get('level',''))" <<< "$INPUT")
THINKING=$(py "import sys,json; d=json.load(sys.stdin); print(d.get('thinking',{}).get('enabled',False))" <<< "$INPUT")
CWD=$(py "import sys,json; d=json.load(sys.stdin); print(d.get('workspace',{}).get('current_dir','') or d.get('cwd',''))" <<< "$INPUT")

RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
C_PURPLE="\033[38;5;141m"
C_BLUE="\033[38;5;75m"
C_CYAN="\033[38;5;116m"
C_GREEN="\033[38;5;114m"
C_YELLOW="\033[38;5;221m"
C_ORANGE="\033[38;5;215m"
C_RED="\033[38;5;203m"
C_GRAY="\033[38;5;245m"
C_PINK="\033[38;5;219m"

SEP="${DIM}${C_GRAY} │ ${RESET}"

# ── Model ──────────────────────────────────────────────────────────────
if [ -n "$MODEL" ]; then
  MODEL_SHORT=$(echo "$MODEL" | sed 's/Claude //' | sed 's/claude-//' | sed 's/\[.*\]//' | sed 's/ (.*)//')
else
  MODEL_SHORT="claude"
fi
MODEL_SEG="${C_PURPLE}${BOLD} ${MODEL_SHORT}${RESET}"

# ── Effort / Thinking ──────────────────────────────────────────────────
EFFORT_SEG=""
if [ -n "$EFFORT" ]; then
  case "$EFFORT" in
    low)    EFFORT_ICON="󰋙"; EFFORT_COLOR="$C_GRAY";   EFFORT_LABEL="low"   ;;
    medium) EFFORT_ICON="󰋙"; EFFORT_COLOR="$C_CYAN";   EFFORT_LABEL="med"   ;;
    high)   EFFORT_ICON="󰋙"; EFFORT_COLOR="$C_YELLOW"; EFFORT_LABEL="high"  ;;
    xhigh)  EFFORT_ICON="󰋙"; EFFORT_COLOR="$C_ORANGE"; EFFORT_LABEL="xhigh" ;;
    max)    EFFORT_ICON="󰋙"; EFFORT_COLOR="$C_RED";    EFFORT_LABEL="max"   ;;
    *)      EFFORT_ICON="󰋙"; EFFORT_COLOR="$C_GRAY";   EFFORT_LABEL="$EFFORT" ;;
  esac
  EFFORT_SEG="${EFFORT_COLOR}${BOLD}${EFFORT_ICON} ${EFFORT_LABEL}${RESET}"
  # append thinking indicator
  if [ "$THINKING" = "True" ]; then
    EFFORT_SEG="${EFFORT_SEG} ${C_PINK}${DIM}thinking${RESET}"
  fi
fi

# ── Context bar ────────────────────────────────────────────────────────
CTX_SEG=""
if [ -n "$CTX_PCT" ] && [ "$CTX_PCT" != "None" ] && [ "$CTX_PCT" != "" ]; then
  PCT=$(py "print(int(float('$CTX_PCT')))")
  K_USED=$(py "print(f'{$CTX_USED/1000:.0f}k')")
  K_SIZE=$(py "print(f'{$CTX_SIZE/1000:.0f}k')")
  FILLED=$(py "print(int($PCT/100*8))")
  EMPTY=$((8 - FILLED))
  BAR=$(py "print('█'*$FILLED + '░'*$EMPTY)")
  if   [ "$PCT" -lt 50 ]; then CTX_COLOR="$C_GREEN"
  elif [ "$PCT" -lt 80 ]; then CTX_COLOR="$C_YELLOW"
  else                         CTX_COLOR="$C_RED"
  fi
  CTX_SEG="${CTX_COLOR}${BAR} ${PCT}%${RESET} ${DIM}${C_GRAY}${K_USED}/${K_SIZE}${RESET}"
fi

# ── Directory ──────────────────────────────────────────────────────────
DIR_SEG=""
if [ -n "$CWD" ]; then
  DIR_DISPLAY=$(echo "$CWD" | sed "s|$HOME|~|" | awk -F'/' '{n=NF; if(n<=2) print $0; else print $(n-1)"/"$n}')
  DIR_SEG="${C_BLUE} ${DIR_DISPLAY}${RESET}"
fi

# ── Assemble ───────────────────────────────────────────────────────────
PARTS=()
PARTS+=("$MODEL_SEG")
[ -n "$EFFORT_SEG" ] && PARTS+=("$EFFORT_SEG")
[ -n "$CTX_SEG"    ] && PARTS+=("$CTX_SEG")
[ -n "$DIR_SEG"    ] && PARTS+=("$DIR_SEG")

OUT=""
for i in "${!PARTS[@]}"; do
  [ $i -gt 0 ] && OUT+="$SEP"
  OUT+="${PARTS[$i]}"
done

echo -e "$OUT"
