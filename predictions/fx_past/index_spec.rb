#
# index_spec.rb
#

# Usage:
# bundle exec rspec index_spec.rb

# I use this script to generate a list of a-tags like this:
# Week: 2011-02-20 Through 2011-02-25

# The a-tags will land in this file:
# ./fx_past/_fx_past_spool.html.erb
# which is a partial in this file:
# ./fx_past/index.haml

# Each a-tag will take me to a set of reports for a specific week.
# The reports will show:
# - Action (buy or sell) summaries
# - pair summaries
# - Details of all predictions

# Here is some haml which serves as a demo of what I want an a-tag to look like:
# %a(href="/fx_past/fx_past_wk2011_02_20")
#   Week: 2011-02-20 Through 2011-02-25

# I use fx_past.sql to get the data via a join of 3 types of tables:
# prices,gains
# gatt-scores
# gattn-scores

require "../../spec_helper.rb"

describe "cj4svm helps me build both erb files and haml files which act as Rails templates" do

  it "rvm should give me the correct version of Ruby and correct set of Gems" do
    `which rvm`.should == "/home/oracle/bin/rvm\n"
    `rvm list`.should include "ruby-1.9.2-head [ x86_64 ]"
    `which ruby`.should include "/home/oracle/.rvm/rubies/ruby-1.9.2-head/bin/ruby"
    `ruby -v`.should include "ruby 1.9.2p246 (2011-05-30 revision 31821) [x86_64-linux]"
  end
##


  it "Should run the sql script fx_past.sql" do
    `which sqt`.should == "/pt/s/rl/cj4svm/bin/sqt\n"
    `/bin/ls -l fx_past.sql`.should == "-rw-r--r-- 1 oracle oinstall 2938 2011-06-05 21:57 fx_past.sql\n"
    # The script should have an exit so it will not hang:
    `grep exit fx_past.sql`.should match /^exit\n/
    time0 = Time.now
    sql_output = `sqt @fx_past.sql`
    # The sql script should need at least 3 seconds to finish:
    (Time.now - time0).should > 2
    sql_output.should match /^Connected to:\n/
    sql_output.should match /^Oracle Database 11g Enterprise Edition /
    sql_output.should match /fx_past.sql/
    sql_output.should match /^Recyclebin purged/
    sql_output.should match /^@fx_past_week.sql 2011-05-08/
    sql_output.should match /^Disconnected from Oracle Database 11g /
    # I should see 2 recent spool files:
    (Time.now - File.ctime("/tmp/_fx_past_spool.html.erb")).should < 9
    (Time.now - File.ctime("/tmp/fx_past_week.txt")).should < 9
    # Do a small edit:
    `grep -v 'rows selected' /tmp/_fx_past_spool.html.erb > /tmp/tmp.html`
    (Time.now - File.ctime("/tmp/tmp.html")).should < 2
  end
##

end

