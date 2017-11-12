class Evaluation
  include AnnotationLoop

  attr_reader :true_positives, :false_positives, :false_negatives,
              :precision, :recall, :f_measure

  def initialize(recognition_annotations, ground_truth_annotations)
    @matcher = ChordMatcher.new

    @r_annotations = recognition_annotations
    @g_annotations = ground_truth_annotations

    @true_positives, @false_positives, @false_negatives = count_matches

    @precision = 1.0 * @true_positives / (@true_positives + @false_positives)
    @recall = 1.0 * @true_positives / (@true_positives + @false_negatives)

    if @precision + @recall == 0
      @f_measure = 0
    else
      @f_measure = 2 * @precision * @recall / (@precision + @recall)
    end
  end

  def chords_match(label_a, label_b)
    @matcher.compare(label_a, label_b)
  end

  def count_matches
    tp = tn = fn = fp = 0

    annotations = @r_annotations, @g_annotations
    annotation_loop(*annotations) do |r_label, g_label, duration|
      if r_label == "N" # negatives
        if g_label == "N"
          tn += duration
        else
          fn += duration
        end
      else # positives
        if g_label != "N"
          if chords_match(r_label, g_label)
            tp += duration
          else
            fp += duration
          end
        end
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
end
