
initTmp() {
  ##D Create a temporary directory (`mktemp -d`)
  ##D and export the path as `${DECKBUILD_TMP}`.
  ##D BUT: You don't need to run `initTmp()`
  ##D because a default tmp folder is always available.
  ##E touch ${DECKBUILD_TMP}/foo.txt          # use default tmp folder
  ##E initTmp; touch ${DECKBUILD_TMP}/foo.txt # create/use a custom tmp folder
  trap cleanTmp EXIT
  export DECKBUILD_TMP=$(mktemp -d)
  chmod 777 ${DECKBUILD_TMP}
}

cleanTmp() {
  ##D Delete the temporary directory created by `initTmp()`.
  ##E cleanTmp              # clean default tmp folder
  ##E initTmp; cleanTmp     # create and clean a custom tmp folder
  isz "${DECKBUILD_TMP:-}" || rm -rf ${DECKBUILD_TMP}
}

hasArg() {
  ##C <argument> [<arguments>]
  ##D Check if arguments contain the given argument.
  ##A arguments = All arguments, default is `${MY_ARGS}`
  ##E hasArg -h "-h --foo"
  ##E hasArg --foo "-h --foo=bar"
  ##E hasArg -A
  local arg="${1}"
  local args="${2:-${MY_ARGS}}"
  is~ " ${args} " " ${arg} " || is~ " ${args}" " ${arg}="
}

