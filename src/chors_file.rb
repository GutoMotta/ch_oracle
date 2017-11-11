require File.expand_path("../chors.rb", __FILE__)

class ChorsFile
  KIND_REQUIRE_PREFIX = %i(chromagram)
  ALLOWED_KINDS = %i(audio chromagram ground_truth)

  attr_reader :album, :song, :kind, :experiment_id

  def initialize(song, kind: nil, experiment_id: nil, prefix: nil)
    @song = song
    @kind = kind
    @experiment_id = experiment_id
    @prefix = prefix

    validate
  end

  def write(content, force: false)
    raise 'cannot write on an audio ChorsFile' if kind == :audio

    if force || !File.exists?(path)
      make_path_directories
      File.open(path, 'w') { |file| file << content }
    end
  end

  def read
    raise 'cannot read an audio ChorsFile' if kind == :audio

    @content ||= File.read(path)
  end

  def path
    @path ||= "#{dir}/#{song.title}.#{extension}"
  end

  def dir
    @dir ||= File.expand_path(
      "../../#{dir_path_inside_chors}/#{song.album}",
      __FILE__
    )
  end

  def extension
    @extension ||=
      case kind
      when :audio then 'mp3'
      when :chromagram then 'crmg'
      when :ground_truth then 'lab'
      else
        raise "kind #{kind} has no extension definition"
      end
  end

  def exists?
    File.exists? path
  end

  private

  def dir_path_inside_chors
    case kind
    when :audio
      'audios'
    when :chromagram
      ['chromas', @prefix].flatten.compact.join('/')
    when :ground_truth
      'ground_truth'
    else
      raise "kind #{kind} has no path definition"
    end
  end

  def validate
    unless ALLOWED_KINDS.include?(kind)
      raise "invalid ChorsFile kind: #{kind}"
    end

    # if kind == :experiment && experiment_id.nil?
    #   raise 'experiment_id should be present'
    # end

    if @prefix.nil? && KIND_REQUIRE_PREFIX.include?(kind)
      raise 'prefix should be present'
    end
  end

  def make_path_directories
    FileUtils::mkdir_p(dir) unless File.directory?(dir)
  end
end
