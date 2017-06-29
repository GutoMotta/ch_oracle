from __future__ import print_function
import librosa
import numpy as np
import sys

notes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
chord_names = notes + ["%sm" % (note) for note in notes]

mayor_chord_templates = []
minor_chord_templates = []
for i in range(0, 12):
  mayor = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  mayor[i] = mayor[(i + 4) % 12] = mayor[(i + 7) % 12] = 1
  mayor_chord_templates.append(mayor)
  minor = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  minor[i] = minor[(i + 3) % 12] = minor[(i + 7) % 12] = 1
  minor_chord_templates.append(minor)
chord_templates = mayor_chord_templates + minor_chord_templates

class ChOracle(object):
  """docstring for ChOracle"""
  def __init__(self, filename):
    self.x, self.sr = librosa.load(filename)
    self.chromagram = librosa.feature.chroma_stft(y=self.x, sr=self.sr)
    labels = [self.match_feature(l) for l in np.transpose(self.chromagram)]
    self.labels, self.onset_times, self.offset_times = self.unify(labels)
    # tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)
    # beat_times = librosa.frames_to_time(beat_frames, sr=sr)

  def match_feature(self, feat):
    n = [np.inner(feat, t) for t in chord_templates]
    return chord_names[np.argmax(n)]

  def unify(self, labels, hop_size=512, sr=22050):
    new_labels = [labels[0]]
    onset_times = [0]
    offset_times = []
    for i in range(1, len(labels)):
      if labels[i] != labels[i - 1]:
        new_labels.append(labels[i])
        t = 1.0 * i * hop_size / sr
        onset_times.append(t)
        offset_times.append(t)
    offset_times.append(1.0 * len(labels) * hop_size / sr)
    return (new_labels, onset_times, offset_times)

c = ChOracle(sys.argv[1])
for i in range(0, len(c.onset_times)):
  if c.offset_times[i] - c.onset_times[i] > 0.2:
    print("%fs\t%fs\t%s" % (c.onset_times[i], c.offset_times[i], c.labels[i]))

