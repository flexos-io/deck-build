
export MY_ARGS="${*}"
export MY_FP="${0}"
export MY_FN="${MY_FP##*/}"
export MY_DP=${MY_FP%/*}

for FP in ${DECKBUILD_KIT}/*_*.sh; do . ${FP}; done
unset FP

initTmp
