# Warp-style prompt for zsh
# Situation-aware: segments only appear when relevant
# NOTE: This overrides whatever ZSH_THEME oh-my-zsh set. Your .zshrc is untouched.

setopt PROMPT_SUBST

# Disable oh-my-zsh theme's prompt so ours takes over
PROMPT=''
RPROMPT=''

# ─── Colors (256-color for broad terminal support) ───────────────────
_P_RESET="%f%k"
_P_BG=""
_P_FG_GREEN="%F{114}"
_P_FG_BLUE="%F{117}"
_P_FG_YELLOW="%F{222}"
_P_FG_GRAY="%F{252}"
_P_FG_GREENTEXT="%F{114}"
_P_FG_REDTEXT="%F{210}"
_P_FG_DIM="%F{243}"
_P_FG_CYAN="%F{116}"
_P_FG_ORANGE="%F{215}"
_P_FG_MAGENTA="%F{176}"
_P_FG_RED="%F{203}"

# ─── Nerd Font Icons ─────────────────────────────────────────────────
_ICON_NODE="󰎙"
_ICON_PYTHON="󰌠"
_ICON_FOLDER="󰉋"
_ICON_BRANCH=""
_ICON_FILE=""
_ICON_CLOCK="󰅐"
_ICON_FAIL="✘"
_ICON_JOBS="󰜎"
_ICON_AWS="󰸏"
_ICON_GCP="󱇶"
_ICON_KUBE="󱃾"
_ICON_DOCKER="󰡨"
_ICON_VENV="󰌠"

# ─── Timer (track command duration) ──────────────────────────────────
_prompt_timer_start() {
  _PROMPT_TIMER_START=${_PROMPT_TIMER_START:-$EPOCHREALTIME}
}

_prompt_timer_stop() {
  if [[ -n "$_PROMPT_TIMER_START" ]]; then
    local elapsed=$(( EPOCHREALTIME - _PROMPT_TIMER_START ))
    _PROMPT_LAST_DURATION=$elapsed
    unset _PROMPT_TIMER_START
  fi
}

# Hook into command execution
preexec() {
  _PROMPT_TIMER_START=$EPOCHREALTIME
}

# ─── Segment Helpers ─────────────────────────────────────────────────

_seg() {
  # Usage: _seg <fg_color> <icon> <text>
  echo "${_P_BG} ${1}${2} ${3}${_P_RESET} "
}

# ─── Situational Segments ────────────────────────────────────────────

# Node or Python version — only in projects that use them
_prompt_runtime() {
  if [[ -f package.json || -f .nvmrc || -f .node-version ]]; then
    local v=$(node --version 2>/dev/null)
    [[ -n "$v" ]] && _seg "$_P_FG_GREEN" "$_ICON_NODE" "$v" && return
  fi
  if [[ -f pyproject.toml || -f setup.py || -f requirements.txt || -f Pipfile || -f .python-version ]]; then
    local v=$(python3 --version 2>/dev/null | awk '{print $2}')
    [[ -n "$v" ]] && _seg "$_P_FG_GREEN" "$_ICON_PYTHON" "$v" && return
  fi
}

# Current directory
_prompt_dir() {
  local dir="${PWD/#$HOME/~}"
  _seg "$_P_FG_BLUE" "$_ICON_FOLDER" "$dir"
}

# Git branch + diff stats — only in git repos
_prompt_git() {
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return

  local git_out="${_P_BG} ${_P_FG_YELLOW}${_ICON_BRANCH} ${branch}${_P_RESET} "

  # Diff stats
  local stats=$(git diff --stat HEAD 2>/dev/null | tail -1)
  if [[ -n "$stats" ]]; then
    local files=$(echo "$stats" | grep -oE '[0-9]+ files? changed' | grep -oE '[0-9]+')
    local ins=$(echo "$stats" | grep -oE '[0-9]+ insertions?' | grep -oE '[0-9]+')
    local del=$(echo "$stats" | grep -oE '[0-9]+ deletions?' | grep -oE '[0-9]+')
    [[ -z "$files" ]] && files=0
    [[ -z "$ins" ]] && ins=0
    [[ -z "$del" ]] && del=0

    if (( files > 0 )); then
      local s="${_P_BG} ${_P_FG_GRAY}${_ICON_FILE} ${files} ${_P_FG_DIM}•"
      (( ins > 0 )) && s+=" ${_P_FG_GREENTEXT}+${ins}"
      (( del > 0 )) && s+=" ${_P_FG_REDTEXT}-${del}"
      git_out+="${s}${_P_RESET} "
    fi
  fi

  echo "$git_out"
}

