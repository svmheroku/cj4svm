#!/bin/bash

# wgetit.bash

# I use this script to load the Varnish-cache with some links.

cd /tmp/

rm -f index.html index.html.*
rm -f predictions fx us_stk fx_new fx_past us_stk_new us_stk_past contact blog site_map leadership_team glossary faq
rm -f books tos about index
rm -f predictions.? fx.? us_stk.? fx_new.? fx_past.? us_stk_new.? us_stk_past.? contact.? blog.? site_map.?
rm -f glossary.?  leadership_team.? books.? tos.? about.? index.? a1_fx_past.* faq.*

wget http://bot4.us

wget http://bot4.us/predictions

wget http://bot4.us/predictions/fx
wget http://bot4.us/predictions/us_stk

wget http://bot4.us/fx_new
wget http://bot4.us/fx_past

wget http://bot4.us/us_stk_new
wget http://bot4.us/us_stk_past

wget http://bot4.us/blog
wget http://bot4.us/books
wget http://bot4.us/contact
wget http://bot4.us/glossary
wget http://bot4.us/leadership_team
wget http://bot4.us/site_map
wget http://bot4.us/tos

wget http://bot4.us/a1/
wget http://bot4.us/a1/about
wget http://bot4.us/a1/blog
wget http://bot4.us/a1/fx
wget http://bot4.us/a1/faq
wget http://bot4.us/a1/us_stk
wget http://bot4.us/a1/books
wget http://bot4.us/a1/contact
wget http://bot4.us/a1/glossary
wget http://bot4.us/a1/leadership_team
wget http://bot4.us/a1/predictions
wget http://bot4.us/a1/tos
wget http://bot4.us/a1_fx_past

exit 0
