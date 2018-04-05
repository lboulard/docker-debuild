---
title: Docker images for _deb_ creation on Debian distribution and variants
author: "Laurent Boulard <laurent.boulard@gmail.com>"
---

# Docker images for Debian Stretch, Raspbian Stretch, and supported Ubuntu distributions.

## List of images

All images are AMD64 architecture based but Raspbian. Raspbian is ARM
architecture based.

For Raspbian images on AMD64, you need to install `binfmt-support` package on
Debian based distributions as _qemu_ is used to emulate ARM instruction set on
AMD64.

Images list created when running `make`:

- `lboulard/debian-dev:stretch`
- `lboulard/debian-debuild:stretch`
- `lboulard/raspbian-dev:stretch`
- `lboulard/raspbian-debuild:stretch`
- `lboulard/ubuntu-dev:trusty`
- `lboulard/ubuntu-debuild:trusty`
- `lboulard/ubuntu-dev:xenial`
- `lboulard/ubuntu-debuild:xenial`
- `lboulard/ubuntu-dev:artful`
- `lboulard/ubuntu-debuild:artful`
- `lboulard/ubuntu-dev:bionic`
- `lboulard/ubuntu-debuild:bionic`

Images `...-dev` contains enough to build simple project in C/C++. This image
always run as root. They are expected to be used as a base for more complete
build images.

Images `...-debuild` contains a `debuild` wrapper to prepare the build and create
files with current user credentials.

## How to use

By default, images `...-dev` start a root shell (usually `/bin/bash`). `ccache`
is installed and accessible at `/usr/lib/ccache` but not set on default `PATH`.

Images `...-debuild` invoke `debuild -i -us -uc`. Any parameters are happened
to this base command. They also do `apt-get update` and `mkd-build-deps -i -r`
to fetch and install dependencies for _dpkg_ build. When defined, variables
`UID` and `GID` will be used to define an user for running `debuild`. `ccache`
is configured for usage with `debuild`.

Typical `run` command for `...-debuild` images, with `$distro` from one of
`debian`, `ubuntu`, `raspbian`. Run it in directory where source project is
installed (i.e. for project in `/path/project`, run in `/path`).

```sh
docker run --rm                         \
        -e "http_proxy=${http_proxy}"   \
        -e "https_proxy=${https_proxy}" \
        -e "UID=$UID" -e "GID=$GID"     \
        -e "CCACHE_DIR=/mnt/.ccache"    \
        -v $distro-ccache:/mnt/.ccache  \
        -v $(pwd):/mnt/build            \
        -w "/mnt/build/project"         \
        $image [commands...]
```

Use shell functions defined in `functions.sh` file for more comfortable command
line interface usage. You can use images directly inside project directory.

For example, to prepare a package for <https://launchpad.net> use
`debuild-xenial -S -sa` inside a Debian project to create source `changes`
files. Then, go to upper directory, run `debsign project_0.1-1_source.changes`
and `dput ppa:user/project project_0.1-1_source.changes` to send to launchpad.
This example expects that your _launchpad_ account is already configured with
your public key and project has been created on _launchpad_ web site.

## HTTP/HTTPS proxy

`Makefile` will use predefined `http_proxy` and `https_proxy` found in shell
environment. Defines `docker_http_proxy` and, if also needed,
`docker_https_proxy` variables in shell environment if a different proxy should
be used for `docker build` (and `docker run` as defined in `functions.sh`). You
can also run `make HTTP_PROXY=... HTTPS_PROXY=...` to pass HTTP proxy
configuration on command line at `make` invocation.

## Limits

If you need to add more _apt_ repositories for custom packages, you need to
create a new docker image. Another solution is to bind mount extra files in
`/etc/apt/sources.list.d` directory (do not forget to bind PGP key for
repository too in `/etc/apt/trusted.gpg.d`).
