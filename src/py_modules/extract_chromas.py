import sys

import numpy as np

import librosa

from file_list import FileList

hop_length = 512
sr = 22050

if len(sys.argv) < 3 or sys.argv[2] != "cqt":
    chroma = librosa.feature.chroma_stft
else:
    chroma = librosa.feature.chroma_cqt

def extract_chroma(input_filename, output_filename):
    y, _ = librosa.load(input_filename, sr=sr)
    file = open(output_filename, "w")
    chroma = np.transpose(chroma(y=y, sr=sr))
    n = len(chroma)
    ons, offs = onsets_offsets(n)
    for i in range(0, n):
        file.write(out_file_line(ons[i], offs[i], chroma[i]))
    file.close()

def out_file_line(on, off, arr):
    return "%.5f %.5f %s\n" % (on, off, joint(arr))

def joint(arr):
    return ",".join(str(item) for item in arr)

def onsets_offsets(n):
    onsets = [0]
    offsets = []

    for i in range(1, n):
        t = 1.0 * i * hop_length / sr
        onsets.append(t)
        offsets.append(t)
    offsets.append(1.0 * n * hop_length / sr)

    return (onsets, offsets)

file_list = FileList(sys.argv[1])
for i in range(0, file_list.size):
    audio_file = file_list.audio_files[i]
    chroma_file = file_list.chroma_files[i]
    extract_chroma(audio_file, chroma_file)
