#!/bin/bash

#Setting Minimal hiera for QuarterMaster
cp -R /etc/puppet/modules/quartermaster/files/hiera /etc/puppet/hiera
echo "creating symlink for from ./hiera.yaml to /etc/puppet/hiera.yaml"
ln -s /etc/puppet/hiera/hiera.yaml /etc/puppet/hiera.yaml

