#!/bin/bash

# fx_past_png.bash

# I use this script to create a png file for the splash page.
# The png file shows a weekly summary of fx-DanBot performance.

# Assume that fx_past.sql (via index_spec.bash) has been run and CSV data landed here:
# /tmp/fx_sunday_l.txt
# /tmp/fx_sunday_s.txt

set -x
cd /pt/s/rl/cj/predictions/fx_past/

echo 'WK, WEEK_OF, RROWNUM, PREDICTION_COUNT, SUM_G24HR, CUM_SUM' > /tmp/fx_sunday_l.csv
echo 'WK, WEEK_OF, RROWNUM, PREDICTION_COUNT, SUM_G24HR, CUM_SUM' > /tmp/fx_sunday_s.csv

grep '^201' /tmp/fx_sunday_l.txt >> /tmp/fx_sunday_l.csv
grep '^201' /tmp/fx_sunday_s.txt >> /tmp/fx_sunday_s.csv

/usr/bin/R -f fx_past_png.r
cp /tmp/fx_sunday.png /pt/s/rl/svm/public/images/

exit 0


