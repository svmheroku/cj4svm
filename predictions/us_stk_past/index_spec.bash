#!/bin/bash

# index_spec.bash

# I use this script as a shell wrapper for index_spec.rb

. /pt/s/rl/cj4svm/.cj

# cd to the right place
cd $CJ4SVM/predictions/us_stk_past/
echo now at:
pwd

# Next, I expdp/impdp 2 new tables:
# echo 'ssh z3 /pt/s/rl/cj4svm/predictions/us_stk_past/expdp_past.bash'
# ssh z3 /pt/s/rl/cj4svm/predictions/us_stk_past/expdp_past.bash
# rsync -vz z3:dpdump/us_stk_past.dpdmp ~/dpdump/
# # For the 1st impdp use: table_exists_action=replace
# echo 'impdp trade/t table_exists_action=replace dumpfile=us_stk_past.dpdmp'
# impdp trade/t table_exists_action=replace dumpfile=us_stk_past.dpdmp tables=us_stk_pst21,stkscores21

# If/when I impdp from other hosts,
# I need to direct that: table_exists_action=append
# so I dont clobber data from the 1st import.

# The new data will be merged later by:
# us_stk_past.sql
# which is called by index_spec.rb.

# I have commented out lines above which I no longer use.
# They have been replaced by the script below:
./ibs5min_cpy.bash

bundle exec rspec index_spec.rb

exit 0
