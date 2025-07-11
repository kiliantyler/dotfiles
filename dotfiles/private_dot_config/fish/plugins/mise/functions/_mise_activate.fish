function _mise_activate --description 'wrap mise activate'
  echo "Activating mise"
  if status is-interactive; and which mise >/dev/null
    mise activate fish | source
    echo "Loaded mise environment"
  else
    echo "mise not found"
  end
  echo "Mise activated2"
end
