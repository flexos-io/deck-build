
aptInstall() {
  ##C <packages>
  ##D Install debian packages (`apt-get install`).
  ##E aptInstall curl wget
  apt-get -y -f --no-install-recommends install ${*}
}

initDebPkgs() {
  ##D Update debian package repository (`apt-get update`).
  yellow "Initializing package repository"
  apt-get -y update || die "Updating package repository failed"
}

upgradeDebPkgs() {
  ##D Upgrade all debian packages (`apt-get upgrade`).
  yellow "Upgrading packages"
  apt-get -y --no-install-recommends upgrade || die "Upgrading packages failed"
}

cleanDebPkgs() {
  ##C [<delete_files>]
  ##D Clean debian package repository (`apt-get autoremove`).
  ##A delete_files = Clear also `/var/lib/apt/lists/*`, default is `true`
  ##E cleanDebPkgs false
  local clearFiles=${1:-true}
  yellow "Cleaning and checking packages"
  apt-get -y autoremove || die "Cleaning packages failed"
  aptInstall || die "Checking packages failed"
  isb ${clearFiles} && rm -rf /var/lib/apt/lists/*
}
