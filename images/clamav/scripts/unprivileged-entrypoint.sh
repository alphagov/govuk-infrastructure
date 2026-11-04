#!/usr/bin/env sh
#
# This script is licensed under the GPL-2.0 (or later) license.
#
# Copyright (C) 2021 Olliver Schinagl <oliver@schinagl.nl>
# Copyright (C) 2021-2023 Cisco Systems, Inc. and/or its affiliates. All rights reserved.
#
# The original version of this script can be found at
# https://github.com/Cisco-Talos/clamav-docker/blob/b2fea9dbb6cb89ced9bfffdd2e1e684c669c2442/clamav/1.5/debian/scripts/docker-entrypoint-unprivileged.sh.

set -eu

# run command if it is not starting with a "-" and is an executable in PATH
if [ "${#}" -gt 0 ] && \
   [ "${1#-}" = "${1}" ] && \
   command -v "${1}" > "/dev/null" 2>&1; then
	# Ensure healthcheck always passes
	CLAMAV_NO_CLAMD="true" exec "${@}"
else
	if [ "${#}" -ge 1 ] && \
	   [ "${1#-}" != "${1}" ]; then
		# If an argument starts with "-" pass it to clamd specifically
		exec clamd "${@}"
	fi
	# else default to running clamav's servers

	# Ensure we have some virus data, otherwise clamd refuses to start
	if [ ! -f "/var/lib/clamav/main.cvd" ]; then
		echo "Updating initial database"
		# Set "TestDatabases no" and remove "NotifyClamd" for initial download
		sed -e 's|^\(TestDatabases \)|\#\1|' \
			-e '$a TestDatabases no' \
			-e 's|^\(NotifyClamd \)|\#\1|' \
			/etc/clamav/freshclam.conf > /tmp/freshclam_initial.conf
		freshclam --foreground --stdout --config-file=/tmp/freshclam_initial.conf
		rm /tmp/freshclam_initial.conf
	fi

	if [ "${CLAMAV_NO_FRESHCLAMD:-false}" != "true" ]; then
		echo "Starting Freshclamd"
		freshclam \
		          --checks="${FRESHCLAM_CHECKS:-1}" \
		          --daemon \
		          --foreground \
		          --stdout \
		          --user="clamav" \
			  &
	fi

	if [ "${CLAMAV_NO_CLAMD:-false}" != "true" ]; then
		echo "Starting ClamAV"
		if [ -S "/tmp/clamd.sock" ]; then
			unlink "/tmp/clamd.sock"
		fi
		clamd --foreground &
		while [ ! -S "/tmp/clamd.sock" ]; do
			if [ "${_timeout:=0}" -gt "${CLAMD_STARTUP_TIMEOUT:=1800}" ]; then
				echo
				echo "Failed to start clamd"
				exit 1
			fi
			printf "\r%s" "Socket for clamd not found yet, retrying (${_timeout}/${CLAMD_STARTUP_TIMEOUT}) ..."
			sleep 1
			_timeout="$((_timeout + 1))"
		done
		echo "socket found, clamd started."
	fi

	if [ "${CLAMAV_NO_MILTERD:-true}" != "true" ]; then
		echo "Starting clamav milterd"
		clamav-milter &
	fi

	# Wait forever (or until canceled)
	exec tail -f "/dev/null"
fi

exit 0
