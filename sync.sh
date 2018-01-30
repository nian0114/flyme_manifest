#!/bin/bash
#
# Auto maker Script for FlymeOS patchrom
# Script Start

x=`date +%Y`
y=`date +.%-m.%-d`
z=${x: -1:1}
version=$z$y
PORT_ROOT='/Volumes/sources/flyme_n'


cd $PORT_ROOT/build
git add -A
git commit -m "Update Tools"
git push origin mac-n
cd $PORT_ROOT/tools
git add -A
git commit -m "Update Tools"
git push origin mac-n
rm -rf $PORT_ROOT/flyme/release $PORT_ROOT/build $PORT_ROOT/tools

cd $PORT_ROOT/
repo sync
cd $PORT_ROOT/build
git checkout mac-n
cd $PORT_ROOT/tools
git checkout mac-n
cd $PORT_ROOT/
