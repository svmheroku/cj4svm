#!/bin/bash

# expdp_new.bash

# I use this script to expdp new stock data out of the db.
# My intention is to then impdp-append the new data 
# into a target db after I rsync the dpdmp file to the target host.

# Usage: ssh sourcehost /pt/s/rl/cj4svm/predictions/us_stk_new/expdp_new.bash
#        rsync sourcehost:dpdump/us_stk_new.dpdmp ~/dpdump/
#        impdp trade/t table_exists_action=append dumpfile=us_stk_new.dpdmp

. /pt/s/rl/cj4svm/.cj

# cd to the right place
cd $CJ4SVM/predictions/us_stk_new/
echo now at:
pwd

# Make a copy of the data which is suitable for my needs.
# I use expdp_us_stk_new_prep.sql for 2 purposes:
# 1. To prep data for expdp
# 2. To create tables at the destination DB for use by us_stk_pst13.sql
sqt>/tmp/expdp_us_stk_new_prep.txt<<EOF
@expdp_us_stk_new_prep.sql
EOF

set -x
# sqlplus work ok?:
cat /tmp/expdp_us_stk_new_prep.txt

# Make way for the new us_stk_new.dpdmp file:
touch ~/dpdump/us_stk_new.dpdmp
mv ~/dpdump/us_stk_new.dpdmp /tmp/

# do it:
expdp trade/t dumpfile=us_stk_new.dpdmp tables=us_stk_pst17,stkscores17

exit 0
