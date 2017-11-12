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

  def chromagram(chroma_kind: :stft, norm: 2)
    Chromagram.chromas(self, chroma_kind: chroma_kind, norm: norm)
  end

  def ground_truth
    @ground_truth_file ||= ChorsFile.new(self, kind: :audio)

    @ground_truth ||= @ground_truth_file.read.lines.map do |line|
      on, off, chord = line.strip
      [on.to_f, off.to_f, chord]
    end
  end

  def chords(binary_templates: true)
    templates = TemplateBank.new(binary: binary_templates)

    chromagram.map do |chroma|
      chord = templates.best_match chroma
      [chroma.on, chroma.off, chord]
    end

    # smooth_frames if @smooth_frames

    # classify_chords_in_frames
  end
end
