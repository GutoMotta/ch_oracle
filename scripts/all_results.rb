require 'yaml'

measures_path = File.expand_path("../../measures", __FILE__)
dirs = Dir["#{measures_path}/*"]
dir_paths = dirs.map { |dir| [dir, Dir["#{dir}/*/*"]] }.to_h

results = dirs.map do |dir|
  next unless File.exists?("#{dir}/overall.yml")

  experiment_name = dir.split("/").last

  paths = dir_paths[dir]

  precisions = paths.map do |path|
    file_content = File.read(path)
    YAML.load(file_content)['precision'].to_f
  end

  min_precision, max_precision = precisions.minmax
  file_content = File.read("#{dir}/overall.yml")
  file_content_hash = YAML.load(file_content)
  avg_precision = file_content_hash['precisions']['avg']

  [
    experiment_name,
    (avg_precision.to_f * 100).round(2),
    (min_precision.to_f * 100).round(2),
    (max_precision.to_f * 100).round(2)
  ]
end

results.compact!.sort_by! { |name, avg, min, max| -avg }
labels = %w(avg min max)

results.each do |result|
  result_str = labels.map.with_index do |label, i|
    "#{label}: #{sprintf('%.2f', result[i + 1]).rjust(5, ' ')}"
  end.join("\t")

  puts "#{result[0].to_s.rjust(30, ' ')}\t\t#{result_str}\n\n"
end

