#
# index_spec.rb
#

# Usage:
# bundle exec rspec index_spec.rb

# I use this script to generate a list of a-tags like this:
# Week: 2011-02-20 Through 2011-02-25

# The a-tags will land in this file:
# ./a1_fx_past/_fx_past_spool.html.erb
# which is a partial in this file:
# ./a1_fx_past/index.html.slim

# Each a-tag will take me to a set of reports for a specific week.
# The reports will show:
# - Action (buy or sell) summaries
# - pair summaries

# Here is some haml which serves as a demo of what I want an a-tag to look like:
# %a(href="/a1_fx_past/fx_past_wk2011_02_20")
#   Week: 2011-02-20 Through 2011-02-25

require "../../spec_helper.rb"

describe "cj4svm helps me build both erb files and haml files which act as Rails templates" do

  it "rvm should give me the correct version of Ruby." do
    `which rvm`.should == "/home/oracle/bin/rvm\n"
    `rvm list`.should include "ruby-1.9.2-head [ x86_64 ]"
    `which ruby`.should include "/home/oracle/.rvm/rubies/ruby-1.9.2-head/bin/ruby"
    `ruby -v`.should include "ruby 1.9.2p246 (2011-05-30 revision 31821) [x86_64-linux]"
  end
##

  it "should copy then edit _fx_past_spool.html.erb" do
    `cat fx_past/_fx_past_spool.html.erb | sed '1,$s,/fx_past/,/a1_fx_past/,'> a1_fx_past/_fx_past_spool.html.erb`
    (Time.now - File.ctime("a1_fx_past/_fx_past_spool.html.erb")).should < 2
  end
##
end
