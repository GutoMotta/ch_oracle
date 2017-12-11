class Chromagram < ChorsFile
  def initialize(song, chroma_algorithm, norm, n_fft: 2048, hop_length: 512,
                 sr: 22050)
    unless %i(stft cqt).include?(chroma_algorithm)
      raise "invalid chroma chroma_algorithm: #{chroma_algorithm}"
    end

    @song = song
    @chroma_algorithm = chroma_algorithm
    @norm = norm == :inf ? Numpy.inf : norm
    @n_fft = n_fft
    @hop_length = hop_length
    @sr = sr

    prefix = chroma_algorithm, norm, n_fft, hop_length

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
    y, sr = Librosa.load(@song.audio.path, sr: @sr).to_a

    chromas =
      case @chroma_algorithm
      when :stft
        Librosa.feature.chroma_stft(
          y: y,
          sr: sr,
          norm: @norm,
          n_fft: @n_fft,
          hop_length: @hop_length
        )
      when :cqt
        Librosa.feature.chroma_cqt(
          y: y,
          sr: sr,
          norm: @norm,
          hop_length: @hop_length
        )
      end

    [chromas.tolist.to_a, @hop_length.to_f / sr.to_f]
  end
end
