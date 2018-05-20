require './src/wegottickets_scraper'
require './src/concert_detail_model'
require 'Nokogiri'

RSpec.describe Scraper do

  it "parse_data(url) returns http response into a nokogiri object so that we can parse it" do
    page1 = Scraper.new()
    expect(page1.parse_data("http://www.wegottickets.com/searchresults/page/1/all#paginate").title).to eql("WeGotTickets | Simple, honest ticketing")
  end

  it "extract_concert_details_data(element_arr) will get all the concerts on the page" do
    page1 = Scraper.new
    parse_page = page1.parse_data("http://www.wegottickets.com/searchresults/page/1/all#paginate")
    concert_divs = parse_page.css('.content.block-group.chatterbox-margin')
    concert_details = page1.extract_concert_details_data(concert_divs)
    expect(concert_details.length).to eq(concert_divs.length)
  end

  it "store_concert_details_data(concert_details_array, output_file) will write all the objects into the file without headers" do
    page1 = Scraper.new
    output_file = "./tmp.csv"
    concert_details = [
      ConcertDetails.new("Artist1", "City1", "Venue1", "Date1", "Time1", "Price1"), 
      ConcertDetails.new("Artist2", "City2", "Venue2", "Date2", "Time2", "Price2"), 
      ConcertDetails.new("Artist3", "City3", "Venue3", "Date3", "Time3", "Price3"),
      ConcertDetails.new("Artist4", "City4", "Venue4", "Date4", "Time4", "Price4"),
      ConcertDetails.new("Artist5", "City5", "Venue5", "Date5", "Time5", "Price5")
    ]
    page1.store_concert_details_data(concert_details, output_file)
    file = File.open(output_file, "r") 
    expect(file.readlines.size).to eq(concert_details.length)
    File.delete(file) # cleanup after test
  end

  it "start_scraping(page_limit, output_file) will write all the objects into the file with headers" do
    page1 = Scraper.new
    output_file = './tmp.csv'
    page1.start_scraping(2, output_file)
    file = File.open(output_file, "r") 
    expect(file.readlines.size).to eq(21) # assuming 10 results per page + 1 for headers
    File.delete(file) # cleanup after test
  end
end