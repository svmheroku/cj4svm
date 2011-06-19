#!/bin/bash

# index_spec.bash

# I use this script as a shell wrapper for index_spec.rb

. /pt/s/rl/cj4svm/.cj

# cd to the right place
cd $CJ4SVM/predictions/us_stk_past/
echo now at:
pwd

# Gather the data I need into 2 tables:
# us_stk_pst21
# stkscores21
# First I re-create the 2 tables:
sqt>/tmp/expdp_us_stk_past_prep.txt<<EOF
@expdp_us_stk_past_prep.sql
EOF

cat /tmp/expdp_us_stk_past_prep.txt

# Next, I append data to the 2 tables:
echo 'ssh z3 /pt/s/rl/cj4svm/predictions/us_stk_past/expdp_past.bash'
ssh z3 /pt/s/rl/cj4svm/predictions/us_stk_past/expdp_past.bash

rsync -vz z3:dpdump/us_stk_past.dpdmp ~/dpdump/
echo 'impdp trade/t table_exists_action=append dumpfile=us_stk_past.dpdmp'
impdp trade/t table_exists_action=append dumpfile=us_stk_past.dpdmp

# The new data will be merged later by:
# us_stk_past.sql
# which is called by index_spec.rb.

exit

bundle exec rspec index_spec.rb
