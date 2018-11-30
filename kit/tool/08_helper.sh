
cleanTmp() {
  isz "${_FLEXOS_TMP:-}" || rm -rf ${_FLEXOS_TMP}
}

initTmp() {
  trap cleanTmp EXIT
  export _FLEXOS_TMP=$(mktemp -d)
  chmod 777 ${_FLEXOS_TMP}
}

hasBuildArg() {
  local name="${1}"
  local sep="${2:- }"
  is~ "${sep}${FLEXOS_BUILD_ARGS:-}${sep}" "${sep}${name}${sep}"
}

sudoc() {
  local user=${1}
  local cmd="${2}"
  isc sudo || die "Command 'sudo' not found"
  sudo HOME=$(getUserDp ${user}) -n -u ${user} -E -- ${cmd}
}

sudof() {
  local args="${*}"
  local user="${args%% *}"
  local func="${args#* }" # function with arguments
  isc sudo || die "Command 'sudo' not found"
  sudo HOME=$(getUserDp ${user}) USER=${user} LOGNAME=${user} USERNAME=${user} \
    -n -u ${user} -E bash -c "$(declare -f); unset -f sudof; ${func}"
}

getUserDp() {
  local user=${1}
  eval echo "~${user}"
}

dload() {
  local url=${1}
  local fp=${2:-/dev/stdout}
  isc curl || die "Command 'curl' not found"
  curl -sS --fail -L -o ${fp} "${url}" || stderr "Downloading ${url} failed"
}

getGitHubLatest() {
  local repo=${1}
  local url="https://api.github.com/repos/${repo}/releases/latest"
  # https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
  local v=$(dload ${url} | grep -Po '"tag_name": "\K.*?(?=")' || :)
  ! isz "${v}" || die "Getting latest ${repo} version failed"
  export _FLEXOS_GITHUB_LATEST=${v}
}
