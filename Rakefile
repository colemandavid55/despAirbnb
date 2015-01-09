
task :environment do
  require './lib/despAirbnb.rb'
end

task :console => :environment do
  require 'irb'
  ARGV.clear
  IRB.start
end