# Python virtualenv — only when one is active
_prompt_venv() {
  [[ -z "$VIRTUAL_ENV" && -z "$CONDA_DEFAULT_ENV" ]] && return
  local name="${VIRTUAL_ENV:+$(basename "$VIRTUAL_ENV")}"
  name="${name:-$CONDA_DEFAULT_ENV}"
  _seg "$_P_FG_GREEN" "$_ICON_VENV" "$name"
}

# AWS profile — only when AWS_PROFILE is set
_prompt_aws() {
  [[ -z "$AWS_PROFILE" ]] && return
  _seg "$_P_FG_ORANGE" "$_ICON_AWS" "$AWS_PROFILE"
}

# GCP project — only when CLOUDSDK_CORE_PROJECT or active config is set
_prompt_gcp() {
  local project="${CLOUDSDK_CORE_PROJECT:-}"
  if [[ -z "$project" ]]; then
    # Check active gcloud config (cached — only reads a file, no subprocess)
    local config_file="$HOME/.config/gcloud/properties"
    if [[ -f "$config_file" ]]; then
      project=$(grep -A5 '^\[core\]' "$config_file" 2>/dev/null | grep '^project' | cut -d= -f2 | tr -d ' ')
    fi
  fi
  [[ -z "$project" ]] && return
  _seg "$_P_FG_CYAN" "$_ICON_GCP" "$project"
}

# Kubernetes context — only when kubectl is configured
_prompt_kube() {
  # Only show if KUBECONFIG is set or default config exists
  [[ ! -f "${KUBECONFIG:-$HOME/.kube/config}" ]] && return
  local ctx=$(kubectl config current-context 2>/dev/null)
  [[ -z "$ctx" ]] && return
  local ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
  [[ -n "$ns" && "$ns" != "default" ]] && ctx="${ctx}/${ns}"
  _seg "$_P_FG_CYAN" "$_ICON_KUBE" "$ctx"
}

# Docker — only when inside a container
_prompt_docker() {
  # Check common container indicators
  if [[ -f /.dockerenv ]] || grep -qsm1 'docker\|containerd' /proc/1/cgroup 2>/dev/null; then
    _seg "$_P_FG_CYAN" "$_ICON_DOCKER" "container"
  fi
}

# Background jobs — only when there are suspended/background jobs
_prompt_jobs() {
  local j=$(jobs -s 2>/dev/null | wc -l | tr -d ' ')
  (( j > 0 )) && _seg "$_P_FG_MAGENTA" "$_ICON_JOBS" "${j}"
}

# Last command duration — only when > 2 seconds
_prompt_duration() {
  [[ -z "$_PROMPT_LAST_DURATION" ]] && return
  local d=$_PROMPT_LAST_DURATION
  (( d < 2 )) && return

  local display
  if (( d >= 3600 )); then
    display="$(( ${d%.*} / 3600 ))h$(( (${d%.*} % 3600) / 60 ))m"
  elif (( d >= 60 )); then
    display="$(( ${d%.*} / 60 ))m$(( ${d%.*} % 60 ))s"
  else
    display="${d%.*}s"
  fi
  _seg "$_P_FG_DIM" "$_ICON_CLOCK" "$display"
}

# Last command exit code — only on failure
_prompt_exitcode() {
  [[ "$_PROMPT_LAST_EXIT" -eq 0 ]] && return
  _seg "$_P_FG_RED" "$_ICON_FAIL" "$_PROMPT_LAST_EXIT"
}

# ─── Build Prompt ─────────────────────────────────────────────────────

_build_prompt() {
  # Line 1: context segments (runtime, dir, git, cloud, etc.)
  local line1=""
  line1+="$(_prompt_runtime)"
  line1+="$(_prompt_venv)"
  line1+="$(_prompt_dir)"
  line1+="$(_prompt_git)"
  line1+="$(_prompt_aws)"
  line1+="$(_prompt_gcp)"
  line1+="$(_prompt_kube)"
  line1+="$(_prompt_docker)"

  # Line 2 (right side context): duration, jobs, exit code
  local line2=""
  line2+="$(_prompt_exitcode)"
  line2+="$(_prompt_duration)"
  line2+="$(_prompt_jobs)"

  echo ""
  if [[ -n "$line2" ]]; then
    echo "${line1}  ${line2}"
  else
    echo "${line1}"
  fi
}

precmd() {
  _PROMPT_LAST_EXIT=$?
  _prompt_timer_stop
  PROMPT='$(_build_prompt)
%F{243}❯%f '
}
