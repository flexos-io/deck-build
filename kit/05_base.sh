
is() {
  ##C <value> <value>
  ##D Check if values are equal.
  ##E is foo foo || ...
  ##E if is foo bar; then ...
  [ "${1:-}" == "${2:-}" ]
}

is~() {
  ##C <value> <regex>
  ##D Check if value matchs the regular expression.
  ##E is~ foo '^[0-9]+$' || ...
  ##E if is foo '^bar'; then ...
  [[ "${1:-}" =~ ${2} ]]
}

isz() {
  ##C <value>
  ##D Check if value is empty (`test -z`).
  ##E isz "foo" || ...
  ##E if isz ""; then ...
  [ -z "${1:-}" ]
}

isz~() {
  ##C <value>
  ##D Regex-check if value is empty.
  ##E isz~ "foo" || ...
  ##E if isz~ "   "; then ...
  is~ "${1:-}" '^[[:space:]]*$'
}

ise() {
  ##C <path>
  ##D Check if file exists (`test -e`).
  ##E ise /tmp/foo.txt || ...
  ##E if ise /tmp/bar; then ...
  ! isz~ "${1:-}" && [ -e "${1}" ]
}

isr() {
  ##C <path>
  ##D Check if file exists and is readable (`test -r`).
  ##E isr /tmp/foo.txt || ...
  ##E if isr /tmp/bar; then ...
  ! isz~ "${1:-}" && [ -r "${1}" ]
}

isx() {
  ##C <path>
  ##D Check if file exists and is executable (`test -x`).
  ##E isx /tmp/foo.sh || ...
  ##E if isx /tmp/bar; then ...
  ! isz~ "${1:-}" && [ -x "${1}" ]
}

isd() {
  ##C <path>
  ##D Check if file exists and is a directory (`test -d`).
  ##E isd /tmp/foo || ...
  ##E if isd /tmp/bar; then ...
  ! isz~ "${1:-}" && [ -d "${1}" ]
}

isl() {
  ##C <path>
  ##D Check if file exists and is a link (`test -L`).
  ##E isl /tmp/foo.sh || ...
  ##E if isl /tmp/bar; then ...
  ! isz~ "${1:-}" && [ -L "${1}" ]
}

isn() {
  ##C <value>
  ##D Check if value is a number.
  ##E isn 100 || ...
  ##E if isn 2; then ...
  ! isz~ "${1:-}" && is~ "${1:-}" '^[[:digit:]]*$'
}

isb() {
  ##C <value>
  ##D Boolean check.
  ##D Returns `1` (`false`) for `0`, `false` and empty values.
  ##D Returns `0` (`true`) for other values.
  ##E isb true || ...    # true
  ##E isb foo || ...     # true
  ##E if isb 1; then ... # true
  ##E isb 0 || ...       # false
  ##E isb false || ...   # false
  ##E isb "" || ...      # false
  ##E isb "   " || ...   # false
  local val="${1:-}"
  isz~ "${val}" || [ "${val}" == "0" ] || [ "${val,,}" == "false" ] && return 1
  return 0
}

isc() {
  ##C <command>
  ##D Check if command is runnable (`which <command>`).
  ##E isc ls || ...
  ##E if isc ps; then ...
  which ${1} >/dev/null 2>&1
}

warn() {
  ##C <message>
  ##D Print a red warning message to stderr.
  ##E warn "Timeout reached"
  red "WARN: ${1}"
}

error() {
  ##C <message>
  ##D Print a red error message to stderr.
  ##E error "Downloading file failed"
  red "ERROR: ${1}"
}

die() {
  ##C <message> [<exit_code>]
  ##D Print a red error message to stderr and abort process.
  ##E die "Database unreachable"     # exit code is 1
  ##E die "No network connection" 5  # exit code is 5
  error "${1}"
  exit ${2:-1}
}
