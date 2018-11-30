# clear: "basher init" doesn't seem to overwrite existing values
unset $(env | grep -E ^BASHER_ | sed "s@=.*\$@@")

# initialize
export PATH="${HOME}/.basher/bin:${PATH}"
export BASHER_FULL_CLONE=false
eval "$(basher init - bash)"
