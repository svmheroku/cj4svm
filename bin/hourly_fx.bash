#!/bin/bash

# hourly_fx.bash

# I use this script to copy data out of the DB into some partials.
# Then, it uses git to copy those partials to the Rails site.

# If the /tmp/script_hourly_fx_busy.txt exists, I should exit.

if [ -e "/tmp/script_hourly_fx_busy.txt" ]; then
   echo The /tmp/script_hourly_fx_busy.txt exists.
   echo If the /tmp/script_hourly_fx_busy.txt exists, I should exit.
   exit
else
  date > /tmp/script_hourly_fx_busy.txt

  cd /pt/s/rl/cj4svm/
  . ./.cj

  # Now for Forex,
  # use expdp to copy data from active-fx-db into local-db:
  ssh z /pt/s/rl/cj4svm/bin/expdp_fx.bash

  rsync z:dpdump/fx.dpdmp ~/dpdump/
  impdp trade/t table_exists_action=replace dumpfile=fx.dpdmp

  # Copy data out of the DB into some partials:
  cd /pt/s/rl/cj4svm/predictions/fx_past/
  ./index_spec.bash

  # Now copy the new data to the Rails site:

  set -x

  cd /pt/s/rl/svm/
  git add .
  git commit -a -v -m hourly.bash-commit
  git push heroku master
  git push origin master &

  # Now, pull the new data into the Varnish-cache at the server:
  /pt/s/rl/cj4svm/bin/wgetit.bash &

  rm -f /tmp/script_hourly_fx_busy.txt

fi
exit 0
