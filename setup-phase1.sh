#!/bin/bash

dnf -y update
dnf -y install git ansible-core ansible vim-ansible python3-pip vim
ansible-galaxy role install arensb.firefox_profile
