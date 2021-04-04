#!/usr/bin/env sh

################
# Script Section
################

# Abort on script execution error
set -e

SCRIPT_DIR=$(dirname "$(readlink -e "$0")")
cd "$SCRIPT_DIR"

SCRIPT_UTIL_SOURCE="$SCRIPT_DIR/scripts/script-util.sh"
# shellcheck source=./scripts/script-util.sh
. "$SCRIPT_UTIL_SOURCE"

SCRIPT_NAME=$(basename "$0")

#################
# Project Section
#################

PROJECT_NAME="fix-ubuntu-bluetooth-adapter"
PROJECT_NAME_DISPLAY="Script to Fix Ubuntu's USB Bluetooth 5.0 Adapter"
PROJECT_NAME_DESCRIPTION="Script to fix Ubuntu's recognition problem for USB bluetooth 5.0 adapter (Easy Idea)."
PROJECT_DRIVER_FILE="20201202_mpow_BH456A_driver+for+Linux.7z"

#############
# Fix Section
#############

FIX_NAME="Fix"
FIX_COMMAND="fix"
FIX_DESCRIPTION="Fix Ubuntu's USB bluetooth 5.0 adapter."

echo_fix_usage() {
  echo "Usage: $ sh ${SCRIPT_NAME} $FIX_COMMAND [OPTIONS] [-h,--help]"
}

echo_fix_help() {
  echo ""
  echo_fix_usage
  echo ""
  echo "$FIX_DESCRIPTION"
  echo ""
  echo "Options:"
  echo ""
  echo "  -h, --help    Show this help message and exit."
  echo ""
}

execute_fix() {

  temp_dir="/tmp/$PROJECT_NAME"
  mkdir -p "$temp_dir"
  cd "$temp_dir"

  is_fix_applied="none"
  for name in $(dmesg | grep -oP "Bluetooth.*firmware file rtl_bt/\K.*(?=_fw\.bin not found)"); do
    7z e -y -o"$temp_dir" "$SCRIPT_DIR/$PROJECT_DRIVER_FILE" \
      "20201202_LINUX_BT_DRIVER/rtkbt-firmware/lib/firmware/rtlbt/${name}_fw" \
      "20201202_LINUX_BT_DRIVER/rtkbt-firmware/lib/firmware/rtlbt/${name}_config"
    sudo cp "${name}_fw" "/usr/lib/firmware/rtl_bt/${name}_fw.bin"
    sudo cp "${name}_config" "/usr/lib/firmware/rtl_bt/${name}_config.bin"
    is_fix_applied="yes"
  done
  if [ "$is_fix_applied" = "yes" ]; then
    script_echo -g "Fix applied successfully (reboot your PC)"
  else
    script_echo -g "Fix not applied"
  fi
}

parse_fix_command() {

  while [ $# -gt 0 ]; do

    shift
    parse_fix_parameter="${1}"

    case ${parse_fix_parameter} in

    -h | --help)
      echo_fix_help
      script_exit
      ;;
    "")
      script_echo -t "$FIX_NAME command started."
      execute_fix
      script_echo -t "$FIX_NAME command finished."
      script_exit --successful
      ;;
    *)
      echo_fix_usage
      script_exit --unknown-option "${parse_fix_parameter}"
      ;;
    esac
  done
}

#################
# Project Section
#################

echo_project_usage() {
  echo "Usage: $ sh ${SCRIPT_NAME} [OPTIONS] [COMMAND] [-h,--help]"
}

echo_project_help() {
  echo ""
  script_color_echo -y "========= $PROJECT_NAME_DISPLAY ========="
  script_color_echo -y "========= PedroVagner.com © 2021 ========="
  echo ""
  echo_project_usage
  echo ""
  echo "${PROJECT_NAME_DESCRIPTION}"
  echo ""
  echo "Commands:"
  echo ""
  echo "  $FIX_COMMAND    $(echo "$FIX_DESCRIPTION" | script_wrap)"
  echo ""
  echo "Options:"
  echo ""
  echo "  -h, --help    Show this help message and exit."
  echo ""
}

if [ $# -eq 0 ]; then
  echo_project_help
  script_exit
fi

while [ $# -gt 0 ]; do

  project_parameter="$1"

  case ${project_parameter} in

  -h | --help)
    echo_project_help
    script_exit
    ;;
  "$FIX_COMMAND")
    parse_fix_command "$@"
    ;;
  *)
    echo_project_usage
    script_exit --unknown-option "${project_parameter}"
    ;;
  esac
done
