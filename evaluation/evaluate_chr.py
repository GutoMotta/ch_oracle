#!/usr/bin/env python

from chord_matcher import ChordMatcher
import yaml
import sys

chords_match = ChordMatcher(sys.argv[1]).chords_match

def read_annotations(filename):
    file = open(filename, "r")
    lines = [line.strip().split(" ") for line in file.readlines()]
    file.close()
    annotations = [[float(on), float(off), label] for on, off, label in lines]
    return annotations

recognized = read_annotations(sys.argv[2])
ground_truth = read_annotations(sys.argv[3])

true_positives = 0.0
false_positives = 0.0
false_negatives = 0.0

r = g = 0
while r < len(recognized) and g < len(ground_truth):
    on_r, off_r, label_r = recognized[r]
    on_g, off_g, label_g = ground_truth[g]

    if chords_match(label_r, label_g):
        true_positives += 1
    else:
        false_negatives += 1
        if label_g != "N":
            false_positives += 1

    if off_r < off_g:
        r += 1
    else:
        g += 1

precision = true_positives / (true_positives + false_positives)
recall = true_positives / (true_positives + false_negatives)
f = 2 * precision * recall / (precision + recall)

results = {
    "true_positives": true_positives,
    "false_positives": false_positives,
    "false_negatives": false_negatives,
    "precision": precision,
    "recall": recall,
    "f-measure": f
}
with open(sys.argv[4], 'w') as outfile:
    yaml.dump(results, outfile, default_flow_style=False)
