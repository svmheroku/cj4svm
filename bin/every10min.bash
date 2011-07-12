#!/bin/bash

# every10min.bash

# I use this script to copy data out of the DB into some partials.
# Then, it uses git to copy those partials to the Rails site.

# If the /tmp/script_e10_busy.txt exists, I should exit

if [ -e "/tmp/script_e10_busy.txt" ]; then
   echo The /tmp/script_e10_busy.txt exists.
   echo If the /tmp/script_e10_busy.txt exists, I should exit.
   exit
else
  date > /tmp/script_e10_busy.txt
  cd /pt/s/rl/cj4svm/bin/
  ./every10min_fx.bash
  ./every10min_us_stk.bash
  rm -f /tmp/script_e10_busy.txt
fi

exit 0
