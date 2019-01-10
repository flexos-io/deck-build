
aptInstall() {
  ##C <packages>
  ##D Install debian packages (`apt-get install`).
  ##E aptInstall curl wget
  apt-get -y -f --no-install-recommends install ${*}
}

initDebPkgs() {
  ##D Update debian package repository if necessary (`apt-get update`).
  ##D Necessary means: `${_DECKBUILD_DEB_REPO_INIT}` is not set
  ##D (`initDebPkgs()` sets `${_DECKBUILD_DEB_REPO_INIT}` after running).
  ##E unset ${_DECKBUILD_DEB_REPO_INIT}; initDebPkgs  # force action
  if ! isb "${_DECKBUILD_DEB_REPO_INIT:-}"; then
    yellow "Initializing package repository"
    apt-get -y update || die "Updating package repository failed"
    export _DECKBUILD_DEB_REPO_INIT=1
  fi
}

cleanDebPkgs() {
  ##C [<delete_files>]
  ##D Clean debian package repository (`apt-get autoremove`).
  ##A delete_files = Clear also `/var/lib/apt/lists/*` if set to `true` or `1`
  ##E cleanDebPkgs true
  local noFiles=${1:-1}
  yellow "Cleaning and checking packages"
  apt-get -y autoremove || die "Cleaning packages failed"
  apt-get -y -f --no-install-recommends install || \
    die "Checking packages failed"
  isb ${noFiles} || rm -rf /var/lib/apt/lists/*
}

installDebBatPkg() {
  ##D Install [bat's](https://github.com/sharkdp/bat) latest version.
  initDebPkgs
  yellow "Installing bat"
  getGitHubLatest sharkdp/bat
  local v=${_DECKBUILD_GITHUB_LATEST/v}
  local fp=/usr/local/src/bat_${v}.deb
  local url=https://github.com/sharkdp/bat/releases/download/
  url+=${_DECKBUILD_GITHUB_LATEST}/bat_${v}_amd64.deb
  dload ${url} ${fp}
  ! isz "${fp}" || die "Getting bat failed"
  dpkg -i ${fp} || die "Installing bat failed"
}

upgradeDebPkgs() {
  ##D Upgrade all debian packages (`apt-get upgrade`).
  initDebPkgs
  yellow "Upgrading packages"
  apt-get -y --no-install-recommends upgrade || die "Upgrading packages failed"
}

installDebPkgs() {
  ##D Install some useful debian packages (`apt-get install sudo curl ...`).
  initDebPkgs
  yellow "Installing packages"
  apt-get -y --no-install-recommends install \
    apt-transport-https \
    apt-utils \
    bind9-host \
    build-essential \
    ca-certificates \
    curl \
    dnsutils \
    ethtool \
    file \
    git \
    gnupg \
    inotify-tools \
    iputils-arping \
    iputils-ping \
    jq \
    less \
    libpython-dev \
    libpython3-dev \
    libxml2-utils \
    lsb-release \
    man \
    nano \
    net-tools \
    netcat \
    ngrep \
    nmap \
    openssh-client \
    procps \
    psmisc \
    pwgen \
    python-dev \
    python-pip \
    python-yaml \
    python3-dev \
    python3-pip \
    python3-yaml \
    rsync \
    screen \
    software-properties-common \
    ssl-cert \
    strace \
    sudo \
    tcpdump \
    vim \
    w3m \
    wget || \
  die "Installing packages failed"
}
