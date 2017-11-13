require 'yaml'
require 'byebug'

dir = File.expand_path("../../experiments", __FILE__)
dirs = Dir["#{dir}/*"]

results = dirs.map do |dir|
  path = "#{dir}/results.yml"
  next unless File.exists?(path)

  experiment_name = dir.split("/").last

  paths = Dir["#{dir}/results/*/*"]
  precisions = paths.map do |path|
    file_content = File.read(path)
    YAML.load(file_content)['precision'].to_f
  end

  min_precision, max_precision = precisions.minmax

  _results = YAML.load File.read(path)
  avg_precision = _results.max_by { |_, h| h['precision'] }[1]['precision']

  [
    experiment_name,
    (avg_precision.to_f * 100).round(2),
    (min_precision.to_f * 100).round(2),
    (max_precision.to_f * 100).round(2)
  ]
end

results = results.compact.sort_by { |name, avg, min, max| -avg }
labels = %w(avg min max)

results.each do |result|
  result_str = labels.map.with_index do |label, i|
    "#{label}: #{sprintf('%.2f', result[i + 1]).rjust(5, ' ')}"
  end.join("\t")

  puts "#{result[0].to_s.rjust(40, ' ')}\t\t#{result_str}\n\n"
end

