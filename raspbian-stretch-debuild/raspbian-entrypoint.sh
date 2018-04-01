#!/bin/sh

set -e

if [ -n "$UID" -a -n "$GID" ]; then
	groupadd -g $GID guest
	useradd -r -u $UID -g $GID guest
fi

# behave as init 1 to handle signal and wait process
trap 'kill $pid; wait $pid; exit 1' INT TERM QUIT

apt-get update &
pid=$!
wait $pid
[ -f debian/control ] && {
	(export DEBIAN_FRONTEND=noninteractive; yes | mk-build-deps -i -r) &
	pid=$!
	wait $pid
}

[ -n "$CCACHE_DIR" ] && {
	[ -d "$CCACHE_DIR" ] || mkdir -p "$CCACHE_DIR" || exit 1
	chown -R ${UID:-$(id -u)}:${GID:-$(id -g)} "$CCACHE_DIR" &
	pid=$!
	wait $pid
}
pid=
set -x
exec /sbin/tini -- ${UID:+gosu guest} \
	eatmydata debuild \
	${CCACHE_DIR:+--preserve-envvar=CCACHE_DIR --prepend-path=/usr/lib/ccache} \
	-I.git -i'\.git/' \
	-us -uc \
	$@
