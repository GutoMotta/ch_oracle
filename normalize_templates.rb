require 'yaml'
require 'matrix'

file_names = %w(
  templates_cqt_n2f1.yml
  templates_cqt_n2f2.yml
  templates_cqt_n2f3.yml
  templates_cqt_n2f4.yml
  templates_stft_n2f1.yml
  templates_stft_n2f2.yml
  templates_stft_n2f3.yml
  templates_stft_n2f4.yml
)


file_names.each do |file_name|
  normalized_file_name = file_name.gsub(".yml", "_n.yml")

  templates = YAML.load(File.read(file_name))
  templates.keys.each do |chord|
    templates[chord] = Vector[*templates[chord]].normalize.to_a
  end

  File.open(normalized_file_name, "w") { |f| f << templates.to_yaml }
end

