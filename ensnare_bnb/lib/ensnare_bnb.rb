require_relative 'ensnare_bnb/version'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'active_support'
require 'active_support/core_ext/hash'
require 'pry-byebug'

module EnsnareBnb

  class << self

    def max_page_number(url)
      # pagination-buttons-container
      selector = "body > div.map-search > div.sidebar > " +
                  "div.search-results > div.results-footer > " +
                  "div.pagination-buttons-container > div.pagination > ul > " +
                  "li:nth-child(5)"

      Nokogiri::HTML(open(url)).css(selector).text.to_i
    end

    def find_airbnb_hosts(**opts)

      DEFAULT_RANGE = 10
      DEFAULT_SLEEP = 0

      LAT = 0
      LNG = 1

      # city, state, country
      # New-York--NY--United-States

      # To create new (and to remove old) logfile, add File::CREAT like:
      file = File.open('logfile.log', File::WRONLY | File::APPEND | File::CREAT)
      logger = Logger.new(file)

      city = opts.fetch(:city, nil)
      state = opts.fetch(:state, nil)
      country = opts.fetch(:country, nil)
      sw_coords = opts.fetch(:sw, nil)
      ne_coords = opts.fetch(:ne, nil)
      range = opts.feth(:range, DEFAULT_RANGE)
      sleep_time = opts.fetch(:sleep, DEFAULT_SLEEP)

      # build intelligent options hashes/params in URLparams

      base_url = "https://www.airbnb.com"

      city_query = "", coord_query = ""

      if ( :city )
        city_query = [city, state, country].compact.map do |str|
          str.gsub('-', '~').gsub(' ', '-')
        end.join('--')

      elsif( :sw && :ne)

        coord_query = "&sw_lat=" + sw_coords[LAT] + "&sw_lng=" + sw_coords[LNG] +
                      "&ne_lat=" + ne_coords[LAT] + "&ne_lng=" + ne_coords[LNG]
      end

      search_params = opts.except(:city, :state, :country, :max_pages, :sw, :ne)
      query = city_query + "?" + search_params.to_query + coord_query

      search_url = "#{base_url}/s/#{query}"

      pages = opts.fetch(:max_pages, self.max_page_number(search_url))
      results = []

      pages.times do |pg|
        url = "#{search_url}?room_types%5B%5D=Entire+home%2Fapt&page=#{pg}"
        Nokogiri::HTML(open(url)).css(".col-sm-12.col-md-6.row-space-2").each do |room|

          name   = room.css('.listing').first['data-name']
          lat    = room.css('.listing').first['data-lat']
          lng    = room.css('.listing').first['data-lng']
          url    = base_url + room.css('.listing').first['data-url']
          price  = room.css('.price-amount').first.text
          img    = room.css('img').first['src']

          output = {
            city: city,
            name: name,
            price: price.to_i,
            lattitude: lat,
            longitude: lng,
            roomUrlExt: urlExt,
            imgUrl: img
          }

          results << output
        end
        # prevent bombarding the server with too many requests at once (default=>1)
        sleep(sleep_time)
      end
      results
    end

  end

end
