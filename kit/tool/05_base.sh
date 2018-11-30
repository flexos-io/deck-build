
# matchs value
is() {
  [ "${1:-}" == "${2:-}" ]
}

# matchs regex
is~() {
  [[ "${1:-}" =~ ${2} ]]
}

# is empty
isz() {
  [ -z "${1:-}" ]
}

# is emtpy (regex)
isz~() {
  is~ "${1:-}" '^[[:space:]]*$'
}

# exists
ise() {
  ! isz~ "${1:-}" && [ -e "${1}" ]
}

# is readable
isr() {
  ! isz~ "${1:-}" && [ -r "${1}" ]
}

# is executable
isx() {
  ! isz~ "${1:-}" && [ -x "${1}" ]
}

# is directory
isd() {
  ! isz~ "${1:-}" && [ -d "${1}" ]
}

# is link
isl() {
  ! isz~ "${1:-}" && [ -L "${1}" ]
}

# is number
isn() {
  ! isz~ "${1:-}" && is~ "${1:-}" '^[[:digit:]]*$'
}

# boolean
isb() {
  local val="${1:-}"
  isz~ "${val}" || [ "${val}" == "0" ] || [ "${val,,}" == "false" ] && return 1
  return 0
}

# command is available
isc() {
  which ${1} >/dev/null 2>&1
}

warn() {
  red "WARN: ${1}"
}

error() {
  red "ERROR: ${1}"
}

die() {
  error "${1}"
  exit ${2:-1}
}
