
task :environment do
  require './lib/petshop.rb'
end

task :console => :environment do
  require 'irb'
  ARGV.clear
  IRB.start
end

