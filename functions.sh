#!/bin/sh

debuild-docker() {
    local distro image workdir build name
    [ $# -ge 2 ] || {
        echo >&2 "usage: debuild-docker <distribution> <image> [arguments]"
        return 1
    }
    distro=$1; shift
    image=$1; shift
    if [ -f debian/control ]; then
        workdir=$(pwd)
    else
        echo >&2 "Please run me inside a Debian source directory."
        return 1
    fi
    build=$(dirname $workdir)
    name=$(basename $workdir)
    [ -n "$build" ] || {
        printf >&2 "Failed to split \"%s\" between parent and name\n" "$workdir"
        printf >&2 "parent:\t\"%s\"\nname:\t\"%s\"\n" "$build" "$name"
        return 1
    }
    http_proxy=${docker_http_proxy:-${http_proxy}}
    https_proxy=${docker_https_proxy:-${https_proxy}}
    docker run --rm                     \
        -e "http_proxy=${http_proxy}"   \
        -e "https_proxy=${https_proxy}" \
        -e "UID=$UID" -e "GID=$GID"     \
        -e "CCACHE_DIR=/mnt/.ccache"    \
        -v $distro-ccache:/mnt/.ccache  \
        -v $build:/mnt/build            \
        -w "/mnt/build/$name"           \
        $image $@
}

debuild-stretch() {
    debuild-docker debian lboulard/debian-debuild:stretch $@
}

debuild-xenial() {
    debuild-docker ubuntu lboulard/ubuntu-debuild:xenial $@
}

debuild-trusty() {
    debuild-docker ubuntu lboulard/ubuntu-debuild:trusty $@
}

debuild-rapsbian-stretch() {
    debuild-docker raspbian lboulard/raspbian-debuild:stretch $@
}
