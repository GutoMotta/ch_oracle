# -*- coding: utf-8 -*-

import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import numpy as np
import re
import yaml
import os
import sys

if len(sys.argv) < 2:
    print "select chroma file"
    sys.exit()

template_file = sys.argv[1]
pattern = re.compile(".*stft.*")
if pattern.match(template_file):
    title = "STFT"
else:
    title = "CQT"
template_dir = "templates_%s" % title.lower()
if not os.path.exists("figs/%s" % template_dir):
    os.makedirs("figs/%s" % template_dir)


notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
notes_names = [
    u"dó",
    u"dó#",
    u"ré",
    u"ré#",
    u"mi",
    u"fá",
    u"fá#",
    u"sol",
    u"sol#",
    u"lá",
    u"lá#",
    u"si"
]

file = open(template_file)
templates = yaml.load(file)
file.close()
for chord, chroma in templates.iteritems():
    chord_parts = chord.split(":")
    root = chord_parts[0]
    root_i = notes.index(root)
    minor = len(chord_parts) == 2
    if minor:
      third_i = (root_i + 3) % 12
    else:
      third_i = (root_i + 4) % 12
    fifth_i = (root_i + 7) % 12

    colors =  12 * ["royalblue"]

    colors[root_i] = "palevioletred"
    colors[third_i] = "darksalmon"
    colors[fifth_i] = "rosybrown"

    x = np.arange(len(chroma))
    fig, ax = plt.subplots()
    ax.bar(x, chroma, color=colors)
    # ax.set_title(title)
    ax.set_xticks(x)
    ax.set_xticklabels(notes_names)
    ax.set_ylim([0, 1])

    a = mpatches.Patch(color='palevioletred', label='1a')
    b = mpatches.Patch(color='darksalmon', label='3a')
    c = mpatches.Patch(color='rosybrown', label='5a')
    plt.legend(handles=[a, b, c], loc=2)
    ax.set_xlabel('nota')
    ax.set_ylabel('intensidade')

    mayor_or_minor = "minor" if minor else "mayor"
    fig_name = "%s_%s" % (mayor_or_minor, root)
    plt.savefig("figs/%s/%s" % (template_dir, fig_name), dpi=200)
    plt.close(fig)
