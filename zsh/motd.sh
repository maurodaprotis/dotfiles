#!/bin/bash
# SSH splash. zshrc runs it once per SSH session. fastfetch when installed, plain summary otherwise.
if command -v fastfetch >/dev/null; then
  fastfetch
  exit 0
fi

host="${HOSTNAME:-$(hostname)}"; host="${host%%.*}"
D=$'\e[38;5;243m'; B=$'\e[1m'; R=$'\e[0m'
row() { printf '  %s%-8s%s %s\n' "$D" "$1" "$R" "$2"; }

if [[ -r /etc/os-release ]]; then . /etc/os-release; os="$PRETTY_NAME"; else os="$(uname -sr)"; fi
up=$(uptime -p 2>/dev/null | sed 's/^up //')
[[ -z "$up" ]] && up=$(uptime | sed -E 's/.*up +(.*), [0-9]+ users?.*/\1/')
mem=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 " / " $2}')
disk=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
ts=$(tailscale ip -4 2>/dev/null)

echo; printf '  %s%s%s\n\n' "$B" "$host" "$R"
row OS "$os · $(uname -r)"
row Uptime "$up"
row Memory "${mem:-?}"
row Disk "$disk"
row Tailnet "${ts:-not connected}"
echo
