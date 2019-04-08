
setUser() {
  ##D Configure user environment:
  ##D Reads `${DECKBUILD_USER_CFG}` and sets related environment variables
  ##D (e.g. `${DECKBUILD_USER}` and `${DECKBUILD_USER_ID}`).
  local userCfg="${DECKBUILD_USER_CFG:-}" # user:uid:sudoYesNo[:home:group:gid]
  local userColons=${userCfg//[^:]}
  local emsg="\$DECKBUILD_USER_CFG is invalid"
  if is ${#userColons} 2 || is ${#userColons} 5; then
    export DECKBUILD_USER=$(echo ${userCfg} | cut -d: -f1)
    ! isz "${DECKBUILD_USER:-}" || die "${emsg}: User-name is invalid"
    export DECKBUILD_USER_ID=$(echo ${userCfg} | cut -d: -f2)
    isn "${DECKBUILD_USER_ID:-}" || die "${emsg}: User-ID is invalid"
    export DECKBUILD_USER_SUDO=$(echo ${userCfg} | cut -d: -f3)
    is "${DECKBUILD_USER_SUDO:-}" 0 || is "${DECKBUILD_USER_SUDO:-}" 1 || \
      die "${emsg}: User-sudo is invalid"
    if is ${#userColons} 5; then
      export DECKBUILD_USER_HOME=$(echo ${userCfg} | cut -d: -f4)
      ! isz "${DECKBUILD_USER_HOME:-}" || die "${emsg}: User-home is invalid"
      export DECKBUILD_GROUP=$(echo ${userCfg} | cut -d: -f5)
      ! isz "${DECKBUILD_GROUP:-}" || die "${emsg}: Group-name is invalid"
      export DECKBUILD_GROUP_ID=$(echo ${userCfg} | cut -d: -f6)
      isn "${DECKBUILD_GROUP_ID:-}" || die "${emsg}: Group-ID is invalid"
    fi
  else
    die "${emsg}"
  fi
}

installUser() {
  ##C user user_id [user_home] [group] [group_id] [user_args] [group_args]
  ##D Create a user (and group).
  ##A user = User name
  ##A user_id = User ID
  ##A user_home = Path to user's home directory
  ##A group = Group name
  ##A group_id = Group ID
  ##A user_args = Additional arguments for `useradd` command
  ##A group_args = Additional arguments for `groupadd` command
  ##E installUser foo 1001
  ##E installUser foo 1001 /home/user/foo
  ##E installUser foo 1001 /home/foo bar 2002
  ##E installUser foo 1001 /home/foo bar 2002 "-M" "-p myEncrPw"
  local user=${1}
  local uid=${2}
  local userDp=${3:-/home/${user}}
  local grp=${4:-${user}}
  local gid=${5:-${uid}}
  local userArgs="${6:-}"
  local grpArgs="${7:-}"
  ! isz "${user:-}" || \
    die "User is not set: Do you forget to set \$DECKBUILD_USER_CFG?"
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
  ##C <user> [<sudo_args>]
  ##D Enable sudo for given user.
  ##A sudo_args = `sudo` arguments, default are: `ALL=(ALL) NOPASSWD:ALL`
  ##E installSudoUser foo
  ##E setUser; installSudoUser ${DECKBUILD_USER}
  local user=${1}
  local args="${2:-ALL=(ALL) NOPASSWD:ALL}"
  local dp=/etc/sudoers.d
  ! isz "${user:-}" || \
    die "User is not set: Do you forget to set \$DECKBUILD_USER_CFG?"
  isd ${dp} || die "Opening ${dp}/ failed: Is 'sudo' installed?"
  yellow "Enabling sudo for ${user}"
  echo "${user} ${args}" > ${dp}/${user}
  chmod 440 ${dp}/${user}
}

installBashd() {
  ##C [<directory_path>]
  ##D Initialize `bash.d` environment:
  ##D bash.d folders store bash profile files.
  ##D Profile files will be read (sourced) during container startup.
  ##D BUT: Don't call this function directly, use `addToBashd()` instead.
  ##A directory_path = `bash.d` parent folder, default is user's `${HOME}`
  ##E installBashd            # creates /root/.bash.d
  ##E sudof foo installBashd  # creates /home/foo/.bash.d
  ##E installBashd /etc       # creates /etc/bash.d
  local dp="${1:-}"
  if isz "${dp}"; then
    export _DECKBUILD_BASHD=${HOME}/.bash.d
    local cmdDp="\${HOME}/.bash.d"
    local fp=${HOME}/.bashrc
  else
    export _DECKBUILD_BASHD=${dp}/bash.d
    local cmdDp=${_DECKBUILD_BASHD}
    local fp=/etc/bash.bashrc
  fi
  mkdir -p ${_DECKBUILD_BASHD}
  local cmd="for _fp in ${cmdDp}/*.sh; do . \${_fp}; done; unset _fp"
  if ! grep -F -q "${cmd}" ${fp} 2>/dev/null; then
    yellow "Adding bash.d sourcing to ${fp}"
    echo -e "\n# deck-build\n${cmd}\n" >> ${fp} || \
      die "Adding bash.d sourcing to ${fp} failed"
  fi
}

addToBashd() {
  ##C <file_path> [<directory_path>]
  ##D Add and read (source) a `bash.d` profile file
  ##D (see `installBashd()` for `bash.d` details).
  ##A file_path = Path to profile file
  ##A directory_path = `bash.d` parent folder, see `installBashd()` for details
  ##E addToBashd /tmp/bar            # creates /root/.bash.d/bar
  ##E addToBashd /tmp/bar /etc       # creates /etc/bash.d/bar
  ##E sudof foo addToBashd /tmp/bar  # creates /home/foo/.bash.d/bar
  ##E sudof foo addToBashd ${DECKBUILD_KIT_STOCK}/python/55_python.sh
  local srcFp="${1}"
  installBashd "${2:-}"
  local dstFp=${_DECKBUILD_BASHD}/$(basename ${srcFp})
  yellow "Installing ${dstFp}"
  cp -a ${srcFp} ${dstFp} || \
    die "Adding ${srcFp} to ${_DECKBUILD_BASHD}/ failed"
  yellow "Sourcing ${dstFp}"
  . ${dstFp} || die "Sourcing ${dstFp} failed"
}

sourceBashdFile() {
  ##C <file_name> [<directory_path>]
  ##D Read (source) a `bash.d` profile file
  ##D (see `installBashd()` for `bash.d` details).
  ##A file_name = Profile file name
  ##A directory_path = `bash.d` parent folder, see `installBashd()` for details
  ##E sourceBashdFile bar            # sources /root/.bash.d/bar
  ##E sourceBashdFile bar /etc       # sources /etc/bash.d/bar
  ##E sudof foo sourceBashdFile bar  # sources /home/foo/.bash.d/bar
  local fn="${1}"
  local dp="${2:-}"
  if isz "${dp}"; then
    dp=${HOME}/.bash.d
  else
    dp=${dp}/bash.d
  fi
  local fp=${dp}/${fn}
  yellow "Sourcing ${fp}"
  . ${fp} || die "Sourcing ${fp} failed"
}

sourceBashdFiles() {
  ##C [<directory_path>]
  ##D Read (source) all `bash.d` profile files
  ##D (see `installBashd()` for `bash.d` details).
  ##A directory_path = `bash.d` parent folder, see `installBashd()` for details
  ##E sourceBashdFiles               # sources /root/.bash.d/*
  ##E sourceBashdFiles bar /etc      # sources /etc/bash.d/*
  ##E sudof foo sourceBashdFile bar  # sources /home/foo/.bash.d/*
  local dp="${1:-}"
  if isz "${dp}"; then
    dp=${HOME}/.bash.d
  else
    dp=${dp}/bash.d
  fi
  yellow "Sourcing ${dp}/"
  local fp=""
  for fp in ${dp}/*.sh; do
    . ${fp} || die "Sourcing ${fp} failed"
  done
}

installDirs() {
  ##D Simplify system's directory structure
  ##D (e.g. merge `/usr/local/bin` and `/usr/local/sbin`).
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
