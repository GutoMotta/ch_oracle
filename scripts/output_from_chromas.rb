require File.expand_path("../../src/file_list/file_list.rb", __FILE__)
require 'optparse'
require 'yaml'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: output_from_chromas.rb [options]"

  opts.on('-f', '--filter', 'Filter') { options[:filter] = true }

  opts.on('-t', '--templates-file FILE', 'Chroma Scope') do |value|
    options[:templates_file] = value
  end

  opts.on('-o', '--output-dir DIR', 'Output Directory') do |value|
    options[:output_dir] = value
  end

  opts.on('-c', '--chroma-scope SCOPE', 'Chroma Scope') do |value|
    options[:chromas_scope] = value
  end

  opts.on('-l', '--list-file FILE',
          'File with the list of files for recognizing') do |value|
    options[:list_file] = value
  end

end.parse!


mandatory_args = %i(chromas_scope templates_file output_dir)
missing_args = mandatory_args - options.keys

raise "Missing args: #{missing_args}" if missing_args.any?

chromas_scope = options[:chromas_scope]
templates_file = options[:templates_file]
output_dir = options[:output_dir]
list_file = options[:list_file]


templates = YAML.load(File.read(templates_file))
@labels, @templates = templates.to_a.transpose

def file_lines(filename)
  File.read(filename).lines.map(&:strip)
end

def read_chroma_file(path)
  file_lines(path).map do |line|
    on, off, chroma = line.split(" ")
    [on.to_f, off.to_f, chroma.split(",").map(&:to_f)]
  end
end

def filter_chromas(ons_offs_chromas, k=5)
  n = ons_offs_chromas.size
  ons_offs_chromas.map.with_index do |on_off_chroma, i|
    on, off, _ = on_off_chroma

    from = [i - k, 0].max
    to = [i + k, n - 1].min

    chroma = chromas_average(ons_offs_chromas[from..to].map(&:last))
    [on, off, chroma]
  end
end

def chromas_average(chromas)
  n = chromas[0].size
  chromas.transpose.map { |note_intensities| note_intensities.sum.to_f / n }
end

def best_match(chroma)
  similarities = @templates.map do |template|
    [chroma, template].transpose.map { |c, t| c * t }.sum
  end
  @labels[similarities.map.with_index.max[1]]
end

run_on_index =
  if list_file
    file_lines(list_file).map { |str| [str.to_i, true] }.to_h
  else
    Hash.new(true)
  end

chroma_file_list = FileList.new(chromas_scope)
output_file_list = FileList.new(output_dir)

n = output_file_list.size

n.times do |i|
  print "#{output_dir} => #{(100.0 * i / n).round(1)} %\n"

  next unless run_on_index[i]

  output_path = output_file_list.recognized_files[i]
  chroma_path = chroma_file_list.chroma_files[i]

  File.open(output_path, "w") do |file|
    chromas = read_chroma_file(chroma_path)

    chromas = filter_chromas(chromas) if options[:filter]

    chromas.each do |on, off, chroma|
      file << "#{on} #{off} #{best_match(chroma)}\n"
    end
  end
end
