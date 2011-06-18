#!/bin/bash

# index_spec.bash

# I use this script as a shell wrapper for index_spec.rb

. /pt/s/rl/cj4svm/.cj

# cd to the right place
cd $CJ4SVM/predictions/us_stk_new/
echo now at:
pwd

# Gather the data I need into 2 tables:
# us_stk_pst17
# stkscores17

ssh z3 /pt/s/rl/cj4svm/predictions/us_stk_new/expdp_new.bash

# debug
exit
# debug
rsync sourcehost:dpdump/us_stk_new.dpdmp ~/dpdump/
impdp trade/t table_exists_action=append dumpfile=us_stk_new.dpdmp

# The new data will be merged later by:
# us_stk_pst13.sql

# debug
exit
# debug
bundle exec rspec index_spec.rb
