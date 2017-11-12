require File.expand_path("../chors.rb", __FILE__)

class Experiment
  def initialize(chroma_algorithm: :stft, templates: :bin,
                 normalize_templates: nil, normalize_chromas: :inf,
                 smooth_frames: 0, post_filtering: false)
    @chroma_algorithm = chroma_algorithm
    @templates = templates
    @normalize_templates = normalize_templates
    @normalize_chromas = normalize_chromas
    @smooth_frames = smooth_frames
    @post_filtering = post_filtering
  end

  def id
    @id ||= [
      @chroma_algorithm,
      @templates,
      @normalize_templates,
      @normalize_chromas,
      @smooth_frames,
      @post_filtering
    ].map { |attribute| attribute || "nil" }.join("_")
  end

  def description
    @description ||= <<~TXT
      Chord Recognition experiment with the following parameters:

      \tchroma_algorithm     => #{@chroma_algorithm}
      \ttemplates            => #{@templates}
      \tnormalize_templates  => #{@normalize_templates}
      \tnormalize_chromas    => #{@normalize_chromas}
      \tsmooth_frames        => #{@smooth_frames}
      \tpost_filtering       => #{@post_filtering}

    TXT
  end

  def results
    @results ||= already_ran? ? load_results : run
  end

  def directory
    @directory ||= File.expand_path("../../experiments/#{id}", __FILE__)
  end

  private

  def already_ran?
    return false unless File.directory(directory)
    File.exists?(path_of :results)
  end

  def run
    create_directory

    save_description

    # load_songs

    # load_templates

    # smooth_frames if @smooth_frames

    # classify_chords_in_frames

    # save_results

    # Results format
    #  {
    #   avg: bla,
    #   worst_recognition: {
    #     file: 'bla',
    #     precision: 0
    #   },
    #   best_recognition: {
    #     file: 'bla2',
    #     precision: 1
    #   },
    #   folds: [
    #     { avg: 0, best: {}, worst: {} },
    #     { avg: 0, best: {}, worst: {} }
    #   ]
    # }
  end

  def create_directory
    Dir.mkdir directory unless Dir.exists? directory
  end

  def save_description
    File.open(path_of :description, "w") { |f| f << description }
  end

  def load_results
    results_text = File.read(path_of :results)
    YAML.parse results_text
  end

  def path_of(file, file_format: :yml)
    "#{directoy}/#{[file].flatten.join("/")}.#{file_format}"
  end
end
