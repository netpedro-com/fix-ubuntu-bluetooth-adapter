#!/usr/bin/env sh

script_color_echo() {

  SCRIPT_COLOR_ECHO_NO_COLOR='\033[0m'
  script_color_echo_message=""
  script_color_echo_line_ending='\n'

  while [ $# -gt 0 ]; do

    script_color_echo_argument="$1"

    case ${script_color_echo_argument} in

    --black)
      script_color_echo_message="${script_color_echo_message}\033[0;30m"
      shift
      ;;
    --dark-red)
      script_color_echo_message="${script_color_echo_message}\033[0;31m"
      shift
      ;;
    --dark-green)
      script_color_echo_message="${script_color_echo_message}\033[0;32m"
      shift
      ;;
    --dark-yellow)
      script_color_echo_message="${script_color_echo_message}\033[0;33m"
      shift
      ;;
    --dark-blue)
      script_color_echo_message="${script_color_echo_message}\033[0;34m"
      shift
      ;;
    --dark-purple)
      script_color_echo_message="${script_color_echo_message}\033[0;35m"
      shift
      ;;
    --dark-cyan)
      script_color_echo_message="${script_color_echo_message}\033[0;36m"
      shift
      ;;
    --gray)
      script_color_echo_message="${script_color_echo_message}\033[0;37m"
      shift
      ;;
    --light-gray)
      script_color_echo_message="${script_color_echo_message}\033[1;30m"
      shift
      ;;
    -r | --red)
      script_color_echo_message="${script_color_echo_message}\033[1;31m"
      shift
      ;;
    -g | --green)
      script_color_echo_message="${script_color_echo_message}\033[1;32m"
      shift
      ;;
    -y | --yellow)
      script_color_echo_message="${script_color_echo_message}\033[1;33m"
      shift
      ;;
    -b | --blue)
      script_color_echo_message="${script_color_echo_message}\033[1;34m"
      shift
      ;;
    -p | --purple)
      script_color_echo_message="${script_color_echo_message}\033[1;35m"
      shift
      ;;
    -c | --cyan)
      script_color_echo_message="${script_color_echo_message}\033[1;36m"
      shift
      ;;
    --white)
      script_color_echo_message="${script_color_echo_message}\033[1;37m"
      shift
      ;;
    -s | --space)
      script_color_echo_message="${script_color_echo_message} "
      shift
      ;;
    -n | --no-color)
      script_color_echo_message="${script_color_echo_message}${SCRIPT_COLOR_ECHO_NO_COLOR}"
      shift
      ;;
    --no-line)
      script_color_echo_line_ending=""
      shift
      ;;
    *)
      script_color_echo_message="${script_color_echo_message}${script_color_echo_argument}"
      shift
      ;;
    esac
  done

  printf "%b" "${script_color_echo_message}${SCRIPT_COLOR_ECHO_NO_COLOR}${script_color_echo_line_ending}"
}

script_echo() {

  script_echo_time_argument=""

  while [ $# -gt 0 ]; do

    script_echo_parameter="$1"

    case ${script_echo_parameter} in

    -t | --time)
      script_echo_time_argument="--dark-purple -s $(date --rfc-3339=seconds | sed 's/ / -s /g')"
      shift
      ;;
    -c | --context)
      shift
      script_echo_context_argument="$1"

      case $script_echo_context_argument in

      dev | prod)
        script_echo_context_argument=" $script_echo_context_argument"
        ;;
      *)
        script_exit -m "Missing script_echo context argument (dev|prod). Received: $script_echo_context_argument"
        ;;
      esac

      shift
      ;;
    *)
      break
      ;;
    esac
  done

  if [ -n "$PROJECT_NAME_DEV" ]; then
    # shellcheck disable=SC2086
    script_color_echo -c "[${PROJECT_NAME_DEV}${script_echo_context_argument}]" $script_echo_time_argument -n -s "$@"
  elif [ -n "$PROJECT_NAME" ]; then
    # shellcheck disable=SC2086
    script_color_echo -c "[${PROJECT_NAME}${script_echo_context_argument}]" $script_echo_time_argument -n -s "$@"
  else
    # shellcheck disable=SC2086
    script_color_echo "$@"
  fi
}

