#!/bin/bash

# every10min.bash

# I use this script to copy data out of the DB into some partials.
# Then, it uses git to copy those partials to the Rails site.

cd /pt/s/rl/cj4svm/bin/
./every10min_fx.bash
./every10min_us_stk.bash

exit 0
