#!/bin/bash

# every10min_hourly.bash

# I use this script to copy data out of the DB into some partials.
# Then, it uses git to copy those partials to the Rails site.

cd /pt/s/rl/cj4svm/bin/
./hourly.bash
./every10min.bash

exit 0
