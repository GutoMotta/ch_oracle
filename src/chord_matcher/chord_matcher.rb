require 'yaml'

class ChordMatcher
  def initialize(config_file="chord_matcher.yml")
    config = YAML.load_file(config_file)
    @shorthands = config["shorthands"]
    @intervals = config["intervals"]
    pitches = %w(C C# D D# E F F# G G# A A# B)
    @pitch_index = 12.times.map { |i| [pitches[i], i] }.to_h
  end

  def compare(chord_a, chord_b)
    return false if chord_a == "N" || chord_b == "N"
    notes(chord_a) == notes(chord_b)
  end

  def notes(chord)
    pitch = parse_pitch(chord)
    notes = parse_shorthand(chord)
    added_notes, removed_notes = parse_intervals(chord)
    bass_notes = parse_bass(chord)
    notes = notes + added_notes - removed_notes + bass_notes
    notes += @shorthands["maj"] if notes.empty?

    [pitch, notes.sort]
  end

  def parse_pitch(chord)
    pitch = chord.split(":")[0]
    root = pitch.delete("b#")
    @pitch_index[root] + pitch.count("#") - pitch.count("b")
  end

  def parse_shorthand(chord)
    shorthand = chord[/(?<=:)[^()\/]+/]
    notes = @shorthands[shorthand]
    p "ERROR! Invalid shorthand: #{shorthand}" if shorthand && notes.nil?
    notes.to_a
  end

  def parse_intervals(chord)
    added_notes = []
    removed_notes = []

    intervals = chord[/(?<=\().*(?=\))/].to_s

    intervals.split(",").map { |s| s.strip }.each do |interval|
      if interval[0] == "*"
        removed_notes << parse_interval(interval[1..-1])
      else
        added_notes << parse_interval(interval)
      end
    end

    [added_notes, removed_notes]
  end

  def parse_interval(interv)
    i = interv.to_i
    i %= 7 if i > 7
    @intervals[i] + interv.count("#") - interv.count("b")
  end

  def parse_bass(chord)
    bass = chord[/(?<=\/).+$/]
    bass ? [parse_interval(bass)] : []
  end
end
