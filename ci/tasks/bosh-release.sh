#!/bin/sh
set -e -x

gem install bosh_cli --no-ri --no-rdoc

cd config-server
bosh create release --force --with-tarball --name config-server --version acceptance

ls -al ../
echo "====================================="
ls -al /

cd ..
cp config-server/dev_releases/config-server/config-server-acceptance.tgz bosh-release/

ls -al bosh-release


