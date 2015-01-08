[![Stories in Ready](https://badge.waffle.io/hackerparadise2014/ensnare_bnb.png?label=ready&title=Ready)](https://waffle.io/hackerparadise2014/ensnare_bnb)
# EnsnareBnb

EnsnareBnb is a simple scraper designed to get listings from AirBNB in JSON
format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ensnare_bnb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ensnare_bnb

## Usage

#### Required Fields

AirBNB only requires a city for most results to be found, but to prevent inaccurate results for common city names (for example, Dover or St. Louis), providing city, state, and country (for US cities) and city/country for international cities is recommended.

```
EnsnareBnb.find_airbnb_hosts(
	city: 'Chiang Mai', 
	country: 'Thailand',
	min_bedrooms:4, 
	min_beds: 6)
```
=> Returns JSON results of all AirBNB listings found in Chiang Mai, Thailand with a minimum of 4 bedrooms and 6 beds.

#### Optional Fields
<pre>
{
sleep: 1,				 # time (in seconds) to wait between each request 
checkin: "11-01-2014",   # intended checkin date in MM-DD-YYYY
checkout: "11-20-2014",  # intended checkout date
guests: 7, 				 # number of guests staying
price_min: 50, 			 # minimum price
price_max: 100, 		 # maximum price
min_beds: 6, 			 # total number of beds
min_bedrooms: 4, 		 # total number of bedrooms,
min_bathrooms: 3, 		 # total number of bathrooms,
keywords: "oceanfront" 	 # additional keywords to search properties by
}
</pre>

### TODO:

Improve support for international city names by prefecture/province/etc.
Add support for advanced filtering options: property type, amenities, and host language.

--

### Contributing

1. Fork it ( https://github.com/[my-github-username]/ensnare_bnb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
