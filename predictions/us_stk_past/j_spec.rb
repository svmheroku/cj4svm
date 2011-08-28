
require "../../spec_helper.rb"

describe "cj4svm helps me build both erb files which act as Rails templates" do

  it "Should Fill each of the partials with data." do

    # I start by getting a list of spool files created by sqlplus:
    glb = Dir.glob("/tmp/tmp_us_stk_past_week_20*.lst").sort
    glb.size.should > 4

    glb.each{|fn|
      # Make a note of the filename:
      p "Input file is #{fn}"
      # For each file, make note of the date embedded in the filename.
      # The date should usually be a Monday.
      # I use the date to identify a weeks worth of data:
      the_date = fn.sub(/tmp_us_stk_past_week_/,'').sub(/.lst/,'').gsub(/-/,'_').sub(/\/.*\//,'')
      the_date.should match /^201._.._../

      # generate bread_crumbs from the_date
      bread_crumbs = "Site Map > Predictions > US Stocks > Past US Stock Predictions #{the_date}"
      site_map    = '<a href="/site_map">Site Map</a>'
      predictions = '<a href="/predictions">Predictions</a>'
      us_stk       = '<a href="/predictions/us_stk">US Stocks</a>'
      past_us_stk_predictions = '<a href="/us_stk_past">Past US Stock Predictions</a>'
      bread_crumbs = "#{site_map} > #{predictions} > #{us_stk} > #{past_us_stk_predictions} > Week of: #{the_date}"

      # generate h4-element from the_date
      h4_element = "<h4>Week of: #{the_date}</h4>"

      # Add an anchor-element related to online help
      data_description = "A description of the data in this page is here > "
      data_description << "<a href='#' class='data_description'> Data Description</a>"
      data_description << "<br /><br />"

      # Next, I feed the file to Nokogiri so I can access HTML in the file:
      nokf = File.open(fn)
      html_doc = Nokogiri::HTML(nokf)
      nokf.close

      # I want a file for this URL pattern:
      # href="/predictions/us_stk_past_wk2011_01_30"
      html_f = File.new("./us_stk_past/us_stk_past_wk#{the_date}.html.erb", "w")

      # Maybe I will find a table_element in that file which interests me.
      table_elem0 = html_doc.search("table")[0]
      if table_elem0.nil?
        some_html = "No Predictions Were Calculated For This Week."
        html_f.puts bread_crumbs + h4_element + some_html
        html_f.close
      else
        # Generate some a-elements from th-elements.
        th_elems = table_elem0.search("th")

        th_elems.each {|elm| 
          ei_h =   elm.inner_html
          ei_hclass = ei_h.gsub(/\n/,'').gsub(/\<br\>/,'').gsub(/\<br \/>/,'').gsub(/ /,'').downcase
          elm.inner_html = "<a href='#' class='#{ei_hclass}'>#{ei_h}</a>"
        }

        table_elem2 = html_doc.search("table")[2]

        # Generate some a-elements from th-elements.
        th_elems = table_elem2.search("th")
        idnum = 0
        th_elems.each {|elm| 
          ei_h =   elm.inner_html
          ei_hclass = ei_h.gsub(/\n/,'').gsub(/\<br\>/,'').gsub(/\<br \/>/,'').gsub(/ /,'').downcase
          ei_hid = ei_hclass + idnum.to_s
          elm.inner_html = "<a href='##{ei_hid}' class='#{ei_hclass}' id='#{ei_hid}'>#{ei_h}</a>"
          idnum += 1
        }

        # Load some html into a string:
        some_html = html_doc.search("table.table_us_stk_past_week").to_html
        some_html << "<br />"
        some_html << "<hr />"
        # Fill the file with HTML which I had obtained from sqlplus:
        html_f.puts bread_crumbs + h4_element + data_description + some_html
        html_f.close
      end # if table_elem0.nil?
      p "#{html_f.path} File written"
    } # glb.each{|fn|
  end # it "Should Fill each of the partials with data." do
##

end
