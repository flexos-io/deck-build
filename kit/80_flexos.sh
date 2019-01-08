
installFlexos() {
  ##C [<directory_path>]
  ##D Install flexos environment (for specific user).
  ##A directory_path = bash.d parent folder, see installBashd() for details
  ##E installFlexos            # adds flexos files to root's bash.d folder
  ##E sudo foo installFlexos   # adds flexos files to user foo's bash.d folder
  local dp="${1:-}"
  yellow "Creating flexos bash.d"
  export _DECKBUILD_TMP_CFG=${_DECKBUILD_TMP}/81_flexos.sh
  local vars1=$(env | grep -E ^FLEXOS_ | sort)
  local vars2=$(env | grep -E ^DECKBUILD_ | sort)
  echo -e "set -a\n${vars1}\n${vars2}\nset +a" > ${_DECKBUILD_TMP_CFG}
  addToBashd ${_DECKBUILD_TMP_CFG} ${dp}
  addToBashd ${DECKBUILD_KIT_STOCK}/flexos/80_flexos.sh ${dp}
  rm ${_DECKBUILD_TMP_CFG}
}

installFlexosSh() {
  ##D Install flexos basher packages (for specific user).
  ##E installFlexosSh             # install packages for root
  ##E sudof foo installFlexosSh   # install packages for user foo
  installBasherPkg flexos-io/flexos-sh-base
  installBasherPkg flexos-io/flexos-sh-tool
}

installFlexosPy() {
  ##D Install flexos python packages (for specific user).
  ##E installFlexosPy             # install packages for root
  ##E sudof foo installFlexosPy   # install packages for user foo
  installPyPkgs ${DECKBUILD_KIT_STOCK}/python/requirements/base.txt
  installPyPkgs ${DECKBUILD_KIT_STOCK}/flexos/python/requirements/flexos.txt
}
