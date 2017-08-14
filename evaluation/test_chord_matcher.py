import chord_matcher

m = chord_matcher.ChordMatcher().chords_match

assert m("A", "A:maj"), "ERROR! A didn't match A:maj"
assert m("C:(1, 3, 5)", "C:maj"), "ERROR! C(1, 3, 5) didn't match C:maj"
assert m("Db", "C#"), "ERROR! Db didn't match C#"
assert m("A", "A:maj"), "ERROR! A didn't match A:maj"
assert m("Fbb:min", "D#:min"), "ERROR! Fbb matched Ebb"
assert m("B:maj9", "B:maj7(2)"), "ERROR! B:maj9 didn't match B:maj7(2)"
assert m("B:maj9", "B:maj7/2"), "ERROR! B:maj9 didn't match B:maj7/2"

assert not m("A", "A:min"), "ERROR! A matched A:min"

print("All tests passed. Yey :)")
