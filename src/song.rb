require File.expand_path("../chors.rb", __FILE__)

class Song
  attr_reader :album, :title

  def initialize(album, title)
    @album = album
    @title = title.split(".mp3")[0]
  end

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

  def id
    [album, title]
  end

  def audio
    @audio ||= ChorsFile.new(self, kind: :audio)
  end

  def chromagram(chroma_algorithm: :stft, norm: 2)
    Chromagram.chromas(self, chroma_algorithm: chroma_algorithm, norm: norm)
  end

  def ground_truth
    @ground_truth ||= Annotation.new(self, kind: :ground_truth).data
  end

  def chords(templates, chroma_algorithm: nil, normalize_chromas: nil,
             smooth_frames: nil, post_filtering: nil)
    prefix = [
      chroma_algorithm,
      templates.name,
      templates.normalize?,
      normalize_chromas,
      smooth_frames,
      post_filtering
    ].map { |attribute| attribute || "nil" }.join("_")

    file = Annotation.new(self, kind: :chords, prefix: prefix)

    return file.data if file.exists?

    # smooth_frames if @smooth_frames

    song_fold = templates.song_fold self

    chromas = chromagram(chroma_algorithm: chroma_algorithm)

    chords = chromas.map do |chroma|
      chord = templates.best_match chroma, fold: song_fold
      [chroma.on, chroma.off, chord]
    end

    file.write chords

    chords
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
