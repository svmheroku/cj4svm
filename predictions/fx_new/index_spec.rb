#
# index_spec.rb
#

# Usage:
# bundle exec rspec index_spec.rb

# I use this script to generate a partial full of new predictions.

require "../../spec_helper.rb"

describe "cj helps me build both erb files and haml files which act as Rails templates" do

  it "rvm should give me the correct version of Ruby." do
    `which rvm`.should == "/home/oracle/bin/rvm\n"
    `rvm list`.should include "ruby-1.9.2-head [ x86_64 ]"
    `which ruby`.should include "/home/oracle/.rvm/rubies/ruby-1.9.2-head/bin/ruby"
    `ruby -v`.should include "ruby 1.9.2p246 (2011-05-30 revision 31821) [x86_64-linux]"
  end
##

  it "Should run the sql script fx_new.sql" do
    `which sqt`.should == "/pt/s/rl/cj4svm/bin/sqt\n"
    # The script should have an exit so it will not hang:
    `grep exit fx_new.sql`.should match /^exit\n/
    time0 = Time.now
    sql_output = `sqt @fx_new.sql`
    # The sql script should need at least 3 seconds to finish:
    # (Time.now - time0).should > 2
    sql_output.should match /^Connected to:\n/
    sql_output.should match /^Oracle Database 11g Enterprise Edition /
    sql_output.should match /fx_new.sql/
    sql_output.should match /^Disconnected from Oracle Database 11g /
    # I should see a recent spool file:
    (Time.now - File.ctime("/tmp/_fx_new_spool.html.erb")).should < 9
    # Do a small edit:
    `grep -v 'rows selected' /tmp/_fx_new_spool.html.erb > /tmp/fx_new.html`
    (Time.now - File.ctime("/tmp/fx_new.html")).should < 2
  end
##

  # I Use Nokogiri to massage the HTML in fx_new.html and redirect it into a partial holding a table-element.
  # The partial is here:
  # ./fx_new/_fx_new_spool.html.erb
  # The partial is rendered in this file: 
  # ./fx_new/index.haml

  it "Uses Nokogiri to massage fx_new.html into a partial holding a table-element." do
    myf = File.open("/tmp/fx_new.html")
    html_doc = Nokogiri::HTML(myf)
    myf.close
    table_elem = html_doc.search("table.table_fx_new").first
    html4partial = "No predictions have been calculated for this time period."
    unless table_elem.nil?
      # Generate some a-elements from th-elements.
      th_elems = table_elem.search("th")
      th_elems.each {|elm| 
        ei_h =   elm.inner_html
        ei_hclass = ei_h.gsub(/\n/,'').gsub(/\<br\>/,'').gsub(/\<br \/>/,'').gsub(/ /,'').gsub(/\(/,'').gsub(/\)/,'').downcase
        elm.inner_html = "<a href='#' class='#{ei_hclass}'>#{ei_h}</a>"
      }

      # Generate some a-elements from td-elements containing pair-symbols.
      td_elems = table_elem.search("td")
      # Look at every td-element and see if it matches a simple reg-exp for a string of 7 chars:
      td_elems.each {|elm|
        ei_h = elm.inner_html
        if ei_h =~ /(\w\w\w_\w\w\w)/
          mypair1 = $1
          mypair2 = mypair1.sub(/_/,'')
          elm.inner_html = "<a target='y' href='http://finance.yahoo.com/q?s=#{mypair2}=X'>#{mypair1}</a>"
        end
      }

      # Overwrite the default:
      html4partial = table_elem.to_html
    end

    # Im done, write it to the Rails partial:
    partial_fn = "./fx_new/_fx_new_spool.html.erb"
    fhw = File.open(partial_fn,"w")
    fhw.write(html4partial)
    fhw.close
    File.size(partial_fn).should > 1
  end
##

end
