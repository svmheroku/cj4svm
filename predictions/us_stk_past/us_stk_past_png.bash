#!/bin/bash

# us_stk_past_png.bash

# I use this script to create a png file for the splash page.
# The png file shows a weekly summary of DanBot performance.

# Assume that us_stk_past.sql (via index_spec.bash) has been run and CSV data landed here:
# /tmp/us_stk_sunday_l.txt
# /tmp/us_stk_sunday_s.txt

set -x
cd /pt/s/rl/cj/predictions/us_stk_past/

echo 'WK, WEEK_OF, RROWNUM, PREDICTION_COUNT, SUM_G24HR, CUM_SUM' > /tmp/us_stk_sunday_l.csv
echo 'WK, WEEK_OF, RROWNUM, PREDICTION_COUNT, SUM_G24HR, CUM_SUM' > /tmp/us_stk_sunday_s.csv

grep '^201' /tmp/us_stk_sunday_l.txt >> /tmp/us_stk_sunday_l.csv
grep '^201' /tmp/us_stk_sunday_s.txt >> /tmp/us_stk_sunday_s.csv

/usr/bin/R -f us_stk_past_png.r
cp /tmp/us_stk_sunday.png /pt/s/rl/svm/public/images/

exit 0


