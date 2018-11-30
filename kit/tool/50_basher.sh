
clearBasher() {
  unset $(env | grep -E ^BASHER_ | sed "s@=.*\$@@")
}

installBasher() {
  local dp=${HOME}/.basher
  if isd ${dp}; then
    . ${HOME}/.bash.d/50_basher.sh
  else
    yellow "Installing basher environment"
    export BASHER_FULL_CLONE=false
    cd $(dirname ${dp})
    git clone https://github.com/basherpm/basher.git $(basename ${dp}) || \
      die "Getting basher failed"
    addToBashd ${FLEXOS_KIT_STOCK}/basher/50_basher.sh
  fi
}

installBasherPkg() {
  local uri=${1}
  installBasher
  yellow "Installing basher package: ${uri}"
  basher install ${uri} || die "Installing ${uri} basher package failed"
}
