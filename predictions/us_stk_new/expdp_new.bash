#!/bin/bash

# expdp_new.bash

# I use this script to expdp new stock data out of the db.

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

sqt>/tmp/qry_us_stk_pst17.txt<<EOF
@qry_us_stk_pst17.sql
EOF
cat /tmp/qry_us_stk_pst17.txt

exit 0
