#!/bin/bash

set -o errtrace
set -o nounset
set -o errexit
set -o pipefail
#set -o posix

_myFp=$(readlink -f "${0}")
_myFn=$(basename "${_myFp}")
_args0="${@}"
_version=0.2.0

stderr() {
  echo -e "${1}" >&2
}

yellow() {
  stderr "\e[00;33m${1}\e[00m"
}

red() {
  stderr "\e[00;31m${1}\e[00m"
}

die() {
  red "ERROR: ${1}"
  exit 1
}

is() {
  [ "${1:-}" == "${2:-}" ]
}

is~() {
  [[ "${1:-}" =~ ${2} ]]
}

isz() {
  [ -z "${1:-}" ]
}

isx() {
  ! isz "${1:-}" && [ -x "${1}" ]
}

ise() {
  ! isz "${1:-}" && [ -e "${1}" ]
}

isd() {
  ! isz "${1:-}" && [ -d "${1}" ]
}

isb() {
  local val="${1:-}"
  isz "${val}" || [ "${val}" == "0" ] || [ "${val,,}" == "false" ] && return 1
  return 0
}

clean() {
  yellow "Cleaning"
  isz "${_cleanFps:-}" || rm -rf ${_cleanFps}
  isz "${_tmpDp:-}" || rm -rf ${_tmpDp}
}

initTmp() {
  export _tmpDp=$(mktemp -d)
}

usage() {
  local tag=flexos/py:0.1.0
  stderr ""
  stderr "  ${_myFn} -t <image:tag> -p <plan> [-P [-L]] [-F] [-- <args>]"
  stderr "    -t image:tag = docker image name and tag"
  stderr "    -p plan      = plan's directory or git URI"
  stderr "    -P           = push image to docker-hub"
  stderr "    -L           = add 'latest' tag to docker-hub (needs -P)"
  stderr "    -F           = force actions"
  stderr "    -- <args>    = additional arguments for 'docker build'"
  stderr ""
  stderr "  examples:"
  stderr "    ${_myFn} -t ${tag} -p ./py"
  stderr "    ${_myFn} -t ${tag} -p ./py -P"
  stderr "    ${_myFn} -t ${tag} -p github.com/... -P -L"
  stderr "    ${_myFn} -t ${tag} -p ./py -- --no-cache"
  stderr ""
  stderr "  version: ${_version}"
  stderr ""
  exit 2
}

sourceCfgs() {
  local cfgs="${HOME}/.flexos/deck/build/cfg.sh"
  cfgs="${FLEXOS_CFGS:-} ${DECKBUILD_CFGS:-}"
  local fp=""
  for fp in ${cfgs}; do
    if ! isz ${fp} && ise ${fp}; then
      yellow "Sourcing ${fp}"
      . ${fp} || die "Sourcing ${fp} failed"
    fi
  done
}

isUri() {
  # very dirty: improve me!
  is~ "${1}" ^git || is~ "${1}" ://
}

checkIntegrity() {
  local planDp=${1}
  local dckrFp=${2}
  # check for the following Dockerfile lines:
  #  ADD https://github.com/flexos-io/deck-build/raw/master/kit/kit.tgz ${DECKBUILD_PLANT}/
  #  RUN cd ${DECKBUILD_PLANT} && tar --no-same-owner -zxpf kit.tgz && rm kit.tgz
  #  RUN tar --no-same-owner -zxpf ${DECKBUILD_PLANT}/kit.tgz -C ${DECKBUILD_PLANT} && rm ${DECKBUILD_PLANT}/kit.tgz
  #  COPY .kit ${DECKBUILD_KIT}
  if grep -q -P '^\s*(COPY|ADD)\s+\.kit\s+\${?DECKBUILD_KIT}?\s*$' ${dckrFp}; then
    if grep -q -P '^\s*ADD\s+https://github.com/.+/kit\.tgz\s+\${?DECKBUILD_PLANT}?/(kit\.tgz)?\s*$' ${dckrFp} || \
       grep -q -P '^\s*RUN\s+.+\${?DECKBUILD_PLANT}?.+\s+tar\s+.+\s+kit.tgz(\s+.+)?\s*$' ${dckrFp} || \
       grep -q -P '^\s*RUN\s+(.*\s+)?tar\s+.+\s\${?DECKBUILD_PLANT}?/kit.tgz(\s+.+)?\s*$' ${dckrFp}
    then
      die "Dockerfile wants to COPY and download kit: Don't enable both. See https://github.com/flexos-io/doc/wiki/deck_build#Configuration-Define-The-Kit"
    fi
    isz "${DECKBUILD_KIT_SRC:-}" && \
      die "Dockerfile wants to COPY kit but \${DECKBUILD_KIT_SRC} is not set. See https://github.com/flexos-io/doc/wiki/deck_build#Configuration-Define-The-Kit"
  fi
  if grep -q -P -r --include='*.sh' '^\s*setUser(\s*$|\s*#)' ${planDp} && \
     isz "${DECKBUILD_USER_CFG:-}"
  then
    die "Plan uses kit's setUser() but \${DECKBUILD_USER_CFG} is not set. See https://github.com/flexos-io/doc/wiki/deck_build#Configuration-Abstract-The-Custom-User"
  fi
}

