#!/bin/bash

# every10min.bash

# I use this script to copy data out of the DB into some partials.
# Then, it uses git to copy those partials to the Rails site.

cd /pt/s/rl/cj4svm/predictions/fx_new/
./index_spec.bash

set -x

cd /pt/s/rl/svm/
git add .
git commit -a -v -m every10min.bash-commit
git push origin master
git push heroku master

