require File.expand_path("../../src/file_list/file_list.rb", __FILE__)

args = ARGV.to_a

raise "Missing args: <chords_templates> <list_file> <scope_directory>" if args.size < 3

templates = args.shift
file_list = args.shift
scope_directory = args.shift

files_indices = File.read(file_list).lines.map(&:to_i)

list = FileList.new(scope_directory)

files_indices.each_with_index do |fi, i|
  print "recognizing: #{(100.0 * i / files_indices.size).round(2)}%\n"

  input = list.audio_files[fi]
  output = list.recognized_files[fi]

  system "ruby recognize_chords.rb #{templates} '#{input}' '#{output}'"
end
