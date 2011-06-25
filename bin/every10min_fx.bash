#!/bin/bash

# every10min_fx.bash

# I use this script to copy data out of the DB into some partials.
# Then, it uses git to copy those partials to the Rails site.

# Now for Forex,
# use expdp to copy data from active-fx-db into local-db:
ssh z /pt/s/rl/cj4svm/bin/expdp_fx.bash

rsync z:dpdump/fx.dpdmp ~/dpdump/
impdp trade/t table_exists_action=replace dumpfile=fx.dpdmp

# Copy data out of the DB into some partials:
cd /pt/s/rl/cj4svm/predictions/fx_new/
./index_spec.bash

# Now copy the new data to the Rails site:

set -x

cd /pt/s/rl/svm/
git add .
git commit -a -v -m every10min.bash-commit
git push origin master
git push heroku master

# Now, pull the new data into the Varnish-cache at the server:
/pt/s/rl/cj4svm/bin/wgetit.bash

exit 0
