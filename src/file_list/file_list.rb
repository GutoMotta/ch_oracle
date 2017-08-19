require "yaml"
require "fileutils"

class FileList
  attr_reader :audio_files, :recognized_files, :ground_truth_files,
              :measure_files, :measures_dir, :count

  def initialize(output_dir, filelist=nil)
    filelist ||= File.expand_path("../file_list.yml", __FILE__)
    @data = YAML.load_file filelist
    @dirs = @data["files"].keys.sort
    @files = @dirs.map do |dir|
      @data["files"][dir].sort.map { |file| "#{dir}/#{file}" }
    end
    @files.flatten!.sort!

    @audio_files = make_list(@data["audio_extension"], "inputs")

    out = "outputs/#{output_dir}"
    create_all_dirs!(File.expand_path("../../../#{out}", __FILE__))
    @recognized_files = make_list(@data["choracle_extension"], out)

    out = "outputs/#{@data["ground_truth_dir"]}"
    @ground_truth_files = make_list(@data["ground_truth_extension"], out)

    sizes = [audio_files.size, recognized_files.size, ground_truth_files.size]
    raise "Something went wrong! Count recognized files" if sizes.uniq.size != 1

    out = "measures/#{output_dir}"
    @measures_dir = File.expand_path("../../../#{out}", __FILE__)
    create_all_dirs! @measures_dir

    @measure_files = make_list(".yml", out)

    @count = @recognized_files.size
  end

  def make_list(extension, dir)
    @files.map do |file|
      File.expand_path("../../../#{dir}/#{file}#{extension}", __FILE__)
    end.sort
  end

  def create_dir!(dirname)
    path = File.expand_path("../../../#{dirname}", __FILE__)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
  end

  def create_all_dirs!(dir)
    create_dir!(dir)
    @dirs.each { |d| create_dir!("#{dir}/#{d}") }
  end
end
