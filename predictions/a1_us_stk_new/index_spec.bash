#!/bin/bash

# index_spec.bash

# I use this script as a shell wrapper for index_spec.rb

. /pt/s/rl/cj4svm/.cj

# cd to the right place
cd $CJ4SVM/predictions/a1_us_stk_new/
echo now at:
pwd

bundle exec rspec index_spec.rb
# bundle exec rspec -e Ruby index_spec.rb

exit 0
