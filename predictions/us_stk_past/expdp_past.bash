#!/bin/bash

# expdp_past.bash

# I use this script to expdp new stock data out of the db.
# My intention is to then impdp-append the new data 
# into a target db after I rsync the dpdmp file to the target host.

# Usage: ssh sourcehost /pt/s/rl/cj4svm/predictions/us_stk_past/expdp_past.bash
#        rsync sourcehost:dpdump/us_stk_past.dpdmp ~/dpdump/
#        impdp trade/t table_exists_action=append dumpfile=us_stk_past.dpdmp

. /pt/s/rl/cj4svm/.cj

# cd to the right place
echo 'cd $CJ4SVM/predictions/us_stk_past/'
cd $CJ4SVM/predictions/us_stk_past/
echo now at:
pwd

# Make a copy of the data which is suitable for my needs.
# I use expdp_us_stk_past_prep.sql for 2 purposes:
# 1. To prep data for expdp
# 2. To create tables at the destination DB for use by us_stk_past.sql
# This data is stored in 2 tables:
# us_stk_pst21
# stkscores21
echo Calling:
echo 'sqlplus @expdp_us_stk_past_prep.sql'
sqt>/tmp/expdp_us_stk_past_prep.txt<<EOF
@expdp_us_stk_past_prep.sql
EOF

# sqlplus work ok?:
cat /tmp/expdp_us_stk_past_prep.txt

# Make way for the new us_stk_past.dpdmp file:
touch ~/dpdump/us_stk_past.dpdmp
mv ~/dpdump/us_stk_past.dpdmp /tmp/

# do it:
echo 'expdp trade/t dumpfile=us_stk_past.dpdmp tables=us_stk_pst21,stkscores21'
expdp trade/t dumpfile=us_stk_past.dpdmp tables=us_stk_pst21,stkscores21

exit 0
