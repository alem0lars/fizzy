#!/bin/bash
set -e

_dir=$(pwd)
cd /tmp

nohup sh -c /usr/sbin/sshd -D &

cd "${_dir}"
unset _dir

exec "$@"