require File.expand_path("../../file_list/file_list.rb", __FILE__)
require File.expand_path("../../chord_matcher/chord_matcher.rb", __FILE__)
require File.expand_path("../../annotation_loop/annotation_loop.rb", __FILE__)

include AnnotationLoop

directory_scope = ARGV[0]

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

chord_arrays = Hash.new { |h, k| h[k] = [] }
matcher = ChordMatcher.new

n.times do |i|
  p i
  ann_chroma = read_chroma_file(file_list.chroma_files[i])
  ann_gt = read_gt_file(file_list.gt_files[i])

  annotation_loop(ann_gt, ann_chroma) do |chord, chroma|
    reduced_chord = matcher.reduce(chord)
    if reduced_chord != "N"
      chord_arrays[reduced_chord] += chroma
    end
  end
end

p chord_arrays
