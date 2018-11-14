#!/usr/bin/env bash

set -e pipefail

script_name="${0##*/}"

mongo_host="$MONGODB_HOST"
mongo_port="$MONGODB_PORT"
mongo_conn=(--host "${mongo_host}" --port "${mongo_port}")

admin_user="$ADMIN_USERNAME"
admin_password="$ADMIN_PASSWORD"
admin_creds=(-u "$admin_user" -p "$admin_password")
ssl_args=()

database="$DATABASE"
database_user="$DATABASE_USER"
database_password="$DATABASE_PASSWORD"

log() {
  local msg="$1"
  local timestamp=$(date --iso-8601=ns)
  echo "[$timestamp] [$script_name] ${msg}" 2>&1
}

retry_until() {
  local command="${1}"
  local expected="${2}"

  local seconds=0
  local timeout=300

  until [[ $(mongo admin "${mongo_conn[@]}" "${admin_creds[@]}" "${ssl_args[@]}" --quiet --eval "${command}") == "${expected}" ]]; do
    log "Retrying ${command}"
    sleep 15

    seconds=$((seconds + 15))

    if [[ "${seconds}" -ge "${timeout}" ]]; then
      log "Timed out after ${timeout}s attempting to create ${database_user} user"
      exit 1
    fi
  done
}

log "Waiting for MongoDB to be ready..."
retry_until "db.adminCommand('ping').ok" "1"

log "Creating '${database}' database admin user '${database_user}'"

mongo admin "${mongo_conn[@]}" "${admin_creds[@]}" "${ssl_args[@]}" << EOF
  use ${database};
  db.dropAllUsers();
  db.createUser({
    user: '${database_user}',
    pwd: '${database_password}',
    roles: [ { role: 'dbOwner', db: '${database}' } ]
  });
EOF

log "User ${database_user} created"
exit 0