script_echo_label() {
  #
  # Meta
  #
  script_echo_label_command="script_echo_label"
  script_echo_label_description="Colorized echo with labels. E.g. [LABEL TIME LABEL] MESSAGE"
  #
  # Variables
  #
  script_echo_label_text=""
  #
  # Parse
  #
  if [ $# -eq 0 ]; then
    script_exit --missing-argument "$script_echo_label_command"
  fi
  while [ $# -gt 0 ]; do

    script_echo_label_parameter="$1"

    case ${script_echo_label_parameter} in

    -d | --date)
      script_echo_label_text="$script_echo_label_text$(script_color_echo --blue -s "$(date -I)")"
      shift
      ;;
    -l | --label)
      shift
      script_echo_label_text_argument="$1"

      case $script_echo_label_text_argument in

      "")
        script_exit --missing-argument "${script_echo_label_command}_text_argument"
        ;;
      *)
        if [ -n "$script_echo_label_text" ]; then
          script_echo_label_text="$script_echo_label_text "
        fi
        script_echo_label_text="$script_echo_label_text$script_echo_label_text_argument"
        ;;
      esac
      shift
      ;;
    -t | --time)
      script_echo_label_text="$script_echo_label_text$(script_color_echo --dark-purple -s "$(date --rfc-3339=seconds)")"
      shift
      ;;
    -u | --human-time)
      script_echo_label_text="$script_echo_label_text$(script_color_echo --yellow -s "$(date -R)")"
      shift
      ;;
    -h | --help)
      echo ""
      echo "$script_echo_label_description"
      echo ""
      echo "Usage: $ $script_echo_label_command [OPTIONS] MESSAGE"
      echo ""
      echo "Arguments:"
      echo ""
      echo "  MESSAGE    Inserted after brackets."
      echo ""
      echo "Options:"
      echo ""
      echo "  -l, --label LABEL    Text inserted inside brackets. E.g. [label label label] message"
      echo "  -t, --time           Date time label, e.g. [2020-08-29 17:14:11-03:00]"
      echo "  -d, --date           Date only label, e.g. [2020-08-29]"
      echo "  -u, --human-time     Date time human label, e.g. [2020-08-29]"
      echo ""
      script_exit
      ;;
    "")
      script_exit --missing-argument "$script_echo_label_command"
      ;;
    *)
      break
      ;;
    esac
  done
  #
  # Execution
  #
  # shellcheck disable=SC2086
  script_color_echo -c "[$script_echo_label_text" -c "]" -n -s "$@"
}

script_exit() {

  script_exit_color=""
  script_exit_code=0
  script_exit_status=""
  script_exit_message=""

  while [ $# -gt 0 ]; do

    script_exit_parameter="$1"

    case ${script_exit_parameter} in

    -s | --successful)
      script_exit_color="-g"
      script_exit_code=0
      script_exit_status="Exited with code $script_exit_code (successful)."
      shift
      ;;
    -e | --error)
      script_exit_color="-r"
      script_exit_code=1
      script_exit_status="Exited with code $script_exit_code (error)."
      shift
      ;;
    -u | --unknown-option)
      script_exit_color="-r"
      script_exit_code=2
      script_exit_status="Exited with code $script_exit_code (unknown option)."
      shift
      ;;
    -w | --wrong-environment)
      script_exit_color="-r"
      script_exit_code=10
      script_exit_status="Exited with code $script_exit_code (wrong environment)."
      shift
      ;;
    -m | --missing-variable)
      script_exit_color="-r"
      script_exit_code=11
      script_exit_status="Exited with code $script_exit_code (missing variable)."
      shift
      ;;
    --missing-directory)
      script_exit_color="-r"
      script_exit_code=12
      script_exit_status="Exited with code $script_exit_code (missing directory)."
      shift
      ;;
    --missing-dependency)
      script_exit_color="-r"
      script_exit_code=13
      script_exit_status="Exited with code $script_exit_code (missing dependency)."
      shift
      ;;
    --file-not-found)
      script_exit_color="-r"
      script_exit_code=14
      script_exit_status="Exited with code $script_exit_code (file not found)."
      shift
      ;;
    --missing-argument)
      script_exit_color="-r"
      script_exit_code=15
      script_exit_status="Exited with code $script_exit_code (missing argument)."
      shift
      ;;
    --wrong-argument)
      script_exit_color="-r"
      script_exit_code=16
      script_exit_status="Exited with code $script_exit_code (wrong argument)."
      shift
      ;;
    --directory-not-found)
      script_exit_color="-r"
      script_exit_code=17
      script_exit_status="Exited with code $script_exit_code (directory not found)."
      shift
      ;;
    --import-error)
      script_exit_color="-r"
      script_exit_code=18
      script_exit_status="Exited with code $script_exit_code (import error)."
      shift
      ;;
    *)
      script_exit_message="$script_exit_message$script_exit_parameter"
      shift
      ;;
    esac
  done

  if [ -n "${script_exit_message}" ]; then
    script_echo "$script_exit_color" "$script_exit_message"
  fi

  if [ -n "${script_exit_status}" ]; then
    script_echo "$script_exit_color" "$script_exit_status"
  fi
  exit $script_exit_code
}

