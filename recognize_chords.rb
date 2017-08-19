args = ARGV.to_a

raise "Missing args: <templates> <input> <output>" if args.size < 3

templates = File.expand_path("../#{args.shift}", __FILE__)
input = args.shift
output = args.shift

exec("python src/ch_oracle/ch_oracle.py #{templates} '#{input}' '#{output}'")
