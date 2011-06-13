#!/bin/bash

# every10min.bash

# I use this script to copy data out of the DB into some partials.
# Then, it uses git to copy those partials to the Rails site.

# Use expdp to copy data from active-fx-db into local-db:
ssh z /pt/s/rl/cj4svm/bin/expdp_fx.bash
rsync z:dpdmp/fx.dpdmp ~/dpdmp/
impdp trade/t table_exists_action=replace dumpfile=fx.dpdmp

cd /pt/s/rl/cj4svm/predictions/fx_new/
./index_spec.bash

set -x

cd /pt/s/rl/svm/
git add .
git commit -a -v -m every10min.bash-commit
git push origin master
git push heroku master

