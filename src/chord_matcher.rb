class ChordMatcher
  def initialize(config_file=nil, debug: false)
    @debug = debug

    config_file ||= File.expand_path("../chord_matcher.yml", __FILE__)
    config = YAML.load_file(config_file)
    @shorthands = config["shorthands"]
    @intervals = config["intervals"]

    pitches = %w(C C# D D# E F F# G G# A A# B)
    @pitch_index = pitches.map.with_index.to_h

    @main_chord_templates = {}
    pitches.each do |pitch|
      %w(maj min dim aug).each do |shorthand|
        label = [pitch, shorthand != "maj" ? shorthand : nil].compact.join(":")
        @main_chord_templates[notes(label)] = label
      end
    end
  end

  def normalize(chord)
    @main_chord_templates[notes(chord)]
  end

  def compare(chord_a, chord_b)
    print "#{chord_a} \t #{chord_b}\n" if @debug
    return false if chord_a == "N" || chord_b == "N"
    [notes(chord_a), notes(chord_b)].transpose.map { |a, b| a <= b }.all?
  end

  def notes(chord)
    return [nil, []] if chord == "N"

    notes = Array.new(12, 0)

    root = parse_pitch(chord)
    added_notes, removed_notes = parse_intervals(root, chord)
    shorthand_notes = parse_shorthand(root, chord)

    if [added_notes + shorthand_notes].flatten.size == 0
      added_notes = parse_shorthand(root, ":maj")
    end

    indices_to_add = [
      root, shorthand_notes,
      parse_bass(root, chord),
      added_notes
    ].flatten.uniq

    indices_to_add.each { |i| notes[i] = 1 }
    removed_notes.each { |i| notes[i] = 0 }

    notes
  end

  def parse_pitch(chord)
    pitch = chord.split(":")[0]
    pitch = pitch.split("/")[0]
    root = pitch.delete("b#")
    (@pitch_index[root] + pitch.count("#") - pitch.count("b")) % 12
  end

  def parse_shorthand(root, chord)
    shorthand = chord[/(?<=:)[^()\/]+/]
    notes = @shorthands[shorthand]
    p "ERROR! Invalid shorthand: #{shorthand}" if shorthand && notes.nil?
    sum_root(root, notes.to_a)
  end

  def parse_intervals(root, chord)
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

    [sum_root(root, added_notes), sum_root(root, removed_notes)]
  end

  def parse_interval(interv)
    i = interv[/\d+/].to_i
    i %= 7 if i > 7
    (@intervals[i] + interv.count("#") - interv.count("b")) % 12
  end

  def parse_bass(root, chord)
    bass = chord[/(?<=\/).+$/]
    bass ? sum_root(root, [parse_interval(bass)]) : []
  end

  def sum_root(root, notes)
    notes.map { |note| (note + root) % 12 }
  end
end
