#!/bin/bash

# every10min_us_stk.bash

# I use this script to copy data out of the DB into some partials.
# Then, it uses git to copy those partials to the Rails site.

# Start with stocks, Copy data from remote DBs to local DB.
# Then, copy data out of local DB into some partials:
cd /pt/s/rl/cj4svm/predictions/us_stk_new/
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
