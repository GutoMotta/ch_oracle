load 'chord_matcher.rb'

@matcher = ChordMatcher.new("chord_matcher.yml")

def assert_match(chord_a, chord_b)
  msg = "#{chord_a} didn't match #{chord_b}"
  raise msg unless @matcher.compare(chord_a, chord_b)
end

def assert_not_match(chord_a, chord_b)
  msg = "#{chord_a} matched #{chord_b}"
  raise msg if @matcher.compare(chord_a, chord_b)
end

assert_match "A", "A:maj"
assert_match "C:(1, 3, 5)", "C:maj"
assert_match "Db", "C#"
assert_match "A", "A:maj"
assert_match "Fbb:min", "D#:min"
assert_match "B:maj9", "B:maj7(2)"
assert_match "B:maj9", "B:maj7/2"

assert_not_match "A", "A:min"

p "All tests passed. Yey :)"
