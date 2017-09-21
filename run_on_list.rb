require File.expand_path("../src/file_list/file_list.rb", __FILE__)

args = ARGV.to_a

raise "Missing args: <chords_templates> <list_file> <scope_directory>" if args.size < 2

templates = args.shift
file_list = args.shift
scope_directory = args.shift

files_indices = File.read(file_list).lines.map(&:to_i)

list = FileList.new(scope_directory)

files_indices.each do |i|
  input = list.audio_files[i]
  output = list.recognized_files[i]

  system "ruby recognize_chords.rb #{templates} '#{input}' '#{output}'"
end
