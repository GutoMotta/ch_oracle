class Song
  include AnnotationLoop

  attr_reader :album, :title

  def self.parse(path)
    album, title = path.split('/')[-2..-1]
    new(album, title)
  end

  def self.all
    all_songs = []

    audios_dir = File.expand_path("../../audios", __FILE__)
    albums_paths = Dir["#{audios_dir}/*"].sort
    albums_paths.each do |album_path|
      all_songs += Dir["#{album_path}/*"].sort.map do |song_path|
        parse song_path
      end
    end

    all_songs
  end

  def self.find_all(regex)
    regex = Regexp.new(regex)
    all.select { |song| song.id.find { |str| str =~ regex } }
  end

  def self.find(regex)
    find_all(regex).first
  end

  def initialize(album, title)
    @album = album
    @title = title.split(".mp3")[0]
  end

  def id
    [album, title]
  end

  def audio
    @audio ||= ChorsFile.new(self, kind: :audio)
  end

  def chromagram(chroma_algorithm: :stft, norm: 2, n_fft: 2048,
                 hop_length: 512)
    Chromagram.new(self, chroma_algorithm, norm, n_fft: n_fft,
                   hop_length: hop_length)
  end

  def ground_truth
    @ground_truth ||= Annotation.new(self, kind: :ground_truth).data
  end

  def pretty_print(recognition_params, to: nil)
    time = 0
    chords = chords_without_dup(recognition_params)
    to ||= chords.last[1]
    annotation_loop(chords, ground_truth) do |chord, gt_chord, dur|
      break if time > to

      next_time = (time + dur).round(2)
      print "#{time}\t#{next_time}\t#{chord}\t#{gt_chord}\n"
      time = next_time
    end
    nil
  end

  def chords_without_dup(recognition_params)
    chords = chords(*recognition_params)

    chords_without_dup = chords[0..-2].select.with_index do |on_off_chord, i|
      chord = on_off_chord.last
      next_chord = chords[i + 1].last
      chord != next_chord
    end

    next_on = 0
    chords_without_dup.each do |on_off_chord|
      on_off_chord[0] = next_on
      next_on = on_off_chord[1]
    end
  end

  def chords(templates, chroma_algorithm: :stft, chromas_norm: 2,
             smooth_chromas: 0, post_filtering: false, n_fft: 2048,
             hop_length: 512)
    prefix = [
      chroma_algorithm,
      templates.name,
      chromas_norm,
      n_fft,
      hop_length,
      smooth_chromas,
      post_filtering || 'no-pf'
    ].join("_")

    file = Annotation.new(self, kind: :chords, prefix: prefix)

    return file.data if file.exists?

    song_fold = templates.song_fold self

    chromagram = chromagram(
      chroma_algorithm: chroma_algorithm,
      norm: chromas_norm,
      n_fft: n_fft,
      hop_length: hop_length
    )
    chromas = smooth(chromagram.chromas, smooth_chromas)

    chords = chromas.map do |chroma|
      chord = templates.best_match chroma, fold: song_fold
      [chroma.on, chroma.off, chord]
    end

    chords = post_filter(chords) if post_filtering

    file.write chords

    chords
  end

  def smooth(chromas, k=5)
    return chromas if k == 0

    number_of_chromas = chromas.size
    chromas.each_with_index do |chroma, i|
      from = [i - k, 0].max
      to = [i + k, number_of_chromas - 1].min

      chroma.feature = chromas_features_average(chromas[from..to])
    end
  end

  def chromas_features_average(chromas)
    n = chromas.size
    chromas.map(&:feature).transpose.map do |note_intensities|
      note_intensities.sum.to_f / n
    end
  end

  def post_filter(chords)
    minimum_consecutive_frames_for_a_chord = 5
    k = minimum_consecutive_frames_for_a_chord / 2

    n = chords.size
    chords.each.with_index do |chord, i|
      from = [i - k, 0].max
      to = [i + k, n - 1].min

      chords[i][2] = majority(chords[from..to].map(&:last)) || chord.last
    end

    chords
  end

  def majority(chords)
    chords_with_counts = chords.map.with_index do |chord, i|
      [chords.count(chord), i, chord]
    end

    chords_with_counts.sort!.reverse!

    chords_with_counts.first[0] > 1 ? chords_with_counts.first[2] : nil
  end

  def evaluation(experiment)
    file = ChorsFile.new(self, kind: :experiment, prefix: experiment.id)

    return YAML.load(file.read) if file.exists?

    chords = chords(*experiment.recognition_params)
    evaluation = Evaluation.new(chords, ground_truth)
    file.write evaluation.results.to_yaml
    evaluation.results
  end
end