script_continue_question() {

  while true; do

    script_echo --no-line "Continue? [y] yes, [n] no, default [y] "
    read -r answer

    answer=${answer:-"Yes"}
    case $answer in

    [Yy]*)
      break
      ;;
    [Nn]*)
      script_exit "Aborted by user."
      ;;
    *)
      script_echo "Please, answer \"yes\" or \"no\"."
      ;;
    esac
  done
}

# shellcheck disable=SC2120
script_wrap() {

  script_wrap_spacer_counter=15

  while [ $# -gt 0 ]; do

    script_wrap_parameter="$1"

    case ${script_wrap_parameter} in

    -s | --spacer)
      shift
      script_wrap_spacer_argument="$1"

      case $script_wrap_spacer_argument in

      "")
        script_exit -m "Missing script_wrap spacer argument. Received: $script_wrap_spacer_argument"
        ;;
      *)
        script_wrap_spacer_counter="$script_wrap_spacer_argument"
        ;;
      esac
      shift
      ;;
    *)
      break
      ;;
    esac
  done

  script_wrap_counter=0
  script_wrap_spaces=""
  while [ "$script_wrap_counter" -lt "$script_wrap_spacer_counter" ]; do
    script_wrap_spaces=" $script_wrap_spaces"
    script_wrap_counter=$((script_wrap_counter = script_wrap_counter + 1))
  done

  script_wrap_counter=0

  fmt | while IFS="" read -r line; do
    if [ $script_wrap_counter -eq 0 ]; then
      echo "$line"
    else
      echo "${script_wrap_spaces}${line}"
    fi
    script_wrap_counter=$((script_wrap_counter = script_wrap_counter + 1))
  done
}

script_ensure_false() {
  #
  # Meta
  #
  script_ensure_false_command="script_ensure_false"
  script_ensure_false_description="Ensures argument has false value."
  #
  # Variables
  #
  script_ensure_false_variable=""
  script_ensure_false_message=""
  #
  # Parse
  #
  while [ $# -gt 0 ]; do

    script_ensure_false_parameter="$1"

    case ${script_ensure_false_parameter} in

    -m | --message)
      shift
      script_ensure_false_message_argument="$1"

      case $script_ensure_false_message_argument in

      "")
        script_exit --missing-argument "script_ensure_false_message_argument"
        ;;
      *)
        if [ -n "$script_ensure_false_message" ]; then
          script_ensure_false_message="$script_ensure_false_message "
        fi
        script_ensure_false_message="$script_ensure_false_message$script_ensure_false_message_argument"
        ;;
      esac
      shift
      ;;
    -h | --help)
      echo ""
      echo "$script_ensure_false_description"
      echo ""
      echo "Usage: $ $script_ensure_false_command [OPTIONS] VARIABLE"
      echo ""
      echo "Arguments:"
      echo ""
      echo "  VARIABLE    Variable to check."
      echo ""
      echo "Options:"
      echo ""
      echo "  -m, --message MESSAGE    Error exit message."
      echo ""
      exit
      ;;
    "")
      script_exit --missing-argument "$script_ensure_false_command"
      ;;
    *)
      if [ -n "$script_ensure_false_variable" ]; then
        script_exit --wrong-argument "$script_ensure_false_parameter"
      fi
      script_ensure_false_variable="$script_ensure_false_parameter"
      shift
      ;;
    esac
  done
  #
  # Execution
  #
  if [ -z "$script_ensure_false_message" ]; then
    script_ensure_false_message="[$script_ensure_false_command] Variable argument doesn't have false value."
  fi
  if [ "$script_ensure_false_variable" != "false" ]; then
    script_exit --error "$script_ensure_false_message"
  fi
}
