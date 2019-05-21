#!/bin/bash -e

MY_FP=$(readlink -f "${0}")
MY_FN=$(basename "${MY_FP}")
MY_ARGS="${*}"
MY_VERSION=0.2.0

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
  isz "${CLEAN_FPS:-}" || rm -rf ${CLEAN_FPS}
  isz "${TMP_DP:-}" || rm -rf ${TMP_DP}
}

initTmp() {
  export TMP_DP=$(mktemp -d)
}

usage() {
  local tag=flexos/py:0.1.0
  stderr ""
  stderr "  ${MY_FN} -t <image:tag> -p <plan> [-P [-L]] [-F] [-- <args>]"
  stderr "    -t <image:tag> = Docker image name and tag"
  stderr "    -p <plan>      = Plan's directory or git URI"
  stderr "    -P             = Push image to docker-hub"
  stderr "    -L             = Add 'latest' tag to docker-hub (needs -P)"
  stderr "    -F             = Force actions"
  stderr "    -s <stage>     = Build stage: Use Dockerfile.<stage> as input"
  stderr "    -- <args>      = Additional arguments for 'docker build'"
  stderr ""
  stderr "  Examples:"
  stderr "    ${MY_FN} -t ${tag} -p ./py"
  stderr "    ${MY_FN} -t ${tag} -p ./py -s dev"
  stderr "    ${MY_FN} -t ${tag} -p ./py -P"
  stderr "    ${MY_FN} -t ${tag} -p ./py -P -L"
  stderr "    ${MY_FN} -t ${tag} -p github.com/flexos-io/deck-plan.git#:py"
  stderr "    ${MY_FN} -t ${tag} -p ./py -- --progress=plain --no-cache"
  stderr ""
  stderr "  Version: ${MY_VERSION}"
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
  #  ADD https://github.com/flexos-io/deck-build/releases/download/x.x.x/kit.tgz ${DECKBUILD_PLANT}/
  #  RUN cd ${DECKBUILD_PLANT} && tar --no-same-owner -zxpf kit.tgz && rm kit.tgz
  #  RUN tar --no-same-owner -zxpf ${DECKBUILD_PLANT}/kit.tgz -C ${DECKBUILD_PLANT} && rm ${DECKBUILD_PLANT}/kit.tgz
  #  COPY .kit ${DECKBUILD_KIT}
  if grep -q -P '^\s*(COPY|ADD)\s+\.kit\s+\${?DECKBUILD_KIT}?\s*$' ${dckrFp}; then
    if grep -q -P '^\s*ADD\s+https://github.com/.+/kit\.tgz\s+\${?DECKBUILD_PLANT}?/(kit\.tgz)?\s*$' ${dckrFp} || \
       grep -q -P '^\s*RUN\s+.+\${?DECKBUILD_PLANT}?.+\s+tar\s+.+\s+kit\.tgz(\s+.+)?\s*$' ${dckrFp} || \
       grep -q -P '^\s*RUN\s+(.*\s+)?tar\s+.+\s\${?DECKBUILD_PLANT}?/kit\.tgz(\s+.+)?\s*$' ${dckrFp}
    then
      die "Dockerfile wants to COPY and download kit: Don't enable both. See https://github.com/flexos-io/doc/wiki/deck_build#Configuration-Define-The-Kit"
    fi
    ! isz "${DECKBUILD_KIT_SRC:-}" || \
      die "Dockerfile wants to COPY kit but \${DECKBUILD_KIT_SRC} is not set. See https://github.com/flexos-io/doc/wiki/deck_build#Configuration-Define-The-Kit"
  fi
  if grep -q -P -r --include='*.sh' '^\s*setUser(\s*$|\s*#)' ${planDp} && \
     isz "${DECKBUILD_USER_CFG:-}"
  then
    die "Plan uses kit's setUser() but \${DECKBUILD_USER_CFG} is not set. See https://github.com/flexos-io/doc/wiki/deck_build#Configuration-Abstract-The-Custom-User"
  fi
}

