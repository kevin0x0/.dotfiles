#
# ~/.bash_profile
#

export PATH="$HOME/.local/bin:$PATH"

for f in ~/.bash_profile.d/*; do
  [ -f "$f" ] || continue
  . "$f"
done

unset f

[[ -f ~/.bashrc ]] && . ~/.bashrc
