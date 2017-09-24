require 'pp'

require File.expand_path("../../file_list/file_list.rb", __FILE__)
require File.expand_path("../../chord_matcher/chord_matcher.rb", __FILE__)
require File.expand_path("../../annotation_loop/annotation_loop.rb", __FILE__)

include AnnotationLoop

directory_scope = ARGV[0] || "tmp"

def read_chroma_file(path)
  lines = file_lines(path)
  lines.map do |line|
    on, off, chroma = line.split(" ")
    [on.to_f, off.to_f, chroma.split(",").map(&:to_f)]
  end
end

def read_gt_file(path)
  lines = file_lines(path)
  lines.map do |line|
    on, off, chord = line.split(" ")
    [on.to_f, off.to_f, chord]
  end
end

def file_lines(filename)
  File.read(filename).lines.map(&:strip)
end

file_list = FileList.new(directory_scope)
n = file_list.size

normalizer = ChordMatcher.new

chord_arrays = Hash.new { |h, k| h[k] = [] }

train_indices = n.times.to_a
test_indices = []
(n / 4).times do
  test_indices << train_indices.delete_at(rand(train_indices.size))
end

train_indices.each_with_index do |t, i|
  print "#{(100.0 * i / train_indices.size).round(2)}%\n"
  ann_chroma = read_chroma_file(file_list.chroma_files[t])
  ann_gt = read_gt_file(file_list.gt_files[t])

  annotation_loop(ann_gt, ann_chroma) do |chord, chroma|
    chord_arrays[normalizer.normalize(chord) || chord] << chroma
  end
end

filtered = chord_arrays.select { |chord, array|
  %w(C C:min C# C#:min D D:min D# D#:min
     E E:min F F:min F# F#:min  G  G:min
     G# G#:min A A:min A# A#:min B B:min).include? chord
}

def avg(arrays)
  n = arrays.size
  sum = arrays.inject(Array.new(12, 0)) do |accumulated, next_array|
    12.times.map { |i| accumulated[i] + next_array[i] }
  end
  sum.map { |e| 1.0 * e / n }
end

templates = filtered.map { |chord, arrays| [chord, avg(arrays)] }

File.open("templates_#{directory_scope}.yml", "w") do |file|
  templates.each do |chord, template|
    file << "\"#{chord}\": #{template}\n"
  end
end

File.open("templates_#{directory_scope}_files.csv", "w") do |file|
  test_indices.each { |i| file << "#{i}\n" }
end
