
installPy() {
  ##D Install python environment (for specific user).
  ##D BUT: Don't call this function directly, use installPyPkgs() instead.
  ##E installPy             # creates /root/.config/pip/pip.conf
  ##E sudof foo installPy   # creates /home/foo/.config/pip/pip.conf
  export _DECKBUILD_PYTHON_REQS=${HOME}/.config/python/requirements
  if isd ${_DECKBUILD_PYTHON_REQS}; then
    . ${HOME}/.bash.d/55_python.sh
  else
    yellow "Installing python environment"
    local pipDp=${HOME}/.config/pip
    mkdir -p ${pipDp} ${_DECKBUILD_PYTHON_REQS}
    yellow "Installing ${pipDp}/pip.conf"
    cp -a ${DECKBUILD_KIT_STOCK}/python/pip.conf ${pipDp}
    addToBashd ${DECKBUILD_KIT_STOCK}/python/55_python.sh
  fi
}

installPyPkgs() {
  ##C <requirements_file>
  ##D Install python packages (for specific user)
  ##D of given pip-requirements file.
  ##E installPyPkgs /tmp/root_reqs           # install packages for root 
  ##E sudof foo installPyPkgs /tmp/foo_reqs  # install packages for user foo
  local srcFp=${1}
  installPy
  local dstFp=${_DECKBUILD_PYTHON_REQS}/$(basename ${srcFp})
  yellow "Installing python packages: ${dstFp}"
  cp -a ${srcFp} ${dstFp} || die "Installing ${srcFp} failed"
  pip install -r ${dstFp} || \
    die "Installing ${dstFp} pip packages failed"
  cd ${HOME}/.local/lib
  ln -sf $(basename $(ls -d python*/ | tail -n1)) python
}
