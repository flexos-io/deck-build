#!/bin/bash

set -o errtrace
set -o nounset
set -o errexit
set -o pipefail
#set -o posix

_myFp=$(readlink -f "${0}")
_myFn=$(basename "${_myFp}")
_args0="${@}"
_version=0.1.0

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
  isz "${_tmpDp:-}" || rm -rf ${_tmpDp}
}

initTmp() {
  trap clean EXIT
  export _tmpDp=$(mktemp -d)
}

usage() {
  local tag=flexos/py3:0.1.0
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
  stderr "    ${_myFn} -t ${tag} -p py3_0.1.0"
  stderr "    ${_myFn} -t ${tag} -p ./py3 -P"
  stderr "    ${_myFn} -t ${tag} -p github.com/... -P -L"
  stderr "    ${_myFn} -t ${tag} -p ./py3 -- --no-cache"
  stderr ""
  stderr "  version: ${_version}"
  stderr ""
  exit 2
}

sourceCfgs() {
  local cfgs="${HOME}/.flexos/deck/build/cfg.sh"
  # support alias $FLEXOS_BUILD_CFGS
  cfgs="${FLEXOS_CFGS:-} ${FLEXOS_DECK_BUILD_CFGS:-${FLEXOS_BUILD_CFGS:-}}"
  local fp=""
  for fp in ${cfgs}; do
    if ! isz ${fp} && ise ${fp}; then
      yellow "Sourcing ${fp}"
      . ${fp} || die "Sourcing ${fp} failed"
    fi
  done
}

isUri() {
  # dirty: improve me!
  is~ "${1}" ^git || is~ "${1}" ://
}

buildPlant() {
  ! isz "${_planArg:-}" || usage
  ! isz "${_imgTagArg:-}" || usage
  export FLEXOS_IMG=${_imgTagArg}
  sourceCfgs
  if isUri "${_planArg:-}"; then
    yellow "Plan: ${_planArg}"
    export FLEXOS_DECK_BUILD_PLAN_URI=1
    export FLEXOS_DECK_BUILD_PLAN=${_planArg}
    export FLEXOS_DECK_BUILD_PLANT=/tmp
  else
    local planDp=$(readlink -f ${_planArg})
    isd ${planDp} || die "Opening ${planDp}/ failed"
    yellow "Plan: ${planDp}"
    initTmp
    local plantDp=${_tmpDp}/plant
    cp -a ${planDp} ${plantDp}
    local kitDp=${FLEXOS_DECK_BUILD_KIT:-${FLEXOS_BUILD_KIT:-}} # support alias
    if ! isz "${kitDp}"; then
      isd ${kitDp} || die "Opening ${kitDp}/ failed"
      yellow "Kit: ${kitDp}"
      cp -a ${kitDp} ${plantDp}/kit
    fi
    export FLEXOS_DECK_BUILD_PLAN_URI=0
    export FLEXOS_DECK_BUILD_PLAN=${planDp}
    export FLEXOS_DECK_BUILD_PLANT=${plantDp}
  fi
}

buildImg() {
  yellow "Building ${FLEXOS_IMG}"
  local plantDp=${FLEXOS_DECK_BUILD_PLANT}
  cd ${plantDp}
  if isb ${FLEXOS_DECK_BUILD_PLAN_URI}; then
    local target=${FLEXOS_DECK_BUILD_PLAN}
  else
    if isx ${plantDp}/build.sh; then
      if isb ${_skipBuildShArg:-}; then
        yellow "Skipping build.sh"
      else
        yellow "Running build.sh"
        ${plantDp}/build.sh || die "Running ${plantDp}/build.sh failed"
      fi
    fi
    local target=./
  fi
  local dp=/usr/local/flexos/deck/build
  # support aliases
  FLEXOS_DECK_BUILD_USER="${FLEXOS_DECK_BUILD_USER:-${FLEXOS_BUILD_USER:-}}"
  export FLEXOS_DECK_BUILD_USER
  FLEXOS_DECK_BUILD_ARGS="${FLEXOS_DECK_BUILD_ARGS:-${FLEXOS_BUILD_ARGS:-}}"
  export FLEXOS_DECK_BUILD_ARGS
  docker build --tag ${FLEXOS_IMG} ${_args2} \
      --build-arg FLEXOS_PLANT=${dp} \
      --build-arg FLEXOS_KIT_TOOL=${dp}/kit/tool \
      --build-arg FLEXOS_BUILD_USER=${FLEXOS_DECK_BUILD_USER:-} \
      --build-arg FLEXOS_BUILD_ARGS="${FLEXOS_DECK_BUILD_ARGS:-}" \
    ${target} || die "Building failed"
  # --build-arg FLEXOS_IMG=${FLEXOS_IMG}
  # --build-arg FLEXOS_PLAN=${FLEXOS_DECK_BUILD_PLAN}
  # --build-arg FLEXOS_KIT=${dp}/kit
  # --build-arg FLEXOS_KIT_STOCK=${dp}/kit/stock
  # --build-arg FLEXOS_BUILD_VERSION=${_version}
}

pushImg() {
  local imgTag=${FLEXOS_IMG}
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
  export FLEXOS_DECK_BUILD_PUSH=${_pushArg}
  export FLEXOS_DECK_BUILD_PUSH_LATEST=${_latestArg}
  export FLEXOS_DECK_BUILD_FORCE=${_forceArg}
}

init
buildPlant
buildImg
! isb "${_pushArg:-}" || pushImg
