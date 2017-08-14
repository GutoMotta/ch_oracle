from __future__ import print_function
import librosa
import numpy as np
import yaml
import sys

class ChOracle(object):
    def __init__(self, filename, templates_filename="chord_templates.yml",
                 threshold=0.2):
        self.templates_filename = templates_filename

        self.threshold = threshold

        self.chord_names, self.chord_templates = self._load_chord_templates()

        self.x, self.sr = librosa.load(filename)

        self.filename = filename.split("/")[-1]

        self.hop_length = 512

        self.chroma = librosa.feature.chroma_stft(y=self.x, sr=self.sr,
                                                  hop_length=self.hop_length)

        labels = [self._match_feature(f) for f in np.transpose(self.chroma)]

        labels_onsets_offsets = self.labels_onsets_offsets(labels)

        self.labels, self.onsets, self.offsets = labels_onsets_offsets

        # labels_times = self._compact_labels(labels)
        # self.labels, self.onsets, self.offsets = self._threshold(*labels_times)

        # tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)
        # beat_times = librosa.frames_to_time(beat_frames, sr=sr)

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

    def labels_onsets_offsets(self, labels):
        onsets = [0]
        offsets = []

        for i in range(1, len(labels)):
            t = 1.0 * i * self.hop_length / self.sr
            onsets.append(t)
            offsets.append(t)
        offsets.append(1.0 * len(labels) * self.hop_length / self.sr)

        return (labels, onsets, offsets)

    def save_evaluation_file(self):
        file = open("outputs/%s.lab" % self.filename, "w")
        for i in range(0, len(self.labels)):
            onset = self.onsets[i]
            offset = self.offsets[i]
            label = self.labels[i]

            file.write("%f %f %s\n" % (onset, offset, label))
        file.close()

    # def _compact_labels(self, labels):
    #     new_labels = [labels[0]]
    #     onsets = [0]
    #     offsets = []

    #     for i in range(1, len(labels)):
    #         if labels[i] != labels[i - 1]:
    #             new_labels.append(labels[i])
    #             t = 1.0 * i * self.hop_length / self.sr
    #             onsets.append(t)
    #             offsets.append(t)
    #     offsets.append(1.0 * len(labels) * self.hop_length / self.sr)

    #     return (new_labels, onsets, offsets)

    # def _threshold(self, labels, onsets, offsets):
    #     new_labels = []
    #     new_onsets = []
    #     new_offsets = []

    #     for i in range(0, len(onsets)):
    #         if offsets[i] - onsets[i] > self.threshold:
    #             new_labels.append(labels[i])
    #             new_onsets.append(onsets[i])
    #             new_offsets.append(offsets[i])

    #     return (new_labels, new_onsets, new_offsets)

    # def times_chords_annotations(self):
    #     x = np.transpose([self.onsets, self.offsets, self.labels])
    #     # TODO porque esta vindo como string?
    #     # print(type(x[1][1]).__name__)
    #     return x

# t = float(sys.argv[2]) if len(sys.argv) >= 3 else 0.2
c = ChOracle(sys.argv[1], templates_filename="chord_templates.yml")
c.save_evaluation_file()
