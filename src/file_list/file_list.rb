require "yaml"
require "fileutils"

class FileList
  attr_reader :audio_files, :recognized_files, :gt_files,
              :chroma_files, :measure_files, :measures_dir, :size

  def initialize(scope_directory, list_file_name=nil)
    list_file_name ||= File.expand_path("../file_list.yml", __FILE__)
    @data = YAML.load_file list_file_name

    @audio_files      = create_list("audio")
    @gt_files         = create_list("output", "ground_truth")
    @chroma_files     = create_list("chroma", scope_directory)
    @recognized_files = create_list("output", scope_directory)
    @measure_files    = create_list("measure", scope_directory)

    @size = @audio_files.size
  end

  def count
    @size
  end

  def create_list(list_name, label=nil)
    mkdir! "#{list_name}s"
    mkdirs! dir_name("#{list_name}s", label)

    extension_name = label == "ground_truth" ? "ground_truth" : list_name

    files = @data["albuns"].map do |album, songs|
      dir = dir_name("#{list_name}s", label, album)
      songs.map { |song| file_path(dir, song, extension_name) }
    end

    files.flatten.sort
  end

  def mkdir!(dir)
    path = spath(dir)
    FileUtils.mkdir_p(path) unless File.directory?(path)
  end

  def mkdirs!(dir)
    mkdir!(dir)
    @data["albuns"].each { |album, songs| mkdir!("#{dir}/#{album}") }
  end

  def dir_name(*items)
    items.compact.join("/")
  end

  def file_path(dir, basename, extension_name)
    ext = @data["extensions"][extension_name]
    spath("#{dir}/#{basename}.#{ext}")
  end

  def spath(path)
    File.expand_path("../../../#{path}", __FILE__)
  end
end
