#!/bin/bash

# expdp_fx.bash

# I use this script to expdp a table full of fx data.

. /pt/s/rl/cj4svm/.cj

set -x
mv fx.dpdmp /tmp/
expdp trade/t dumpfile=fx.dpdmp tables=di5min,svm62scores
