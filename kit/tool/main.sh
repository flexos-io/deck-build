#!/bin/bash

if [[ " ${FLEXOS_BUILD_ARGS:-} " =~ " -e " ]]; then
  set -o errtrace
  set -o nounset
  set -o errexit
  set -o pipefail
  #set -o posix
fi

for _fp in ${FLEXOS_KIT_TOOL}/*_*.sh; do . ${_fp}; done
initTmp 777
