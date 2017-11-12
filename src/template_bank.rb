require File.expand_path("../chors.rb", __FILE__)

class TemplateBank
  def initialize(binary: true, normalize: false, folds: 1,
                 chroma_algorithm: :stft)
    @binary = binary
    @folds = folds
  end

  def name
    @binary ? :bin : :learned
  end

  def normalize?
    !!@normalize
  end

  def best_match(chroma, fold: 0)
    templates[fold - 1].max_by { |_, template| chroma.similarity template }[0]
  end

  def name
    "#{@binary ? :binary : :learned}"
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
    # TODO
  end
end
