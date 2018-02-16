#!/usr/bin/env bash
set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=ppouliot
# image name
IMAGE=puppet-quartermaster
VERSION=`cat VERSION`
export USERNAME
export IMAGE
export VERSION
-d () {
  docker-compose build --no-cache --force-rm
}
-v () {
 vagrant up
}
echo "USAGE: -d Docker -v Vagrant"
$1
