
stderr() {
  local msg="${1}"
  local fmt="${2:-}"
  if [ -z "${fmt}" ]; then
    echo -e "${msg}" >&2
  else
    stderr "\e[${fmt}m${msg}\e[00m"
  fi
}

blue() {
  stderr "${1}" "00;34"
}

black() {
  stderr "${1}" "00;30"
}

cyan() {
  stderr "${1}" "00;36"
}

green() {
  stderr "${1}" "00;32"
}

pink() {
  stderr "${1}" "00;35"
}

red() {
  stderr "${1}" "00;31"
}

redBold() {
  stderr "${1}" "01;31"
}

white() {
  stderr "${1}" "00;37"
}

yellow() {
  stderr "${1}" "00;33"
}
