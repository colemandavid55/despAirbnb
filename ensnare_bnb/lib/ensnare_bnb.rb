require_relative 'ensnare_bnb/version'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'active_support'
require 'active_support/core_ext/hash'

module EnsnareBnb

  class << self

    def max_page_number(url)
      # pagination-buttons-container
      selector = "body > div.map-search > div.sidebar > " +
                  "div.search-results.panel-body > div.results-footer > " +
                  "div.pagination-buttons-container > div.pagination > ul > " +
                  "li:nth-child(5)"
      Nokogiri::HTML(open(url)).css(selector).text.to_i
    end

    def find_airbnb_hosts(**opts)
      # city, state, country
      # New-York--NY--United-States
      city = opts.fetch(:city)
      state = opts.fetch(:state, nil)
      country = opts.fetch(:country, nil)
      sleep_time = opts.fetch(:sleep, 1)

      city_query = [city, state, country].compact.map do |str|
        str.gsub('-', '~').gsub(' ', '-')
      end.join('--')

      search_params = opts.except(:city, :state, :country, :max_pages)
      query = city_query + "?" + search_params.to_query

      # build intelligent options hashes/params in URLparams

      base_url = "https://www.airbnb.com"
      search_url = "#{base_url}/s/#{query}"

      pages = opts.fetch(:max_pages, self.max_page_number(search_url))
      results = []

      pages.times do |pg|
        url = "#{search_url}?room_types%5B%5D=Entire+home%2Fapt&page=#{pg}"
        Nokogiri::HTML(open(url)).css(".target-details.block-link").each do |box|
          details_url = "#{base_url}#{box["href"]}"
          inner_pg_data = Nokogiri::HTML(open(details_url))
          name = inner_pg_data.css('#listing_name').text.strip
          price = inner_pg_data.css('#price_amount').text[/\d+/]
          beds = inner_pg_data.css('#summary > div > div > div.col-8 > div > div:nth-child(2) > div.col-9 > div > div:nth-child(4)').text[/\d+/]
          bedrooms = inner_pg_data.css('#summary > div > div > div.col-8 > div > div:nth-child(2) > div.col-9 > div > div:nth-child(3)').text[/\d+/]
          capacity = inner_pg_data.css('#summary > div > div > div.col-8 > div > div:nth-child(2) > div.col-9 > div > div:nth-child(2)').text[/\d+/]
          output = {
            city: city,
            name: name,
            price: price.to_i,
            bedrooms: bedrooms.to_i,
            beds: beds.to_i,
            capacity: capacity.to_i
          }.to_json

          results << output
        end
        # prevent bombarding the server with too many requests at once (default=>1)
        sleep(sleep_time)
      end
      results
    end

  end

end
