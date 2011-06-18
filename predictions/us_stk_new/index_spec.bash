#!/bin/bash

# index_spec.bash

# I use this script as a shell wrapper for index_spec.rb

. /pt/s/rl/cj4svm/.cj

# cd to the right place
echo 'cd $CJ4SVM/predictions/us_stk_new/'
cd $CJ4SVM/predictions/us_stk_new/
echo now at:
pwd

# Gather the data I need into 2 tables:
# us_stk_pst17
# stkscores17
# First I re-create the 2 tables:
sqt>/tmp/expdp_us_stk_new_prep.txt<<EOF
@expdp_us_stk_new_prep.sql
EOF
# Next, I append data to the 2 tables:
echo 'ssh z3 /pt/s/rl/cj4svm/predictions/us_stk_new/expdp_new.bash'
ssh z3 /pt/s/rl/cj4svm/predictions/us_stk_new/expdp_new.bash
rsync -vz z3:dpdump/us_stk_new.dpdmp ~/dpdump/
echo 'impdp trade/t table_exists_action=append dumpfile=us_stk_new.dpdmp'
impdp trade/t table_exists_action=append dumpfile=us_stk_new.dpdmp

# The new data will be merged later by:
# us_stk_pst13.sql
# which is called by index_spec.rb.

echo 'bundle exec rspec index_spec.rb'
bundle exec rspec index_spec.rb

exit 0
