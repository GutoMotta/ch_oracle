require File.expand_path("../src/file_list/file_list.rb", __FILE__)

args = ARGV.to_a

raise "Missing args: <chords_templates> <scope_directory>" if args.size < 2

templates = args.shift
scope_directory = args.shift

list = FileList.new(scope_directory)

list.count.times do |i|
  input = list.audio_files[i]
  output = list.recognized_files[i]

  system "ruby recognize_chords.rb #{templates} '#{input}' '#{output}'"
end
