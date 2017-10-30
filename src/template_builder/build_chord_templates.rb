require 'pp'

require File.expand_path("../../file_list/file_list.rb", __FILE__)
require File.expand_path("../../chord_matcher/chord_matcher.rb", __FILE__)
require File.expand_path("../../annotation_loop/annotation_loop.rb", __FILE__)

include AnnotationLoop


# USAGE
#   set experiment labels on directory_scope and then create directories under
#   chroma/ named dir_name{f1,f2,f3,f4} with all chromas for building templates
directory_scope = "stft_n2", "cqt_n2"
print "remember, the directory_scope's are hard-coded: #{directory_scope}\n"

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

def avg(arrays)
  n = arrays.size
  sum = arrays.inject(Array.new(12, 0)) do |accumulated, next_array|
    12.times.map { |i| accumulated[i] + next_array[i] }
  end
  sum.map { |e| 1.0 * e / n }
end

normalizer = ChordMatcher.new
file_list = []

directory_scope.each_with_index do |scope, scopei|
  file_list[scopei] = 4.times.map { |i| FileList.new("#{scope}f#{i + 1}") }
end
n = file_list[0][0].size
all_indices = n.times.to_a
subset = 4.times.map { [] }
n.times do |i|
  subset[i % 4] << all_indices.delete_at(rand(all_indices.size))
end

directory_scope.each_with_index do |scope, scopei|
  4.times do |fold|
    print "#{scope}: fold #{fold}\n"

    template_label = "#{scope}f#{fold + 1}"

    chord_arrays = Hash.new { |h, k| h[k] = [] }
    test_indices = subset[fold]
    train_indices = n.times.to_a - test_indices

    train_indices.each_with_index do |t, i|
      ann_chroma = read_chroma_file(file_list[scopei][fold].chroma_files[t])
      ann_gt = read_gt_file(file_list[scopei][fold].gt_files[t])

      annotation_loop(ann_gt, ann_chroma) do |chord, chroma|
        chord_arrays[normalizer.normalize(chord) || chord] << chroma
      end
    end

    filtered = chord_arrays.select { |chord, array|
      %w(C C:min C# C#:min D D:min D# D#:min
         E E:min F F:min F# F#:min  G  G:min
         G# G#:min A A:min A# A#:min B B:min).include? chord
    }

    templates = filtered.map { |chord, arrays| [chord, avg(arrays)] }

    File.open("templates_#{template_label}.yml", "w") do |file|
      templates.each do |chord, template|
        file << "\"#{chord}\": #{template}\n"
      end
    end

    File.open("templates_#{template_label}_files.csv", "w") do |file|
      test_indices.each { |i| file << "#{i}\n" }
    end
  end
end
