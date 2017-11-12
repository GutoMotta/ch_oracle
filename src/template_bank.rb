require File.expand_path("../chors.rb", __FILE__)

class TemplateBank
  def initialize(binary: true, folds: 1)
    @binary = binary
    @folds = folds
  end

  def best_match(chroma, fold: 1)
    templates[fold - 1].max_by { |_, template| chroma.similarity template }[0]
  end

  def name
    "#{@binary ? :binary : :learned}"
  end

  def song_lists
    unless @song_lists
      build_templates unless exists?
      @song_lists = 1.upto(@folds).map { |fold| load_song_list(fold) }
    end

    @song_lists
  end

  def each
    [templates, song_list].transpose.each do |template, song_list|
      yield template, song_list
    end
  end

  def self.dir
    @@dir ||= File.expand_path("../../templates", __FILE__)
  end


  private

  def templates
    unless @templates
      build_templates unless exists?
      @templates = 1.upto(@folds).map { |fold| load_templates(fold) }
    end

    @templates
  end

  def exists?
    1.upto(@folds).map { |fold| File.exists? path(fold) }.all?
  end

  def dir
    "#{self.class.dir}/#{name}"
  end

  def path(fold=1, kind: :templates)
    "#{dir}/fold#{fold}.#{kind == :templates ? 'yml' : kind}"
  end

  def load_templates(fold)
    YAML.load File.read(path(fold))
  end

  def load_song_list(fold)
    File.read(path(fold, kind: :list)).lines.map(&:strip)
  end

  def write(file_path, content)
    FileUtils::mkdir_p(dir) unless File.directory?(dir)
    File.open(file_path, 'w') { |f| f << content }
  end

  def build_templates
    templates_array = @binary ? build_binary_templates : learn_templates

    templates_array.each_with_index do |templates_and_list, fold|
      templates, song_list = templates_and_list

      write(path(fold + 1), templates.to_yaml)

      write(path(fold + 1, kind: :list), song_list.join("\n"))
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

    [chromas, Song.all]
  end

  def learn_templates
    # TODO
  end
end
