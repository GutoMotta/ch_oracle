args = ARGV.to_a

raise "Missing args: <templates> <input> <output>" if args.size < 3

templates = File.expand_path("../#{args.shift}", __FILE__)
input = args.shift
output = args.shift
threshold = args.shift

args = "'#{templates}' '#{input}' '#{output}' #{threshold}"
exec("python src/ch_oracle/extract_chords.py #{args}")
