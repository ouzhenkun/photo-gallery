#!/bin/sh

rm -rf public
rm -rf node_modules
rm -rf bower_components

npm install
bower install
brunch watch --server
