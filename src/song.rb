require File.expand_path("../chors.rb", __FILE__)

class Song
  attr_reader :album, :title

  def initialize(album, title)
    @album = album
    @title = title[/.*(?=\.mp3)?/]
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
end
