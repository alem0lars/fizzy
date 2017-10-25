local root="${autoenv_env_file:h}"

#
# Delete path by parts so we can never accidentally remove sub paths.
#
function path_remove {
  export PATH=${PATH//":$1:"/":"} # Delete any instances in the middle.
  export PATH=${PATH/#"$1:"/}     # Delete any instance at the beginning.
  export PATH=${PATH/%":$1"/}     # Delete any instance in the at the end.
}

path_remove "${root}/.binstub"

unfunction path_remove
