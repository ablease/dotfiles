#!/usr/bin/env bash
set -euo pipefail

main() {
  interactively_ensure_we_are_logged_in
  lookup_token
}

check_lpass_status() {
  lpass status | grep "Logged in as" >/dev/null
}

interactively_ensure_we_are_logged_in() {
  if ! check_lpass_status
  then
    echo "Last pass isn't currently logged in. Who should we log in as?" 1>&2
    read username
    if [[ "${username%@*}" == "${username}" ]]; then
      username+="@pivotal.io"
    fi
    lpass login --trust "${username}" 1>&2
  fi
}

lookup_token() {
  lpass show --notes "Shared-PCF RabbitMQ/rabbitmq-toolsmiths-api-token"
}

main
