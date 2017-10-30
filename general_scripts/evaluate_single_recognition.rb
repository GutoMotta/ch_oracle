require File.expand_path("../../src/appraiser/appraiser.rb", __FILE__)
require "pp"
pp Appraiser.new(ARGV[0], ARGV[1]).results["f_measure"]
