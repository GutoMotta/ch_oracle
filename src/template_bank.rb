class TemplateBank
  include AnnotationLoop
  attr_reader :norm

  FOLDS = 4

  def initialize(binary: true, chromas_norm: 2, norm: 2,
                 chroma_algorithm: :stft, n_fft: 2048, hop_length: 512)
    @binary = binary
    @folds = binary ? 1 : FOLDS
    @chromas_norm = chromas_norm
    @norm = norm
    @chroma_algorithm = chroma_algorithm
    @n_fft = n_fft
    @hop_length = hop_length
  end

  def name
    return :bin if @binary
    "t(#{@chroma_algorithm}-#{@chromas_norm}-#{@norm}-#{@n_fft}-#{@hop_length})"
  end

  def best_match(chroma, fold: 0)
    templates[fold - 1].max_by { |_, template| chroma.similarity template }[0]
  end

  def templates
    unless @templates
      build_templates unless exists?
      @templates = @folds.times.map { |fold| load_templates(fold) }
    end

    @templates
  end

  def songs
    unless @songs
      build_templates unless exists?
      @songs = @folds.times.map { |fold| load_songs(fold) }
    end

    @songs
  end

  def self.dir
    @@dir ||= File.expand_path("../../templates", __FILE__)
  end

  def song_fold(song)
    songs.index do |song_list|
      song_list.index { |s| s.id == song.id }
    end
  end


  private

  def exists?
    folds_existance = @folds.times.map do |fold|
      File.exists?(path fold) && File.exists?(path fold, kind: :list)
    end
    folds_existance.all?
  end

  def dir
    "#{self.class.dir}/#{name}"
  end

  def path(fold=0, kind: :templates)
    "#{dir}/fold#{fold}.#{kind == :templates ? 'yml' : kind}"
  end

  def load_templates(fold)
    YAML.load File.read(path(fold))
  end

  def load_songs(fold)
    File.read(path(fold, kind: :list)).lines.map { |path| Song.parse path }
  end

  def write(file_path, content)
    FileUtils::mkdir_p(dir) unless File.directory?(dir)
    File.open(file_path, 'w') { |f| f << content }
  end

  def build_templates
    templates_array = @binary ? build_binary_templates : learn_templates

    templates_array.each_with_index do |templates_and_songs, fold|
      templates, songs = templates_and_songs

      write(path(fold), templates.to_yaml)

      songs_paths = songs.map { |song| song.audio.path }

      write(path(fold, kind: :list), songs_paths.join("\n"))
    end
  end

  def build_binary_templates
    chromas = {}

    c_mayor = [1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0]
    c_minor = [1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0]

    labels = %w(C C# D D# E F F# G G# A A# B)

    labels.each_with_index do |label, i|
      chromas[label] = c_mayor.rotate(-i)
      chromas["#{label}:min"] = c_minor.rotate(-i)
    end

    [[chromas, Song.all]]
  end

  def learn_templates
    all_folds = @folds.times.to_a

    average_chromas = Hash.new do |h, k|
      h[k] = Hash.new { |h2, k2| h2[k2] = Array.new(12, 0) }
    end

    songs_by_fold.each_with_index do |songs, fold_to_skip|
      songs.each_with_index do |song, song_i|
        chromas = song.chromagram(
          chroma_algorithm: @chroma_algorithm,
          norm: @chromas_norm,
          hop_length: @hop_length,
          n_fft: @n_fft
        ).chromas

        chromas.map!(&:raw)

        chords = song.ground_truth

        (all_folds - [fold_to_skip]).each do |fold|
          accumulate_chords_chromas(chords, chromas, average_chromas, fold)
        end

        percent = (100.0 * song_i / songs.size).round(2)
        puts "building templates, fold #{fold_to_skip}: #{percent} %"
      end
    end

    average_chromas = divide_accumulated_chromas(average_chromas)

    average_chromas.zip(songs_by_fold)
  end

  def divide_accumulated_chromas(accumulated_chromas_hash)
    accumulated_chromas_hash.map do |fold, chords_chromas|
      templates = chords_chromas.map do |chord, chroma|
        accumulated = Vector[*chroma]

        norm =
          case @norm
          when 2 then accumulated.norm
          when :inf then accumulated.max
          end

        accumulated = (accumulated / norm).to_a

        [chord, accumulated]
      end

      templates.to_h
    end
  end

  def accumulate_chords_chromas(chords, chromas, average_chromas, fold)
    @chord_normalizer ||= ChordMatcher.new

    annotation_loop(chords, chromas) do |chord, chroma, duration|
      normalized_chord = @chord_normalizer.normalize(chord)

      if normalized_chord
        acc = average_chromas[fold][normalized_chord].zip(chroma).map(&:sum)
        average_chromas[fold][normalized_chord] = acc
      end
    end
  end

  def songs_by_fold
    all_songs = Song.all

    songs_by_fold = (1.0 * all_songs.size / @folds).ceil

    songs_lists = all_songs.shuffle.each_slice(songs_by_fold).to_a

    songs_lists.each_with_index do |songs, fold|
      content = songs.map { |song | song.audio.path }.join("\n")
      write(path(fold, kind: :list), content)
    end

    songs_lists
  end
end
