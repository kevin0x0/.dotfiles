#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

for f in ~/.bashrc.d/*; do
  [ -f "$f" ] || continue
  . "$f"
done
unset f

# my PS1
ps1_exitcode() {
  local exitcode=$?
  if (( exitcode == 0 )); then
    echo ""
  else
    echo " [$exitcode]"
  fi
}

ps1_njob() {
  local njob=$(jobs | wc -l)
  if ((njob == 0)); then
    echo ""
  else
    echo " ($njob)"
  fi
}

osc133a() {
  if [ "$TERM" = foot ]; then
    printf "\033]133;A\033\\"
  fi
}

osc133c() {
  if [ "$TERM" = foot ]; then
    printf "\033]133;C\033\\"
  fi
}

FIRST_PROMPT_PRINTING=1

osc133d() {
  if [ "$TERM" = foot ] && [ ! -v FIRST_PROMPT_PRINTING ]; then
    printf "\033]133;D\033\\"
  fi
  if [ -v FIRST_PROMPT_PRINTING ]; then
    unset FIRST_PROMPT_PRINTING
  fi
}

osc7_cwd() {
  if [ "$TERM" != foot ]; then
    return
  fi

  local strlen=${#PWD}
  local encoded=""
  local pos c o
  for ((pos=0; pos<strlen; pos++)); do
    c=${PWD:$pos:1}
    case "$c" in
      [-/:_.!\'\(\)~[:alnum:]])
        o="$c"
        ;;
      *)
        printf -v o "%%%02X" "'$c"
        ;;
    esac
    encoded+="${o}"
  done
  printf "\033]7;file://%s%s\033\\\\" "$HOSTNAME" "$encoded"
}

PS1='\[\e[1m\e[36m\]\u\[\e[0;1m\]@\[\e[35m\]\h \[\e[33m\]\w\[\e[31m\]$(ps1_exitcode)\[\e[34m\]$(ps1_njob)\[\e[0m\]\n\[\e[1m\]\$\[\e[0m\] '
PS2='\[\e[1m\]>\[\e[0m\] '
PS0='\['$(osc133c | sed 's/\\/\\\\/g')'\]'
PROMPT_COMMAND=("${PROMPT_COMMAND[@]}" 'osc133d' 'osc133a' 'osc7_cwd')
