require 'yaml'

class ChordMatcher
  def initialize(config_file=nil, debug: false)
    @debug = debug

    config_file ||= File.expand_path("../chord_matcher.yml", __FILE__)
    config = YAML.load_file(config_file)
    @shorthands = config["shorthands"]
    @intervals = config["intervals"]
    pitches = %w(C C# D D# E F F# G G# A A# B)
    @pitch_index = 12.times.map { |i| [pitches[i], i] }.to_h
  end

  def reduce(chord)
    pitch, nts = notes(chord)
    %w(maj min dim aug).each do |s|
      return "#{pitch}:#{s}" if notes.first(3) == @shorthands[s]
    end
    "N"
  end

  def compare(chord_a, chord_b)
    print "#{chord_a} \t #{chord_b}\n" if @debug
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
    pitch = pitch.split("/")[0]
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
    i = interv[/\d+/].to_i
    i %= 7 if i > 7
    @intervals[i] + interv.count("#") - interv.count("b")
  end

  def parse_bass(chord)
    bass = chord[/(?<=\/).+$/]
    bass ? [parse_interval(bass)] : []
  end
end
