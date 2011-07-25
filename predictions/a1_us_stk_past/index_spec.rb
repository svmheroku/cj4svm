#
# index_spec.rb
#

# Usage:
# bundle exec rspec index_spec.rb

# I use this script to generate a list of a-tags like this:
# Week: 2011-02-20 Through 2011-02-25

# The a-tags will land in this file:
# ./a1_us_stk_past/_us_stk_past_spool.html.erb
# which is a partial in this file:
# ./a1_us_stk_past/index.html.slim

# Each a-tag will take me to a set of reports for a specific week.
# The reports will show:
# - Action (buy or sell) summaries
# - Stock Ticker summaries

# Here is some haml which serves as a demo of what I want an a-tag to look like:
# %a(href="/a1_us_stk_past/a1_us_stk_past_wk2011_02_20")
#   Week: 2011-02-20 Through 2011-02-25

# I use a1_us_stk_past.sql to get the data.

require "../../spec_helper.rb"

describe "cj4svm helps me build both erb files which act as Rails templates" do

  it "rvm should give me the correct version of Ruby." do
    `which rvm`.should == "/home/oracle/bin/rvm\n"
    `rvm list`.should include "ruby-1.9.2-head [ x86_64 ]"
    `which ruby`.should include "/home/oracle/.rvm/rubies/ruby-1.9.2-head/bin/ruby"
    `ruby -v`.should include "ruby 1.9.2p246 (2011-05-30 revision 31821) [x86_64-linux]"
  end
##
  it "should copy then edit _us_stk_past_spool.html.erb" do
    `cat us_stk_past/_us_stk_past_spool.html.erb | sed '1,$s/us_stk_past/a1_us_stk_past/g'> a1_us_stk_past/_a1_us_stk_past_spool.html.erb`
    (Time.now - File.ctime("a1_us_stk_past/_a1_us_stk_past_spool.html.erb")).should < 2
  end
##

  it "Should Fill each of the partials with data." do
    # Start by pulling some syntax from the table us_stk_pst13 which was built by ../us_stk_past/us_stk_past.sql
    sql_output = `sqt @a1_us_stk_past_script_builder.sql`
    # Now edit the built script
    `grep a1_us_stk_past_week.sql /tmp/a1_us_stk_past_weeks.txt | grep -v cmd > /tmp/a1_us_stk_past_weeks.sql`
    `echo exit >> /tmp/a1_us_stk_past_weeks.sql`
    (Time.now - File.ctime("/tmp/a1_us_stk_past_weeks.sql")).should < 2
    # Now call the built script
    sql_output = `sqt @/tmp/a1_us_stk_past_weeks.sql`
    # Get a list of spool files created by sqlplus:
    glb = Dir.glob("/tmp/tmp_a1_us_stk_past_week_20*.lst").sort
    glb.size.should > 0
    glb.each{|fn|
      # For each file, make note of the date embedded in the filename.
      # The date should be a Sunday.
      # I use the date to identify a weeks worth of data:
      the_date = fn.sub(/tmp_a1_us_stk_past_week_/,'').sub(/.lst/,'').gsub(/-/,'_').sub(/\/.*\//,'')
      the_date.should match /^201._.._../
      # generate h4-element from the_date
      h4_element = "<h4>Week of: #{the_date}</h4>"
      # Next, I feed the file to Nokogiri so I can access HTML in the file:
      nokf = File.open(fn)
      html_doc = Nokogiri::HTML(nokf)
      nokf.close
      # Load some html into a string:
      some_html = html_doc.search("table.table_a1_us_stk_past_week").to_html
      some_html << "<br />"
      some_html << "<hr />"
      # I want a file for this URL pattern:
      # href="/a1_us_stk_past/a1_us_stk_past_wk2011_01_30"
      html_f = File.new("./a1_us_stk_past/a1_us_stk_past_wk#{the_date}.html.erb", "w")
      # Fill the file with HTML which I had obtained from sqlplus:
      html_f.puts h4_element + some_html
      p "#{html_f.path} File written"
      html_f.close
    } # glb.each
  end
##
end
