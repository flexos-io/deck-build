
initTmp() {
  ##D Create a temporary directory (`mktemp -d`)
  ##D and export the path as `${_DECKBUILD_TMP}`.
  ##D BUT: You don't need to run `initTmp()`
  ##D because a default tmp folder is always available.
  ##E touch ${_DECKBUILD_TMP}/foo.txt          # use default tmp folder
  ##E initTmp; touch ${_DECKBUILD_TMP}/foo.txt # create/use a custom tmp folder
  trap cleanTmp EXIT
  export _DECKBUILD_TMP=$(mktemp -d)
  chmod 777 ${_DECKBUILD_TMP}
}

cleanTmp() {
  ##D Delete the temporary directory created by `initTmp()`.
  ##E cleanTmp              # clean default tmp folder
  ##E initTmp; cleanTmp     # create/clean a custom tmp folder
  isz "${_DECKBUILD_TMP:-}" || rm -rf ${_DECKBUILD_TMP}
}

hasBuildArg() {
  ##C <arg> [<separator>]
  ##D Check if `${DECKBUILD_ARGS}` contains given argument.
  ##A separator = Argument separator (e.g. `,`), default is whitespace
  ##E hasBuildArg -h
  ##E hasBuildArg -A ,
  local arg="${1}"
  local sep="${2:- }"
  is~ "${sep}${DECKBUILD_ARGS:-}${sep}" "${sep}${arg}${sep}"
}

getUserDp() {
  ##C <user>
  ##D Get user's home directory path.
  ##E getUserDp foo
  local user=${1}
  eval echo "~${user}"
}

getUserHome() {
  ##C <user>
  ##D Alias for `getUserDp()`.
  getUserDp ${1}
}

sudoc() {
  ##C <user> <command> [<command_arguments>]
  ##D Run command as given user (`sudo ...`).
  ##E sudoc foo ls
  ##E sudoc foo ls /home/foo
  local args="${*}"
  local user="${args%% *}"
  local cmd="${args#* }" # command with arguments
  isc sudo || die "Command 'sudo' not found"
  sudo HOME=$(getUserDp ${user}) USER=${user} LOGNAME=${user} USERNAME=${user} \
    -n -u ${user} -E -- ${cmd}

sudof() {
  ##C <user> <function> [<function_arguments>]
  ##D Run shell function as given user (`sudo ...`).
  ##E sudof foo myShellFunc
  ##E sudof foo myShellFunc arg1 arg2
  local args="${*}"
  local user="${args%% *}"
  local func="${args#* }" # function with arguments
  isc sudo || die "Command 'sudo' not found"
  sudo HOME=$(getUserDp ${user}) USER=${user} LOGNAME=${user} USERNAME=${user} \
    -n -u ${user} -E bash -c "$(declare -f); unset -f sudof; ${func}"
}

dload() {
  ##C <url> [<destination_file>]
  ##D Download file (`curl https://...`).
  ##E dload https://example.org/foo.txt /tmp/foo.txt # download to file
  ##E fooTxt=$(dload https://example.org/foo.txt)    # assign to fooTxt variable
  local url=${1}
  local fp=${2:-/dev/stdout}
  isc curl || die "Command 'curl' not found"
  curl -sS --fail -L -o ${fp} "${url}" || stderr "Downloading ${url} failed"
}

getGitHubLatest() {
  ##C <repo>
  ##D Get latest software version of a GitHub repository:
  ##D Returns the version and sets `${_DECKBUILD_GITHUB_LATEST}`.
  ##E # for https://api.github.com/repos/foobar/releases/latest:
  ##E getGitHubLatest foobar
  local repo=${1}
  local url="https://api.github.com/repos/${repo}/releases/latest"
  # https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
  local v=$(dload ${url} | grep -Po '"tag_name": "\K.*?(?=")' || :)
  ! isz "${v}" || die "Getting latest ${repo} version failed"
  export _DECKBUILD_GITHUB_LATEST=${v}
  echo "${v}"
}
