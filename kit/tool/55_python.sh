
installPy() {
  export _FLEXOS_PYTHON_REQS=${HOME}/.config/python/requirements
  if isd ${_FLEXOS_PYTHON_REQS}; then
    . ${HOME}/.bash.d/55_python.sh
  else
    yellow "Installing python environment"
    local pipDp=${HOME}/.config/pip
    mkdir -p ${pipDp} ${_FLEXOS_PYTHON_REQS}
    yellow "Installing ${pipDp}/pip.conf"
    cp -a ${FLEXOS_KIT_STOCK}/python/pip.conf ${pipDp}
    addToBashd ${FLEXOS_KIT_STOCK}/python/55_python.sh
  fi
}

installPyPkgs() {
  local srcFp=${1}
  installPy
  local dstFp=${_FLEXOS_PYTHON_REQS}/$(basename ${srcFp})
  yellow "Installing python packages: ${dstFp}"
  cp -a ${srcFp} ${dstFp} || die "Installing ${srcFp} failed"
  pip install -r ${dstFp} || \
    die "Installing ${dstFp} pip packages failed"
}
