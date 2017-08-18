require "yaml"
require File.expand_path("../src/appraiser/appraiser.rb", __FILE__)
require File.expand_path("../src/file_list/file_list.rb", __FILE__)

raise "Choose an output directory for reading recognized files" if ARGV.size < 1

output_dir = ARGV[0]
list = FileList.new(output_dir)

f_measures = []
precisions = []
recalls = []

list.count.times do |i|
  recognized = list.recognized_files[i]
  ground_truth = list.ground_truth_files[i]
  measure_file = list.measure_files[i]

  evaluation = Appraiser.new(recognized, ground_truth)
  results = evaluation.results

  f_measures << results["f_measure"]
  precisions << results["precision"]
  recalls << results["recall"]

  evaluation.save_results(measure_file)
end

def avg(array)
  1.0 * array.inject(:+) / array.size
end

def stdev(array)
  avg = avg(array)
  sum = array.inject(0) { |accum, i| accum + (i - avg) ** 2 }
  1.0 * sum / array.size
end

def overall(array)
  { "avg" => avg(array), "stdev" => stdev(array) }
end

results = {
  "f_measures" => overall(f_measures),
  "precisions" => overall(precisions),
  "recalls" => overall(recalls)
}

File.open("#{list.measures_dir}/overall.yml", "w") do |f|
  f << results.to_yaml
end
