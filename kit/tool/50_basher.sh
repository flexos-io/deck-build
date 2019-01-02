
clearBasher() {
  ##D Clear basher environment ("unset BASHER_*").
  unset $(env | grep -E ^BASHER_ | sed "s@=.*\$@@")
}

installBasher() {
  ##D Install basher (https://github.com/basherpm/basher) environment
  ##D (for specific user).
  ##D BUT: Don't call this function directly, use installBasherPkg() instead.
  ##E installBasher            # install basher for root
  ##E sudof foo installBasher  # install basher for user foo
  local dp=${HOME}/.basher
  if isd ${dp}; then
    . ${HOME}/.bash.d/50_basher.sh
  else
    yellow "Installing basher environment"
    export BASHER_FULL_CLONE=false
    cd $(dirname ${dp})
    git clone https://github.com/basherpm/basher.git $(basename ${dp}) || \
      die "Getting basher failed"
    addToBashd ${DECKBUILD_KIT_STOCK}/basher/50_basher.sh
  fi
}

installBasherPkg() {
  ##D Install a basher package (see installBasher() for basher details).
  ##E installBasherPkg bar            # install bar package for root
  ##E sudof foo installBasherPkg bar  # install bar package for user foo
  local uri=${1}
  installBasher
  yellow "Installing basher package: ${uri}"
  basher install ${uri} || die "Installing ${uri} basher package failed"
}
