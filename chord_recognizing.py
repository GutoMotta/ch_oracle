from __future__ import print_function
import librosa
import numpy as np
import sys

class ChOracle(object):
    chord_names = [
        'C', 'C#', 'D', 'D#', 'E', 'F',
        'F#', 'G', 'G#', 'A', 'A#', 'B',
        'Cm', 'C#m', 'Dm', 'D#m', 'Em', 'Fm',
        'F#m', 'Gm', 'G#m', 'Am', 'A#m', 'Bm'
    ]
    chord_templates = [
        [1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0],
        [0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1],
        [1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0],
        [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0],
        [0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0],
        [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1],
        [1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0],
        [0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0],
        [0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1],
        [1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0],
        [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1]
    ]

    def __init__(self, filename):
        self.x, self.sr = librosa.load(filename)

        self.hop_length = 512

        self.chroma = librosa.feature.chroma_stft(y=self.x, sr=self.sr,
                                                  hop_length=self.hop_length)

        labels = [self._match_feature(l) for l in np.transpose(self.chroma)]
        self.labels, self.onsets, self.offsets = self._filter_labels(labels)

        # tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)
        # beat_times = librosa.frames_to_time(beat_frames, sr=sr)

    def _match_feature(self, feature):
        templates = ChOracle.chord_templates
        inner_products = [np.inner(feature, temp) for temp in templates]
        index_max = np.argmax(inner_products)
        best_match = ChOracle.chord_names[index_max]

        return best_match

    def _filter_labels(self, labels, threshold=0.2):
        new_labels = [labels[0]]
        onsets = [0]
        offsets = []

        for i in range(1, len(labels)):
            if labels[i] != labels[i - 1]:
                t = 1.0 * i * self.hop_length / self.sr

                if t - onsets[-1] > threshold:
                    new_labels.append(labels[i])
                    onsets.append(t)
                    offsets.append(t)
        offsets.append(1.0 * len(labels) * self.hop_length / self.sr)

        return (new_labels, onsets, offsets)

    def times_chords_annotations(self):
        x = np.transpose([self.onsets, self.offsets, self.labels])
        # TODO porque esta vindo como string?
        print(type(x[1][1]).__name__)
        return x


c = ChOracle(sys.argv[1])
for annotation in c.times_chords_annotations():
    on, off, chord = annotation
    print("%ss\t%ss\t%s" % (on, off, chord))

