#!/usr/bin/env bash

sudo apt-add-repository --yes ppa:ansible/ansible
sudo apt-get update
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install --yes \
    software-properties-common \
    ansible \
    python-jmespath \
&& ansible --version
