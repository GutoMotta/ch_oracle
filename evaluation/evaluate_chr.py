from chord_matcher import ChordMatcher
import sys

recognized = open(sys.argv[1])
ground_truth = open(sys.argv[2])

true_positives = 0.0
false_positives = 0.0
false_negatives = 0.0


precision = true_positives / (true_positives + false_positives)
recall = true_positives / (true_positives + false_negatives)
f = 2 * precision * recall / (precision + recall)

print "precision = %f\nrecall = %f\nf-measure=%f\n" % (precision, recall, f)