getArg() {
  ##C <key-value_argument> [<arguments>]
  ##D Get value of given key-value argument.
  ##A arguments = All arguments, default is `${MY_ARGS}`
  ##E getArg --foo "-h --foo=bar"              # returns "bar"
  ##E getArg --foo "-h --foo=bar1 --foo=bar2"  # returns "bar2"
  ##E getArg --foo -h                          # returns ""
  local arg="${1}"
  local args="${2:-${MY_ARGS}}"
  for val in ${args}; do
    is " ${val} " " -- " && break
    if is~ " ${val}" " ${arg}="; then
      local argVal=${val#*=}
    fi
  done
  echo ${argVal:-}
}

hasBuildArg() {
  ##C <argument>
  ##D Check if `${DECKBUILD_ARGS}` contains the given argument.
  ##E hasBuildArg -e
  local arg="${1}"
  hasArg "${arg}" "${DECKBUILD_ARGS:-}"
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
}

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
  ##D Download file (`curl https://...`). Set `${DECKBUILD_CACHE}` to cache
  ##D (and reuse) downloaded files in given directory.
  ##E dload https://example.org /tmp/index.html    # download to file
  ##E txt=$(dload https://example.org/foo.txt)     # assign to "txt" variable
  ##E export DECKBUILD_CACHE=~/cache; dload https://example.org ./index.html
  ##E export DECKBUILD_CACHE=~/cache; dload ...    # cache read-only mode
  ##E export DECKBUILD_CACHE=~/cache:ro; dload ... # cache read-only mode
  ##E export DECKBUILD_CACHE=~/cache:rw; dload ... # cache read-write mode
  local url=${1}
  local fp=${2:-/dev/stderr}
  local curlArgs="-sS --fail -L -o ${fp}"
  local msg="Downloading ${url} to ${fp}"
  isc curl || die "Command 'curl' not found"
  if isz "${DECKBUILD_CACHE:-}" || is~ ${fp} ^/dev/; then
    yellow "${msg}"
    curl ${curlArgs} "${url}" || die "${msg} failed"
  else
    if is~ ${DECKBUILD_CACHE} ":"; then
      local cacheDp=${DECKBUILD_CACHE%:*}
      local cacheMode=${DECKBUILD_CACHE##*:}
    else
      local cacheDp=${DECKBUILD_CACHE}
      local cacheMode=ro
    fi
    local cacheFp=${cacheDp}/$(basename ${fp})
    if ise ${cacheFp}; then
      yellow "Getting $(basename ${fp}) from download cache ${cacheDp}/"
      cp ${cacheFp} ${fp}
    else
      yellow "${msg}"
      curl ${curlArgs} "${url}" || die "${msg} failed"
      if is ${cacheMode} rw; then
        msg="Adding $(basename ${fp}) to download cache ${cacheDp}/"
        yellow "${msg}"
        mkdir -p $(dirname ${cacheFp}) || die "${msg} failed"
        cp ${fp} ${cacheFp} || die "${msg} failed"
      fi
    fi
  fi
}

getGitHubLatest() {
  ##C <repo>
  ##D Get latest software version of a GitHub repository:
  ##D Returns the version and sets `${DECKBUILD_GITHUB_LATEST}`.
  ##E # for https://api.github.com/repos/foobar/releases/latest:
  ##E getGitHubLatest foobar
  local repo=${1}
  local url="https://api.github.com/repos/${repo}/releases/latest"
  # https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
  local v=$(dload ${url} | grep -Po '"tag_name": "\K.*?(?=")' || :)
  ! isz "${v}" || die "Getting latest ${repo} version failed"
  export DECKBUILD_GITHUB_LATEST=${v}
  echo "${v}"
}

addMetaFile() {
  ##C <destination_directory> [<data_file>]
  ##D Create a metafile that contains informations like the OS version"
  ##A destination_directory = Destination directory for metafile
  ##A data_file = Append content (`key=value` format) from this file to metafile
  local dstDp=${1}/.deck-build
  local dataFp="${2:-}"
  local dstFp=${dstDp}/meta.$(date +"%Y%m%d_%H%M%S").cfg
  yellow "Creating ${dstFp}"
  isd ${dstDp} || mkdir -p ${dstDp}
  touch ${dstFp}
  ! isc uname || echo "OS=\"$(uname -a)\"" >> ${dstFp}
  ! ise /etc/lsb-release || cat /etc/lsb-release >> ${dstFp}
  echo "DATE=$(date --utc --iso-8601=seconds)" >> ${dstFp}
  echo "DECKBUILD_CMD=\"${MY_FN} $(echo ${MY_ARGS})\"" >> ${dstFp}
  isz "${DECKBUILD_RELEASE:-}" || \
    echo "DECKBUILD_RELEASE=\"${DECKBUILD_RELEASE}\"" >> ${dstFp}
  echo "DIRECTORY=\"$(dirname ${dstDp})\"" >> ${dstFp}
  if ! isz "${dataFp}" && ise ${dataFp}; then
    cat ${dataFp} >> ${dstFp}
  fi
}

isBuild() {
  ##D Check if this is the building stage.
  ##E isBuild && echo "Yes: Building stage" || echo "No: Not building stage"
  ##E export DECKBUILD_STAGE=build; if isBuild; then ...      # returns true
  ##E export DECKBUILD_STAGE=BUILD; if isBuild; then ...      # returns true
  ##E export DECKBUILD_STAGE=dev; if isBuild; then ...        # returns false
  is ${DECKBUILD_STAGE,,} build
}

isDev() {
  ##D Check if this is the development stage.
  ##E isDev && echo "Yes: Development stage" || echo "No: Not development stage"
  ##E export DECKBUILD_STAGE=dev; if isDev; then ...          # returns true
  ##E export DECKBUILD_STAGE=development; if isDev; then ...  # returns true
  ##E export DECKBUILD_STAGE=DEV; if isDev; then ...          # returns true
  ##E export DECKBUILD_STAGE=DEVELOPMENT; if isDev; then ...  # returns true
  ##E export DECKBUILD_STAGE=prod; if isDev; then ...         # returns false
  is ${DECKBUILD_STAGE,,} dev || is ${DECKBUILD_STAGE,,} development
}

isTest() {
  ##D Check if this is the test stage.
  ##E isTest && echo "Yes: test stage" || echo "No: Not test stage"
  ##E export DECKBUILD_STAGE=test; if isTest; then ...  # returns true
  ##E export DECKBUILD_STAGE=TEST; if isTest; then ...  # returns true
  ##E export DECKBUILD_STAGE=prod; if isTest; then ...  # returns false
  is ${DECKBUILD_STAGE,,} test
}

isTrial() {
  ##D Check if this is the trial stage.
  ##E isTrial && echo "Yes: trial stage" || echo "No: Not trial stage"
  ##E export DECKBUILD_STAGE=trial; if isTrial; then ...  # returns true
  ##E export DECKBUILD_STAGE=TRIAL; if isTrial; then ...  # returns true
  ##E export DECKBUILD_STAGE=prod; if isTrial; then ...   # returns false
  is ${DECKBUILD_STAGE,,} trial ]
}

isProd() {
  ##D Check if this is the production stage.
  ##E isProd && echo "Yes: Production stage" || echo "No: Not production stage"
  ##E export DECKBUILD_STAGE=prod; if isProd; then ...        # returns true
  ##E export DECKBUILD_STAGE=production; if isProd; then ...  # returns true
  ##E export DECKBUILD_STAGE=PROD; if isProd; then ...        # returns true
  ##E export DECKBUILD_STAGE=PRODUCTION; if isProd; then ...  # returns true
  ##E export DECKBUILD_STAGE=dev; if isProd; then ...         # returns false
  is ${DECKBUILD_STAGE,,} prod || is ${DECKBUILD_STAGE,,} production
}

lnDir() {
  ##C <source_directory> <destination_directory>
  ##D Move source data to destination folder and replace source directory by
  ##D link to destination.
  local srcDp=${1}
  local dstDp=${2}
  isd ${dstDp} || mkdir -p ${dstDp}
  if isd ${srcDp}; then
    isc rsync || die "rsync not found"
    rsync -aH ${srcDp}/ ${dstDp}/
    rm -r ${srcDp}
  else
    isd ${srcDp%/*} || mkdir -p ${srcDp%/*}
  fi
  yellow "Linking ${srcDp}/ to ${dstDp}/"
  ln -s ${dstDp} ${srcDp}
}
