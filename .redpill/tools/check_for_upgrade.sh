#!/bin/sh

_current_epoch()
{
  echo $(($(date +%s) / 60 / 60 / 24))
}

_update_zsh_update()
{
  echo "LAST_EPOCH=$(_current_epoch)" >! ~/.zsh-update
}

_upgrade_zsh()
{
  env ZSH=$ZSH sh $ZSH/tools/upgrade.sh
  # update the zsh file
  _update_zsh_update
}

epoch_target=$UPDATE_ZSH_DAYS
if [[ -z "$epoch_target" ]]; then
  # Default to old behavior
  epoch_target=13
fi

# Cancel upgrade if the current user doesn't have write permissions for the
# red-pill directory.
[[ -w "$ZSH" ]] || return 0

if [ -f ~/.zsh-update ]; then
  . ~/.zsh-update

  if [[ -z "$LAST_EPOCH" ]]; then
    _update_zsh_update && return 0;
  fi

  epoch_diff=$(($(_current_epoch) - $LAST_EPOCH))
  if [ $epoch_diff -gt $epoch_target ]; then
    if [ "$DISABLE_UPDATE_PROMPT" = "true" ]; then
      _upgrade_zsh
    else

      echo "Would you like to check for updates?"
      echo "Type Y to update red-pill: \c"
      read line

      if [ "$line" = Y ] || [ "$line" = y ]; then
        _upgrade_zsh
      else
        _update_zsh_update
      fi

    fi
  fi
else
  # create the zsh file
  _update_zsh_update
fi

