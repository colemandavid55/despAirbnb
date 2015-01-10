require 'geocoder'
require 'pry-byebug'

module DespAirbnb
  module Calculations
    extend self

    ##
    # Distance between two points on Earth (Haversine formula).
    # Takes two points and an options hash.
    # The points are given in the same way that points are given to all
    # Geocoder methods that accept points as arguments. They can be:
    #
    # * an array of coordinates ([lat,lon])
    # * a geocodable address (string)
    # * a geocoded object (one which implements a +to_coordinates+ method
    #   which returns a [lat,lon] array
    #
    # The options hash supports:
    #
    # * <tt>:units</tt> - <tt>:mi</tt> or <tt>:km</tt>
    #   Use Geocoder.configure(:units => ...) to configure default units.
    #
    def distance_between(point1, point2, options = {})
      Geocoder::Calculations.distance_between(point1, point2, options)
    end

    def coord_float_to_string(coord) 
      coord.map! { |point| point.to_s }
    end

    def python_baby(coord, range)

      path = File.expand_path File.dirname(__FILE__) + "/python_function.py"

      pythonPortal = IO.popen("python #{path}", "w+")
      pythonPortal.puts coord, range
      pythonPortal.close_write
      result = []

      temp = pythonPortal.gets

      while temp != nil
          result << temp
          temp = pythonPortal.gets
      end 

      # gotValue = false

      # binding.pry

      # begin
      #   if( temp = pythonPortal.gets )
      #     result << temp
      #     gotValue = true
      #   end
      # end while (temp == nil || !gotValue)


      corner1 = [] 
      corner2 = []


      corner1 << result[0].gsub(/[()]/, "").split("=")[0].split(",")[0].strip.gsub(/[deg]/, "")
      corner1 << result[0].gsub(/[()]/, "").split("=")[0].split(",")[1].strip.gsub(/[deg]/, "")
      corner2 << result[1].gsub(/[()]/, "").split("=")[0].split(",")[0].strip.gsub(/[deg]/, "")
      corner2 << result[1].gsub(/[()]/, "").split("=")[0].split(",")[1].strip.gsub(/[deg]/, "")

      box = []
      box << corner1
      box << corner2

      box
    end

  end
end
