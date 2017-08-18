require 'yaml'
require 'fileutils'
require File.expand_path("../../chord_matcher/chord_matcher.rb", __FILE__)

class Appraiser
  attr_reader :true_positives, :false_positives, :false_negatives,
              :precision, :recall, :f_measure

  def initialize(recognized_filename, ground_truth_filename)
    @matcher = ChordMatcher.new
    @r_annotations = load_annotations(recognized_filename)
    @g_annotations = load_annotations(ground_truth_filename)

    @true_positives, @false_positives, @false_negatives = count_matches

    @precision = 1.0 * @true_positives / (@true_positives + @false_positives)
    @recall = 1.0 * @true_positives / (@true_positives + @false_negatives)

    if @precision + @recall == 0
      @f_measure = 0
    else
      @f_measure = 2 * @precision * @recall / (@precision + @recall)
    end
  end

  def load_annotations(file)
    File.readlines(file).map { |s|
      on, off, label = s.strip.split(" ")
      [on.to_f, off.to_f, label]
    }
  end

  def chords_match(label_a, label_b)
    @matcher.compare label_a, label_b
  end

  def count_matches
    tp = fn = fp = 0
    r = g = 0
    while r < @r_annotations.size && g < @g_annotations.size
      on_r, off_r, label_r = @r_annotations[r]
      on_g, off_g, label_g = @g_annotations[g]

      if chords_match(label_r, label_g)
        tp += 1
        # print "Matched! #{label_r}\t#{label_g}\n" if label_r != label_g
      else
        # print "DID NOT match: #{label_r}\t#{label_g}\n" if label_g != "N"
        label_g == "N" ? (fp += 1) : (fn += 1)
      end

      if off_r == off_g
        r += 1
        g += 1
      elsif off_r < off_g
        r += 1
      else
        g += 1
      end
    end
    [tp, fp, fn]
  end

  def results
    {
      "true_positives" => true_positives,
      "false_positives" => false_positives,
      "false_negatives" => false_negatives,
      "precision" => precision,
      "recall" => recall,
      "f_measure" => f_measure
    }
  end

  def save_results(filename)
    File.open("#{filename}", 'w') { |f| f.write results.to_yaml }
  end
end
