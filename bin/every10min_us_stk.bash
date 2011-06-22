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
cd /tmp/

rm -f predictions fx us_stk fx_new fx_past us_stk_new us_stk_past
rm -f predictions.? fx.? us_stk.? fx_new.? fx_past.? us_stk_new.? us_stk_past.?

wget http://roboluck.com/predictions

wget http://roboluck.com/predictions/fx
wget http://roboluck.com/predictions/us_stk

wget http://roboluck.com/fx_new
wget http://roboluck.com/fx_past

wget http://roboluck.com/us_stk_new
wget http://roboluck.com/us_stk_past

exit 0
