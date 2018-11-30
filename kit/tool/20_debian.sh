
aptInstall() {
  apt-get -y -f --no-install-recommends install ${*}
}

initDebPkgs() {
  if ! isb "${_FLEXOS_DEB_REPO_INIT:-}"; then
    yellow "Initializing package repository"
    apt-get -y update || die "Updating package repository failed"
    export _FLEXOS_DEB_REPO_INIT=1
  fi
}

cleanDebPkgs() {
  yellow "Cleaning and checking packages"
  apt-get -y autoremove || die "Cleaning packages failed"
  apt-get -y -f --no-install-recommends install || \
    die "Checking packages failed"
  #rm -rf /var/lib/apt/lists/*
}

installDebBatPkg() {
  initDebPkgs
  yellow "Installing bat"
  getGitHubLatest sharkdp/bat
  local vv=${_FLEXOS_GITHUB_LATEST}
  local v=${_FLEXOS_GITHUB_LATEST/v}
  local fp=/usr/local/src/bat_${v}.deb
  local url=https://github.com/sharkdp/bat/releases/download/
  url+=${_FLEXOS_GITHUB_LATEST}/bat_${v}_amd64.deb
  dload ${url} ${fp}
  ! isz "${fp}" || die "Getting bat failed"
  dpkg -i ${fp} || die "Installing bat failed"
}

upgradeDebPkgs() {
  initDebPkgs
  yellow "Upgrading packages"
  apt-get -y --no-install-recommends upgrade || die "Upgrading packages failed"
}

installDebPkgs() {
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
