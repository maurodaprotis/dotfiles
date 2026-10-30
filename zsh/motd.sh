#!/bin/bash
# SSH splash: host banner + system summary. zshrc runs it once per SSH session.
host="${HOSTNAME:-$(hostname)}"; host="${host%%.*}"

# Same hash as prompt.zsh, so banner and prompt share the host color
palette=(203 215 222 114 116 117 176); h=0
for ((i = 0; i < ${#host}; i++)); do
  printf -v code '%d' "'${host:i:1}"
  h=$(( (h * 31 + code) % 65521 ))
done
color="${PROMPT_HOST_COLOR:-${palette[h % ${#palette[@]}]}}"
C=$'\e'"[38;5;${color}m"; D=$'\e[38;5;243m'; B=$'\e[1m'; R=$'\e[0m'

echo
if command -v figlet >/dev/null; then
  printf '%s' "$C"; figlet -f slant "$host"; printf '%s' "$R"
else
  printf '%s%s%s\n\n' "$C$B" "$host" "$R"
fi

row() { printf '  %s%-8s%s %s\n' "$D" "$1" "$R" "$2"; }

if [[ -r /etc/os-release ]]; then . /etc/os-release; os="$PRETTY_NAME"; else os="$(uname -sr)"; fi
up=$(uptime -p 2>/dev/null | sed 's/^up //')
[[ -z "$up" ]] && up=$(uptime | sed -E 's/.*up +(.*), [0-9]+ users?.*/\1/')
load=$(uptime | sed -E 's/.*load averages?: //; s/,//g')
cpus=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
mem=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 " / " $2}')
disk=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
ts=$(tailscale ip -4 2>/dev/null)
tmux_s=$(tmux ls -F '#S' 2>/dev/null | paste -sd, -)
t3=$(systemctl --user is-active t3code.service 2>/dev/null)
upd=$(grep -oE '^[0-9]+ updates?' /var/lib/update-notifier/updates-available 2>/dev/null | head -1)
[[ -f /var/run/reboot-required ]] && reboot=" · reboot required"

row OS "$os · $(uname -r)"
row Uptime "$up · load $load"
row CPU/Mem "$cpus cpu · ${mem:-$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1073741824) " GiB"}')}"
row Disk "$disk"
row Tailnet "${ts:-not connected}"
[[ -n "$upd$reboot" ]] && row Updates "${upd:-none}${reboot}"
row tmux "${tmux_s:-no sessions}"
[[ -n "$t3" ]] && row T3 "$t3"
echo
