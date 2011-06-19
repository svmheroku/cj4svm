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

bundle exec rspec index_spec.rb
