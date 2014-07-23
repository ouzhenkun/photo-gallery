#!/bin/sh

brunch build
./node_modules/karma/bin/karma start test/karma.conf.js
