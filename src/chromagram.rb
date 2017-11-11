require File.expand_path("../chors.rb", __FILE__)

class Chromagram < ChorsFile
  HOP_LENGTH = 512

  def self.chromas(song, chroma_kind: :stft, norm: 2)
    new(song, chroma_kind, norm).chromas
  end

  def initialize(song, chroma_kind, norm)
    unless %i(stft cqt).include?(chroma_kind)
      raise "invalid chroma chroma_kind: #{chroma_kind}"
    end

    @song = song
    @chroma_kind = chroma_kind
    @norm = norm == :inf ? Numpy.inf : norm

    prefix = chroma_kind, norm

    super(song, kind: :chromagram, prefix: prefix)
  end

  def chromas
    @chromas ||= exists? ? load_chromas : compute_chromas
  end

  private

  def load_chromas
    read.lines.map { |line| Chroma.parse(line) }
  end

  def compute_chromas
    chromas, frame_duration = librosa_chroma_function_call

    chromas = chromas.transpose.map.with_index do |chroma, i|
      on = i * frame_duration
      off = on + frame_duration
      Chroma.new(on, off, chroma)
    end

    write chromas.map(&:to_s).join("\n")

    chromas
  end

  def librosa_chroma_function_call
    hop_length = HOP_LENGTH
    y, sr = Librosa.load(@song.audio.path).to_a

    chromas =
      case @chroma_kind
      when :stft
        Librosa.feature.chroma_stft(y=y, sr=sr, norm: @norm)
      when :cqt
        Librosa.feature.chroma_cqt(y=y, sr=sr, norm: @norm)
      end

    [chromas.tolist.to_a, hop_length.to_f / sr.to_f]
  end
end
