
stderr() {
  ##C <message> [<format>]
  ##D Print a message to stderr.
  ##A format = Format (passed to "echo"), e.g. "00;34" to print a blue message
  ##E stderr "Hello World"
  ##E stderr "Hello World" "00;34"
  local msg="${1}"
  local fmt="${2:-}"
  if [ -z "${fmt}" ]; then
    echo -e "${msg}" >&2
  else
    stderr "\e[${fmt}m${msg}\e[00m"
  fi
}

blue() {
  ##C <message>
  ##D Print a blue message to stderr.
  stderr "${1}" "00;34"
}

black() {
  ##C <message>
  ##D Print a black message to stderr.
  stderr "${1}" "00;30"
}

cyan() {
  ##C <message>
  ##D Print a cyan message to stderr.
  stderr "${1}" "00;36"
}

green() {
  ##C <message>
  ##D Print a green message to stderr.
  stderr "${1}" "00;32"
}

pink() {
  ##C <message>
  ##D Print a pink message to stderr.
  stderr "${1}" "00;35"
}

red() {
  ##C <message>
  ##D Print a red message to stderr.
  stderr "${1}" "00;31"
}

redBold() {
  ##C <message>
  ##D Print a bold red message to stderr.
  stderr "${1}" "01;31"
}

white() {
  ##C <message>
  ##D Print a white message to stderr.
  stderr "${1}" "00;37"
}

yellow() {
  ##C <message>
  ##D Print a yellow message to stderr.
  stderr "${1}" "00;33"
}
