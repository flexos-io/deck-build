
writeFlexosCfg() {
  yellow "Creating flexos bashd"
  export _FLEXOS_TMP_CFG=${_FLEXOS_TMP}/81_flexos.sh
  local vars=$(env | grep -E ^FLEXOS_ | sort)
  echo -e "set -a\n${vars}\nset +a" > ${_FLEXOS_TMP_CFG}
}

installFlexos() {
  local dp="${1:-}"
  writeFlexosCfg
  addToBashd ${_FLEXOS_TMP_CFG} ${dp}
  addToBashd ${FLEXOS_KIT_STOCK}/flexos/80_flexos.sh ${dp}
  rm ${_FLEXOS_TMP_CFG}
}

installFlexosBasher() {
  installBasherPkg flexos-io/flexos-sh-base
  installBasherPkg flexos-io/flexos-sh-tool
}

installFlexosPy() {
  installPyPkgs ${FLEXOS_KIT_STOCK}/python/requirements/base.txt
  installPyPkgs ${FLEXOS_KIT_STOCK}/flexos/python/requirements/flexos.txt
}
