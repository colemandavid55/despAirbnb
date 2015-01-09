require 'geocoder'

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

    def python_baby(coord, range)

      pythonPortal = IO.popen("python python_function.py", "w+")
      pythonPortal.puts coord
      pythonPortal.close_write
      result = []
      temp = pythonPortal.gets

      while temp!= nil
          result<<temp
          temp = pythonPortal.gets
      end 

      corner1 = [] 
      corner2 = []


      corner1 << result[0].gsub(/[()]/, "").split("=")[0].split(",")[0].gsub(/[deg]/, "").to_f
      corner1 << result[0].gsub(/[()]/, "").split("=")[0].split(",")[1].strip.gsub(/[deg]/, "").to_f
      corner2 << result[1].gsub(/[()]/, "").split("=")[0].split(",")[0].gsub(/[deg]/, "").to_f
      corner2 << result[1].gsub(/[()]/, "").split("=")[0].split(",")[1].gsub(/[deg]/, "").to_f

      box = []
      box << corner1
      box << corner2

      box
    end

  end
end
