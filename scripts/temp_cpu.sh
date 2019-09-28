#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=helpers.sh
source "$CURRENT_DIR/helpers.sh"

print_cpu_temp() {
  local temp_pkg
  if [[ $(uname -mr) =~ (arm|aarch64|raspi) ]]; then # if on raspberry PI
    temp_pkg=$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))
  elif command_exists "sensors"; then
    temp_pkg=($(sensors | egrep '^Package' | sed '/^\s*$/d' | awk '{printf("%f ", $4)}'))
  else
    echo "no sensors found"
    return
  fi
  # Render the string with temperature values
  local units=$1
  local temp
  local temp_string
  # retrieve temperature of all CPU packages
  temp_pkg=($(sensors | egrep '^Package' | sed '/^\s*$/d' | awk '{printf("%f ", $4)}'))
  for k in $(seq 0 $((${#temp_pkg[@]} - 1))); do
    temp=${temp_pkg[k]}
    if [ "$units" = "F" ]; then
      temp=$(celsius_to_fahrenheit "$temp")
    fi
    # Build a string that has all temperatures
    temp_string="$temp_string $(printf "%3.0fº%s" "$temp" "$units")"
  done
  # remove leading and trailing whitespace
  echo "$temp_string" | awk 'BEGIN{OFS=" "}$1=$1{print $0}'
}

main() {
  local units
  units=$(get_tmux_option "@temp_units" "C")
  print_cpu_temp "$units"
}
main
