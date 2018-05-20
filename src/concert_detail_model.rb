class ConcertDetails

  # Initializaing all instance variables required for concer details array
  def initialize (artist, city, venue, date, time, price)
    @concert_artist = artist
    @concert_city = city
    @concert_venue = venue
    @concert_date = date
    @concert_time = time
    @concert_price = price
  end

  # this function gives array of each concert details
  def toArray()
    return [@concert_artist, @concert_city, @concert_venue, @concert_date, @concert_time, @concert_price]
  end
end