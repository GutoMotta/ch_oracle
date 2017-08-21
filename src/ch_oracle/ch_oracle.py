from __future__ import print_function
import librosa
import numpy as np
import yaml
import os
import sys

class ChOracle(object):
    def __init__(self, filename, templates_filename, threshold=0.2):
        self.templates_filename = templates_filename

        self.threshold = threshold

        self.chord_names, self.chord_templates = self._load_chord_templates()

        self.x, self.sr = librosa.load(filename)

        self.hop_length = 512

        self.chroma = librosa.feature.chroma_stft(y=self.x, sr=self.sr,
                                                  hop_length=self.hop_length)

        labels = [self._match_feature(f) for f in np.transpose(self.chroma)]

        labels_onsets_offsets = self._labels_onsets_offsets(labels)

        self.labels, self.onsets, self.offsets = labels_onsets_offsets

    def _load_chord_templates(self):
        templates_file = open(self.templates_filename)
        chords = yaml.load(templates_file)
        templates_file.close()
        chord_names = chords.keys()
        chord_templates = [chords[name] for name in chord_names]

        return (chord_names, chord_templates)

    def _match_feature(self, feature):
        inner_products = [np.inner(feature, t) for t in self.chord_templates]
        index_max = np.argmax(inner_products)
        best_match = self.chord_names[index_max]

        return best_match

    def _labels_onsets_offsets(self, labels):
        onsets = [0]
        offsets = []

        for i in range(1, len(labels)):
            t = 1.0 * i * self.hop_length / self.sr
            onsets.append(t)
            offsets.append(t)
        offsets.append(1.0 * len(labels) * self.hop_length / self.sr)

        return (labels, onsets, offsets)

    def labels_onsets_offsets(self):
        return (self.labels, self.onsets, self.offsets)

    def save_evaluation_file(self, filename):
        file = open(filename, "w")
        for i in range(0, len(self.labels)):
            onset = self.onsets[i]
            offset = self.offsets[i]
            label = self.labels[i]

            file.write("%f %f %s\n" % (onset, offset, label))
        file.close()

ChOracle(sys.argv[2], sys.argv[1]).save_evaluation_file(sys.argv[3])
