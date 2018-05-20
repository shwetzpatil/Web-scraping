require './src/concert_detail_model'

RSpec.describe ConcertDetails, '#toArray' do

  it "toArray() returns the concert details in an array" do
    concert1 = ConcertDetails.new("Artist", "City", "Venue", "Date", "Time", "Price")
    expect(concert1.toArray()).to match_array(["Artist", "City", "Venue", "Date", "Time", "Price"])
  end

end
