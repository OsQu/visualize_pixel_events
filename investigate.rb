require 'koala'
require 'optparse'
require 'json'
require 'active_support/core_ext/numeric/time'

require './event_source_pixel'
require './histogram'

access_token = ENV['ACCESS_TOKEN']
if access_token.nil?
  raise "access token missing. Add ACCESS_TOKEN environment variable"
end

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby investigate.rb [options]"

  opts.on("--product_set [String]", "Find by product set") do |v|
    options[:product_set_id] = v
  end

  opts.on("--product_catalog [String]", "Find by product catalog") do |v|
    options[:product_catalog_id] = v
  end
end

option_parser.parse!

Koala.config.api_version = "v2.7"
@api = Koala::Facebook::API.new(access_token)

pixel = if product_set_id = options[:product_set_id]
  EventSourcePixel.find_by_product_set_id(@api, product_set_id)
elsif product_catalog_id = options[:product_catalog_id]
  EventSourcePixel.find_by_product_catalog_id(@api, product_catalog_id)
else
  puts option_parser
  exit(0)
end

puts Histogram.new(pixel.stats(from: 18.days.ago, duration: 2.days)).to_gnuplot_dat
