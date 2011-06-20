#!/bin/bash

# wgetit.bash

# I use this script to load the Varnish-cache with some links.

cd /tmp/

rm -f predictions fx us_stk fx_new fx_past us_stk_new us_stk_past
rm -f predictions.? fx.? us_stk.? fx_new.? fx_past.? us_stk_new.? us_stk_past.?

wget http://roboluck.com/predictions

wget http://roboluck.com/predictions/fx
wget http://roboluck.com/predictions/us_stk

wget http://roboluck.com/fx_new
wget http://roboluck.com/fx_past

wget http://roboluck.com/us_stk_new
wget http://roboluck.com/us_stk_past

exit 0
