require 'fileutils'

SCRIPT = "evaluation/evaluate_chr.py"

def create_dir!(dir)
  FileUtils.mkdir_p(dir) unless File.directory?(dir)
end

def filename(path)
  path.split("/").last.gsub(/(\.mp3|\.lab|\.out)/, "")
end

def ground_truth
  "ground_truth_annotations/beatles/#{filename(@dir)}/#{filename(@file)}.lab"
end

def output_file
  "#{output_dir}/#{filename(@file)}.yml"
end

def output_dir
  "measures/#{@test_number}/#{filename(@dir)}"
end

def recognized_dirs
  Dir["outputs/#{@test_number}/*"]
end

@test_number = ARGV[0].to_i
config = "evaluation/chord_matcher.yml"

p "RUNNING TESTS NUMBER #{@test_number}"

recognized_dirs.each do |dir|
  @dir = dir
  create_dir! output_dir
  Dir["#{dir}/*"].each do |file|
    @file = file
    # p "#{SCRIPT} #{config} #{file} #{ground_truth} #{output_file}"
    system "#{SCRIPT} #{config} #{file} #{ground_truth} #{output_file}"
  end
end

