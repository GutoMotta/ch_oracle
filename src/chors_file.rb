class ChorsFile
  KIND_REQUIRE_PREFIX = %i(chromagram experiment chords)
  ALLOWED_KINDS = %i(audio chromagram ground_truth experiment chords)

  attr_reader :album, :song, :kind, :experiment_id

  def initialize(song, kind: nil, prefix: nil)
    @song = song
    @kind = kind
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
      when :audio then :mp3
      when :chromagram then :crmg
      when :ground_truth then :lab
      when :experiment then :yml
      when :chords then :out
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
      ['audios']
    when :chromagram
      ['chromagrams', @prefix]
    when :ground_truth
      ['ground_truth']
    when :experiment
      ['experiments', @prefix, 'results']
    when :chords
      ['chords', @prefix]
    else
      raise "kind #{kind} has no path definition"
    end.flatten.compact.join('/')
  end

  def validate
    unless ALLOWED_KINDS.include?(kind)
      raise "invalid ChorsFile kind: #{kind}"
    end

    if @prefix.nil? && KIND_REQUIRE_PREFIX.include?(kind)
      raise 'prefix should be present'
    end
  end

  def make_path_directories
    FileUtils::mkdir_p(dir) unless File.directory?(dir)
  end
end
