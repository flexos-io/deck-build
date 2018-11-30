
setUser() {
  # e.g. FLEXOS_BUILD_USER=root:0:0:/root:root:0
  local userCfg="${FLEXOS_BUILD_USER:-}" # user:uid:sudo:home:group:gid
  local userColons=${userCfg//[^:]}
  local emsg="\$FLEXOS_BUILD_USER is invalid"
  if is ${#userColons} 2 || is ${#userColons} 5; then
    export FLEXOS_USER=$(echo ${userCfg} | cut -d: -f1)
    ! isz "${FLEXOS_USER:-}" || die "${emsg}: User-name is invalid"
    export FLEXOS_USER_ID=$(echo ${userCfg} | cut -d: -f2)
    isn "${FLEXOS_USER_ID:-}" || die "${emsg}: User-ID is invalid"
    export FLEXOS_USER_SUDO=$(echo ${userCfg} | cut -d: -f3)
    is "${FLEXOS_USER_SUDO:-}" 0 || is "${FLEXOS_USER_SUDO:-}" 1 || \
      die "${emsg}: User-sudo is invalid"
    if is ${#userColons} 5; then
      export FLEXOS_USER_HOME=$(echo ${userCfg} | cut -d: -f4)
      ! isz "${FLEXOS_USER_HOME:-}" || die "${emsg}: User-home is invalid"
      export FLEXOS_GROUP=$(echo ${userCfg} | cut -d: -f5)
      ! isz "${FLEXOS_GROUP:-}" || die "${emsg}: Group-name is invalid"
      export FLEXOS_GROUP_ID=$(echo ${userCfg} | cut -d: -f6)
      isn "${FLEXOS_GROUP_ID:-}" || die "${emsg}: Group-ID is invalid"
    fi
  else
    die "${emsg}"
  fi
}

installUser() {
  local user=${1}
  local uid=${2}
  local userDp=${3:-/home/${user}}
  local grp=${4:-${user}}
  local gid=${5:-${uid}}
  local userArgs="${6:-}"
  local grpArgs="${7:-}"
  if getent group ${grp} >/dev/null; then
    yellow "Skipping creating group ${grp}: Already exists"
  else
    isc groupadd || die "Command 'groupadd' not found"
    yellow "Creating group ${grp}"
    groupadd -g ${gid} ${grp} ${grpArgs}
  fi
  if getent passwd ${user} >/dev/null; then
    yellow "Skipping creating user ${user}: Already exists"
  else
    isc useradd || die "Command 'useradd' not found"
    yellow "Creating user ${user}"
    useradd -m -s /bin/bash -d ${userDp} -g ${grp} -u ${uid} ${user} ${userArgs}
  fi
  yellow "Configuring ${user}'s home environment"
  mkdir -p -m 700 ${userDp}/.ssh ${userDp}/.config
  touch ${userDp}/.ssh/authorized_keys
  chmod 600 ${userDp}/.ssh/authorized_keys
  chown -Rh ${user}:${grp} ${userDp}/.ssh ${userDp}/.config
}

installSudoUser() {
  local user=${1}
  local params="${2:-ALL=(ALL) NOPASSWD:ALL}"
  local dp=/etc/sudoers.d
  isd ${dp} || die "Opening ${dp}/ failed: Is 'sudo' installed?"
  yellow "Enabling sudo for ${user}"
  echo "${user} ${params}" > ${dp}/${user}
  chmod 440 ${dp}/${user}
}

installBashd() {
  local dp="${1:-}"
  if isz "${dp}"; then
    export _FLEXOS_BASHD=${HOME}/.bash.d
    local cmdDp="\${HOME}/.bash.d"
    local fp=${HOME}/.bashrc
  else
    export _FLEXOS_BASHD=${dp}/bash.d
    local cmdDp=${_FLEXOS_BASHD}
    local fp=/etc/bash.bashrc
  fi
  mkdir -p ${_FLEXOS_BASHD}
  local cmd="for _fp in ${cmdDp}/*.sh; do . \${_fp}; done; unset _fp"
  if ! grep -F -q "${cmd}" ${fp} 2>/dev/null; then
    yellow "Adding bash.d sourcing to ${fp}"
    echo -e "\n# flexos\n${cmd}\n" >> ${fp} || \
      die "Adding bash.d sourcing to ${fp} failed"
  fi
}

addToBashd() {
  local srcFp="${1}"
  installBashd "${2:-}"
  local dstFp=${_FLEXOS_BASHD}/$(basename ${srcFp})
  yellow "Installing ${dstFp}"
  cp -a ${srcFp} ${dstFp} || die "Adding ${srcFp} to ${_FLEXOS_BASHD}/ failed"
  yellow "Sourcing ${dstFp}"
  . ${dstFp} || die "Sourcing ${dstFp} failed"
}

installDirs() {
  yellow "Optimizing /usr/local/ and /opt/"
  mkdir -p -m 755 /usr/local/bin /usr/local/src
  mv /opt/bin/* /usr/local/bin/ 2>/dev/null || :
  mv /opt/sbin/* /usr/local/bin/ 2>/dev/null || :
  mv /opt/src/* /usr/local/src/ 2>/dev/null || :
  mv /usr/local/sbin/* /usr/local/bin/ 2>/dev/null || :
  rm -rf /opt/bin /opt/sbin /opt/src /usr/local/sbin
  ln -s /usr/local/bin /opt/bin
  ln -s /usr/local/bin /opt/sbin
  ln -s /usr/local/src /opt/src
  ln -s /usr/local/bin /usr/local/sbin
}
