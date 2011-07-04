#!/bin/bash

# wgetit.bash

# I use this script to load the Varnish-cache with some links.

cd /tmp/

rm -f index.html
rm -f predictions fx us_stk fx_new fx_past us_stk_new us_stk_past contact blog site_map leadership_team glossary
rm -f predictions.? fx.? us_stk.? fx_new.? fx_past.? us_stk_new.? us_stk_past.? contact.? blog.? site_map.?
rm -f glossary.?  leadership_team.?

wget http://bot4.us

wget http://bot4.us/predictions

wget http://bot4.us/predictions/fx
wget http://bot4.us/predictions/us_stk

wget http://bot4.us/fx_new
wget http://bot4.us/fx_past

wget http://bot4.us/us_stk_new
wget http://bot4.us/us_stk_past

wget http://bot4.us/contact
wget http://bot4.us/blog
wget http://bot4.us/site_map
wget http://bot4.us/leadership_team
wget http://bot4.us/glossary

exit 0
