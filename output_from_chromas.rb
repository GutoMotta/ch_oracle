require File.expand_path("../src/file_list/file_list.rb", __FILE__)
require "yaml"

args = ARGV.to_a

raise "Missing args: <chromas_scope> <templates> <output_dir> <list_file>" if args.size < 3

chromas_scope = ARGV[0]
templates_file = ARGV[1]
output_dir = ARGV[2]
list_file = ARGV[3]

def file_lines(filename)
  File.read(filename).lines.map(&:strip)
end

def read_chroma_file(path)
  file_lines(path).map do |line|
    on, off, chroma = line.split(" ")
    [on.to_f, off.to_f, chroma.split(",").map(&:to_f)]
  end
end

run_on_index =
  if list_file
    file_lines(list_file).map { |str| [str.to_i, true] }.to_h
  else
    Hash.new(true)
  end

templates = YAML.load(File.read(templates_file))
@labels, @templates = templates.to_a.transpose
def best_match(chroma)
  similarities = @templates.map do |template|
    [chroma, template].transpose.map { |c, t| c * t }.sum
  end
  @labels[similarities.map.with_index.max[1]]
end

chroma_file_list = FileList.new(chromas_scope)
output_file_list = FileList.new(output_dir)

n = output_file_list.size

n.times do |i|
  print "#{(100.0 * i / n).round(1)} %\n"

  next unless run_on_index[i]

  output_path = output_file_list.recognized_files[i]
  chroma_path = chroma_file_list.chroma_files[i]

  File.open(output_path, "w") do |file|
    read_chroma_file(chroma_path).each do |on, off, chroma|
      file << "#{on} #{off} #{best_match(chroma)}\n"
    end
  end
end
