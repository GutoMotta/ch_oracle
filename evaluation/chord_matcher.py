from __future__ import print_function
import yaml
import re
import sys

class ChordMatcher(object):
    def __init__(self, config):
        self._load_config(config)

    def _load_config(self, filename):
        config_file = open(filename)
        config = yaml.load(config_file)
        config_file.close()

        self.pitches = config["pitches"]
        self.shorthands = config["shorthands"]
        self.intervals = config["intervals"]
        self.pitch_names = config["pitch_names"]

    def chords_match(self, ca, cb):
        return self.chord_notes(ca) == self.chord_notes(cb)

    def chord_notes(self, chord):
        pitch = chord.split(":")[0]
        notes = [self.parse_pitch(pitch)] + self.parse_shorthand(chord)
        intervals = self.get_intervals(chord)

        if chord.count("/") == 1:
            intervals.append(chord.split("/")[-1])

        for interval in intervals:
            if len(interval) >= 1:
                if interval[0] == "*":
                    notes.remove(self.parse_interval(interval[1:]))
                else:
                    notes.append(self.parse_interval(interval))

        if len(notes) == 1:
            notes += self.shorthands['maj']

        return set(notes)

    def get_intervals(self, chord):
        found = re.findall("(?<=\().*(?=\))", chord)
        if len(found) > 0:
            return found[0].split(",")
        return []

    def parse_shorthand(self, chord):
        found = re.findall("(?<=:)[^()/]+(?=\(|\/|$)", chord)
        if len(found) == 0:
            return []
        if found[0] in self.shorthands.keys():
            return self.shorthands[found[0]]
        else:
            print("ERROR! Invalid shorthand: %s" % found[0])
            return []

    def parse_interval(self, interval_str):
        i = self.intervals[str(int(re.split("b|#", interval_str)[-1]) % 8)]
        return i - interval_str.count("b") + interval_str.count("#")

    def parse_pitch(self, pitch):
        i = self.pitches[re.split("b|#", pitch)[0]]
        return self.pitch_names[i - pitch.count("b") + pitch.count("#")]
