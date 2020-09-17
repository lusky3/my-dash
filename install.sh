#!/bin/bash
#
# Description: Build my-dash
#

git clone https://github.com/krestaino/my-dash.git /opt/my-dash

cd /opt/my-dash

yarn setup

yarn build

yarn serve
