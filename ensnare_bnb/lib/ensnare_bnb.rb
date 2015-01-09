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
      range = opts.fetch(:range, 10)
      sleep_time = opts.fetch(:sleep, 0)

      # build intelligent options hashes/params in URLparams
      base_url = "https://www.airbnb.com"

      city_query = ""
      coord_query = ""

      if( sw_coords && ne_coords )
        coord_query = "&sw_lat=" + sw_coords[0] + "&sw_lng=" + sw_coords[1] +
                      "&ne_lat=" + ne_coords[0] + "&ne_lng=" + ne_coords[1]
      elsif ( city )
        city_query = [city, state, country].compact.map do |str|
          str.gsub('-', '~').gsub(' ', '-')
        end.join('--')
      end

      search_params = opts.except(:city, :state, :country, :max_pages, :sw, :ne)
      query = city_query + "?" + search_params.to_query + coord_query

      search_url = "#{base_url}/s/#{query}"

      pages = opts.fetch(:max_pages, self.max_page_number(search_url))
      results = []

      pages.times do |pg|
        url = "#{search_url}?room_types%5B%5D=Entire+home%2Fapt&page=#{pg}"
        Nokogiri::HTML(open(url)).css(".col-sm-12.col-md-6.row-space-2").each do |room|

          id       = room.css('.listing').first['data-id']
          location = room.css('.listing-location').first.text.match(/ ([^·\n]*)\s+$/)[1]
          name     = room.css('.listing').first['data-name']
          lat      = room.css('.listing').first['data-lat']
          lng      = room.css('.listing').first['data-lng']
          url      = base_url + room.css('.listing').first['data-url']
          price    = room.css('.price-amount').first.text
          img      = room.css(".listing-img-container > img").first['src']

          # If default image was not found, use alternate images
          if (img.match(/no_photos/))
            img      = JSON.parse(room.css(".listing-img-container > img").first['data-urls']).first
          end

          output = {
            id:   id,
            location: location,
            name: name,
            price: price.to_i,
            latitude: lat,
            longitude: lng,
            roomUrl: url,
            imgUrl: img
          }

          if (img.match(/no_photos/))
            binding.pry
          end

          results << output
        end
        # prevent bombarding the server with too many requests at once (default=>1)
        sleep(sleep_time)
      end
      File.open("results.log", 'w') { |file| file.write(results.to_json) }
      results
    end

  end

end