buildPlant() {
  ! isz "${ARG_PLAN:-}" || usage
  ! isz "${ARG_IMG_TAG:-}" || usage
  trap clean EXIT
  export DECKBUILD_IMG=${ARG_IMG_TAG}           # e.g. flexos/foo:0.1.0
  export DECKBUILD_RELEASE=${ARG_IMG_TAG##*/}   # e.g.        foo:0.1.0
  sourceCfgs
  if isUri "${ARG_PLAN:-}"; then
    yellow "Plan: ${ARG_PLAN}"
    export DECKBUILD_PLAN_URI=1
    export DECKBUILD_PLAN=${ARG_PLAN}
    export DECKBUILD_PLANT=/tmp
  else
    local planDp=$(readlink -f ${ARG_PLAN})
    isd ${planDp} || die "Opening ${planDp}/ failed"
    local dckrFp=${planDp}/Dockerfile
    isz "${ARG_BUILD_STAGE:-}" || dckrFp+=".${ARG_BUILD_STAGE}"
    ise ${dckrFp} || die "Opening ${dckrFp} failed"
    checkIntegrity ${planDp} ${dckrFp}
    yellow "Plan: ${planDp}"
    if isx ${planDp}/build.sh; then
      export DECKBUILD_TMP_PLANT=true
      yellow "build.sh found: Enabling DECKBUILD_TMP_PLANT"
    fi
    if isb ${DECKBUILD_TMP_PLANT:-false}; then
      initTmp
      yellow "DECKBUILD_TMP_PLANT is enabled: Copying ${planDp}/ to tmp folder"
      local plantDp=${TMP_DP}/plant
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
      CLEAN_FPS+=" ${plantKitDp}"
      cp -a ${kitDp} ${plantKitDp}
    fi
    export DECKBUILD_PLAN_URI=0
    export DECKBUILD_PLAN=${planDp}
    export DECKBUILD_PLANT=${plantDp}
    export DECKBUILD_DOCKERFILE=${dckrFp##*/}
  fi
}

buildImg() {
  yellow "Building ${DECKBUILD_IMG}"
  local plantDp=${DECKBUILD_PLANT}
  cd ${plantDp}
  if isb ${DECKBUILD_PLAN_URI}; then
    local target=${DECKBUILD_PLAN}
  else
    local dckrFpArg=""
    if ! is ${DECKBUILD_DOCKERFILE} Dockerfile; then
      yellow "Build file is ${DECKBUILD_DOCKERFILE}"
      dckrFpArg="-f ${DECKBUILD_DOCKERFILE}"
    fi
    local buildShFp=${plantDp}/build.sh
    if isx ${buildShFp}; then
      if isb ${ARG_SKIP_BUILDSH:-}; then
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
  docker build ${dckrFpArg} --tag ${DECKBUILD_IMG} ${MY_ARGS2} \
      --build-arg DECKBUILD_PLANT=${dp} \
      --build-arg DECKBUILD_KIT=${dp}/kit \
      --build-arg DECKBUILD_RELEASE=${DECKBUILD_RELEASE:-} \
      --build-arg DECKBUILD_USER_CFG="${DECKBUILD_USER_CFG:-}" \
      --build-arg DECKBUILD_ARGS="${DECKBUILD_ARGS:-}" \
    ${target} || die "Building failed"
}

pushImg() {
  local imgTag=${DECKBUILD_IMG}
  yellow "Pushing to docker-hub"
  docker login || die "Login to docker-hub failed"
  yellow "Pushing ${imgTag}"
  docker push ${imgTag} || die "Pushing to docker-hub failed"
  if isb "${ARG_LATEST:-}"; then
    imgLatestTag=${imgTag%:*}:latest
    yellow "Pushing ${imgLatestTag}"
    docker tag ${imgTag} ${imgLatestTag}
    docker push ${imgLatestTag} || die "Pushing to docker-hub failed"
  fi
}

init() {
  ARG_FORCE=0
  ARG_PUSH=0
  ARG_LATEST=0
  if is~ "${MY_ARGS}" "--"; then
    MY_ARGS1="${MY_ARGS%%--*}"
    MY_ARGS2="${MY_ARGS#*--}"
    yellow "docker_build arguments: ${MY_ARGS2}"
  else
    MY_ARGS1="${MY_ARGS}"
    MY_ARGS2=""
  fi
  local arg=""
  while getopts FLPSVp:s:t: arg ${MY_ARGS1}; do
    case "${arg}" in
      F) ARG_FORCE=1;;
      L) ARG_LATEST=1;;
      P) ARG_PUSH=1;;
      p) ARG_PLAN="${OPTARG}";;
      t) ARG_IMG_TAG="${OPTARG}";;
      s) ARG_BUILD_STAGE="${OPTARG}";;
      S) ARG_SKIP_BUILDSH=1;;
      *) usage;;
    esac
  done
  # export values for child processes
  export DECKBUILD_PUSH=${ARG_PUSH}
  export DECKBUILD_PUSH_LATEST=${ARG_LATEST}
  export DECKBUILD_FORCE=${ARG_FORCE}
}

init
buildPlant
buildImg
! isb "${ARG_PUSH:-}" || pushImg
