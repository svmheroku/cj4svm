#!/bin/bash

# every10min_us_stk.bash

# I use this script to copy data out of the DB into some partials.
# Then, it uses git to copy those partials to the Rails site.

# If the /tmp/script_e10_fx_busy.txt exists, I should exit.


if [ -e "/tmp/script_e10_us_stk_busy.txt" ]; then
   echo The /tmp/script_e10_us_stk_busy.txt exists.
   echo If the /tmp/script_e10_us_stk_busy.txt exists, I should exit.
   exit
else
  date > /tmp/script_e10_us_stk_busy.txt

  # Start with stocks, Copy data from remote DBs to local DB.
  # Then, copy data out of local DB into some partials:
  cd /pt/s/rl/cj4svm/predictions/us_stk_new/
  ./index_spec.bash
  cd /pt/s/rl/cj4svm/predictions/us_stk_c/
  ./index_spec.bash

  # Now copy the new data to the Rails site:

  set -x

  cd /pt/s/rl/svm/
  git add .
  git commit -a -v -m every10min.bash-commit
  git push heroku master
  git push origin master &

  # Now, pull the new data into the Varnish-cache at the server:
  /pt/s/rl/cj4svm/bin/wgetit.bash

  rm -f  /tmp/script_e10_us_stk_busy.txt
fi

exit 0
