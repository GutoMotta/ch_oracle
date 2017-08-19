require File.expand_path("../src/file_list/file_list.rb", __FILE__)

args = ARGV.to_a

raise "Missing args: <chords_templates> <recognition_id>" if args.size < 2

templates = args.shift
recognition_id = args.shift

list = FileList.new(recognition_id)

list.count.times do |i|
  input = list.audio_files[i]
  output = list.recognized_files[i]

  system "ruby recognize_chords.rb #{templates} #{input} #{output}"
end
