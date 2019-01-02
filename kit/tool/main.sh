
if [[ " ${DECKBUILD_ARGS:-} " =~ " -e " ]]; then
  set -o errtrace
  set -o nounset
  set -o errexit
  set -o pipefail
  #set -o posix
fi

for _fp in ${DECKBUILD_KIT_TOOL}/*_*.sh; do . ${_fp}; done
initTmp
