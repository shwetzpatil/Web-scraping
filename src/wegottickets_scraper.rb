require 'HTTParty'
require 'Nokogiri'
require 'Pry'
require 'csv'
require './src/concert_detail_model'

class Scraper

  # url:String -> html page: Nokogiri::HTML object
  # gets web web url which we want to scrap and parse it into html page
  def parse_data(url)
    page = HTTParty.get(url)
    parse_page = Nokogiri::HTML(page)
    return parse_page
  end 

  # elementArray: Nokogiri::Document[] -> concertArray: ConcertDetails[]
  # this function take the array of html element as argument and convert each concert into object 
  # returns array of object
  #
  # css selector corresponding to concert details:
  # artists : '.event_link'
  # city : '.venue-details' 'h4:nth-child(1)'
  # venue : '.venue-details' 'h4:nth-child(1)'
  # date : '.venue-details' 'h4:nth-child(2)'
  # time : '.venue-details' 'h4:nth-child(2)'
  # price : '.searchResultsPrice' 'strong'
  def extract_concert_details_data(element_arr)
    # concertArray
    concert_details = []
    element_arr.map do |a|
      artists = a.css('.event_link').text
    
      city = a.css('.venue-details').css('h4:nth-child(1)').text.split(":")[0]

      venue = a.css('.venue-details').css('h4:nth-child(1)').text.split(":")[1]

      date = a.css('.venue-details').css('h4:nth-child(2)').text.split(",").take(2).join

      time = a.css('.venue-details').css('h4:nth-child(2)').text.split(",")[2]

      price = a.css('.searchResultsPrice').css('strong').text
      # concertObject
      concert_details_obj = ConcertDetails.new(artists, city, venue, date, time, price)
      concert_details.push(concert_details_obj)
    end
    return concert_details
  end

  # concertArray: ConcertDetails[], output_file:String -> void
  # it takes concert details Array and output file path as arguments 
  # and stores the array in the csv file specified by output_file without headers
  def store_concert_details_data(concert_details_array, output_file)
    CSV.open(output_file, 'a') do |csv|
      concert_details_array.each{|x| csv << x.toArray()} 
    end
  end

  # page_limit: Integer, output_file_path:String -> void
  # this function takes page limit (page_limit -1 implies all available pages) and output file as argument 
  # runs scraping by using all above functions and
  # stores concert details in the csv file specified by output_file with headers
  def start_scraping(page_limit, output_file_path)

    # add header in csv file before loop starts
    CSV.open(output_file_path, 'w') do |csv|
      csv << ['Artist Name', 'City', 'Venue', 'Date', 'Time', 'Ticket Price']
    end

    # loop for retrieving data for pages upto page_limit
    page_no = 1
    loop do
      url = "http://www.wegottickets.com/searchresults/page/#{page_no}/all#paginate"
      parse_page = self.parse_data(url)
      
      puts "Processing url:", url

      concert_div_arr = parse_page.css('.content.block-group.chatterbox-margin')
      if concert_div_arr.length == 0 # no concert elements are found
        break
      end
      concert_details_array = self.extract_concert_details_data(concert_div_arr)

      self.store_concert_details_data(concert_details_array, output_file_path)
      
      # add up pagginations results
      if page_no >= page_limit && page_limit != -1 
        break
      end
      page_no = page_no + 1
    end
  end
  #Pry.start(binding)
end

# this runs when called with ruby src/..., does not run when called with RSpec
if $0 == __FILE__
  program = Scraper.new
  program.start_scraping(-1, './src/result.csv')
end