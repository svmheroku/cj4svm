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

  it "Should run the sql script a1_us_stk_past.sql" do
    `which sqt`.should == "/pt/s/rl/cj4svm/bin/sqt\n"

    a1_us_stk_past_sql = "/pt/s/rl/cj4svm/predictions/a1_us_stk_past/a1_us_stk_past.sql"
    dglb = Dir.glob(a1_us_stk_past_sql)
    dglb.should == ["/pt/s/rl/cj4svm/predictions/a1_us_stk_past/a1_us_stk_past.sql"]
    File.size(a1_us_stk_past_sql).should == 3314

    # The script should have an exit so it will not hang:
    `grep exit a1_us_stk_past.sql`.should match /^exit\n/
    time0 = Time.now
    sql_output = `sqt @a1_us_stk_past.sql`
    # The sql script should need at least 3 seconds to finish:
    (Time.now - time0).should > 3
    sql_output.should_not match /^ERROR/
    sql_output.should match /^Connected to:\n/
    sql_output.should match /^Oracle Database 11g Enterprise Edition /
    sql_output.should match /a1_us_stk_past.sql/
    sql_output.should match /^Recyclebin purged/
    sql_output.should match /^Disconnected from Oracle Database 11g /
    # I should see 2 recent spool files:
    (Time.now - File.ctime("/tmp/_a1_us_stk_past_spool.html.erb")).should < 9
    (Time.now - File.ctime("/tmp/a1_us_stk_past_week.txt")).should < 9
    # Do a small edit:
    `grep -v 'rows selected' /tmp/_a1_us_stk_past_spool.html.erb > /tmp/tmp_a1_us_stk.html`
    (Time.now - File.ctime("/tmp/tmp_a1_us_stk.html")).should < 2
  end
##

  # Use Nokogiri to massage the HTML in tmp_a1_us_stk.html and redirect it into the partial full of a-tags.
  # The partial is here:
  # ./a1_us_stk_past/_a1_us_stk_past_spool.html.erb
  # The partial is rendered in this file: 
  # ./a1_us_stk_past/index.html.slim

  it "Should Use Nokogiri to transform tmp_a1_us_stk.html into the partial full of a-tags." do
    myf = File.open("/tmp/tmp_a1_us_stk.html")
    html_doc = Nokogiri::HTML(myf)
    myf.close
    td_elems = html_doc.search("td")
    # I should see at least 1 row of history.
    td_elems.size.should > 0

    # Insert links inside each td-element:
    td_elems.each{|td|
      # Change Week: 2011-01-31 Through 2011-02-04
      # to
      # /a1_us_stk_past/a1_us_stk_past_wk2011_01_31
      hhref_tail = td.inner_html.gsub(/\n/,'').sub(/Week: /,'').sub(/ Through .*$/,'').gsub(/-/,'_')
      hhref="/a1_us_stk_past/a1_us_stk_past_wk#{hhref_tail}"
      td.inner_html = "<a href='#{hhref}'>#{td.inner_html.gsub(/\n/,'')}</a>"
    }
    # Im done, write it to the Rails partial:
    fhw = File.open("./a1_us_stk_past/_a1_us_stk_past_spool.html.erb","w")
    fhw.write(html_doc.search("table#table_a1_us_stk_past").to_html)
    fhw.close
  end
##

  it "Should Fill each of the partials with data." do
    # Start by pulling some syntax out of a1_us_stk_past_week.txt
    # which was created by my call to a1_us_stk_past.sql
    `grep a1_us_stk_past_week.sql /tmp/a1_us_stk_past_week.txt > /tmp/run_a1_us_stk_past_week.sql`

    `echo exit >> /tmp/run_a1_us_stk_past_week.sql`
    (Time.now - File.ctime("/tmp/run_a1_us_stk_past_week.sql")).should < 2
    # I should see more than 5 SQL calls in /tmp/run_a1_us_stk_past_week.sql:
    `cat /tmp/run_a1_us_stk_past_week.sql|wc -l`.chomp.to_i.should > 5
    p "Now calling sqlplus:"
    p "sqt @/tmp/run_a1_us_stk_past_week.sql"
    sql_output = `sqt @/tmp/run_a1_us_stk_past_week.sql`
    sql_output.should match /^Connected to:\n/
    sql_output.should match /^Oracle Database 11g Enterprise Edition /
    sql_output.should match /a1_us_stk_past_week.sql/
    sql_output.should match /rows selected/
    sql_output.should match /^Disconnected from Oracle Database 11g /

    # I start by getting a list of spool files created by sqlplus:
    glb = Dir.glob("/tmp/tmp_a1_us_stk_past_week_20*.lst").sort
    glb.size.should > 4

    glb.each{|fn|
      # Make a note of the filename:
      p "Input file is #{fn}"
      # For each file, make note of the date embedded in the filename.
      # The date should usually be a Monday.
      # I use the date to identify a weeks worth of data:
      the_date = fn.sub(/tmp_a1_us_stk_past_week_/,'').sub(/.lst/,'').gsub(/-/,'_').sub(/\/.*\//,'')
      the_date.should match /^201._.._../

      # generate bread_crumbs from the_date
      bread_crumbs = "Site Map > Predictions > US Stocks > Past US Stock Predictions #{the_date}"
      site_map    = '<a href="/site_map">Site Map</a>'
      predictions = '<a href="/predictions">Predictions</a>'
      a1_us_stk       = '<a href="/predictions/a1_us_stk">US Stocks</a>'
      past_a1_us_stk_predictions = '<a href="/a1_us_stk_past">Past US Stock Predictions</a>'
      bread_crumbs = "#{site_map} > #{predictions} > #{a1_us_stk} > #{past_a1_us_stk_predictions} > Week of: #{the_date}"

      # generate h4-element from the_date
      h4_element = "<h4>Week of: #{the_date}</h4>"

      # Next, I feed the file to Nokogiri so I can access HTML in the file:
      nokf = File.open(fn)
      html_doc = Nokogiri::HTML(nokf)
      nokf.close

      # I want a file for this URL pattern:
      # href="/predictions/a1_us_stk_past_wk2011_01_30"
      html_f = File.new("./a1_us_stk_past/a1_us_stk_past_wk#{the_date}.html.erb", "w")

      # Maybe I will find a table_element in that file which interests me.
      table_elem = html_doc.search("table")[0]
      if table_elem.nil?
        some_html = "No Predictions Were Calculated For This Week."
        html_f.puts bread_crumbs + h4_element + some_html
        html_f.close
      else
        # Generate some a-elements from th-elements.
        th_elems = table_elem.search("th")

        th_elems.each {|elm| 
          ei_h =   elm.inner_html
          ei_hclass = ei_h.gsub(/\n/,'').gsub(/\<br\>/,'').gsub(/\<br \/>/,'').gsub(/ /,'').downcase
          elm.inner_html = "<a href='#' class='#{ei_hclass}'>#{ei_h}</a>"
        }

        # Load some html into a string:
        some_html = html_doc.search("table.table_a1_us_stk_past_week").to_html
        some_html << "<br />"
        some_html << "<hr />"
        # Fill the file with HTML which I had obtained from sqlplus:
        html_f.puts bread_crumbs + h4_element + some_html
        html_f.close
      end # if table_elem.nil?
      p "#{html_f.path} File written"
    } # glb.each{|fn|
  end # it "Should Fill each of the partials with data." do
##

end