buildPlant() {
  ! isz "${_planArg:-}" || usage
  ! isz "${_imgTagArg:-}" || usage
  trap clean EXIT
  export DECKBUILD_IMG=${_imgTagArg}
  sourceCfgs
  if isUri "${_planArg:-}"; then
    yellow "Plan: ${_planArg}"
    export DECKBUILD_PLAN_URI=1
    export DECKBUILD_PLAN=${_planArg}
    export DECKBUILD_PLANT=/tmp
  else
    local planDp=$(readlink -f ${_planArg})
    isd ${planDp} || die "Opening ${planDp}/ failed"
    dckrFp=${planDp}/Dockerfile
    ise ${dckrFp} || die "Opening ${_dckrFp} failed"
    checkIntegrity ${planDp} ${dckrFp}
    yellow "Plan: ${planDp}"
    if isx ${planDp}/build.sh; then
      export DECKBUILD_TMP_PLANT=true
      yellow "build.sh found: Enabling DECKBUILD_TMP_PLANT"
    fi
    if isb ${DECKBUILD_TMP_PLANT:-false}; then
      initTmp
      yellow "DECKBUILD_TMP_PLANT is enabled: Copying ${planDp}/ to tmp folder"
      local plantDp=${_tmpDp}/plant
      cp -a ${planDp} ${plantDp}
    else
      local plantDp=${planDp}
    fi
    local kitDp=${DECKBUILD_KIT_SRC:-}
    if ! isz "${kitDp}"; then
      isd ${kitDp} || die "Opening ${kitDp}/ failed"
      yellow "Kit: ${kitDp}"
      local plantKitDp=${plantDp}/.kit
      rm -rf ${plantKitDp}
      _cleanFps+=" ${plantKitDp}"
      cp -a ${kitDp} ${plantKitDp}
    fi
    export DECKBUILD_PLAN_URI=0
    export DECKBUILD_PLAN=${planDp}
    export DECKBUILD_PLANT=${plantDp}
  fi
}

buildImg() {
  yellow "Building ${DECKBUILD_IMG}"
  local plantDp=${DECKBUILD_PLANT}
  cd ${plantDp}
  if isb ${DECKBUILD_PLAN_URI}; then
    local target=${DECKBUILD_PLAN}
  else
    local buildShFp=${plantDp}/build.sh
    if isx ${buildShFp}; then
      if isb ${_skipBuildShArg:-}; then
        yellow "Skipping build.sh"
      else
        yellow "Running build.sh"
        ${buildShFp} || die "Running ${buildShFp} failed"
      fi
    fi
    local target=./
  fi
  local dp=/usr/local/flexos/deck/build
  export DECKBUILD_USER_CFG="${DECKBUILD_USER_CFG:-}"
  export DECKBUILD_ARGS="${DECKBUILD_ARGS:-}"
  docker build --tag ${DECKBUILD_IMG} ${_args2} \
      --build-arg DECKBUILD_PLANT=${dp} \
      --build-arg DECKBUILD_KIT=${dp}/kit \
      --build-arg DECKBUILD_USER_CFG=${DECKBUILD_USER_CFG:-} \
      --build-arg DECKBUILD_ARGS="${DECKBUILD_ARGS:-}" \
    ${target} || die "Building failed"
}

pushImg() {
  local imgTag=${DECKBUILD_IMG}
  yellow "Pushing to docker-hub"
  docker login || die "Login to docker-hub failed"
  yellow "Pushing ${imgTag}"
  docker push ${imgTag} || die "Pushing to docker-hub failed"
  if isb "${_latestArg:-}"; then
    imgLatestTag=${imgTag%:*}:latest
    yellow "Pushing ${imgLatestTag}"
    docker tag ${imgTag} ${imgLatestTag}
    docker push ${imgLatestTag} || die "Pushing to docker-hub failed"
  fi
}

init() {
  _forceArg=0
  _pushArg=0
  _latestArg=0
  if is~ "${_args0}" "--"; then
    _args1="${_args0%%--*}"
    _args2="${_args0#*--}"
    yellow "docker_build arguments: ${_args2}"
  else
    _args1="${_args0}"
    _args2=""
  fi
  local arg=""
  while getopts FLPSVp:t: arg ${_args1}; do
    case "${arg}" in
      F) _forceArg=1;;
      L) _latestArg=1;;
      P) _pushArg=1;;
      p) _planArg="${OPTARG}";;
      t) _imgTagArg="${OPTARG}";;
      S) _skipBuildShArg=1;;
      *) usage;;
    esac
  done
  # export values for child processes
  export DECKBUILD_PUSH=${_pushArg}
  export DECKBUILD_PUSH_LATEST=${_latestArg}
  export DECKBUILD_FORCE=${_forceArg}
}

init
buildPlant
buildImg
! isb "${_pushArg:-}" || pushImg
