class Experiment
  def initialize(chroma_algorithm: :stft, templates: :bin,
                 templates_norm: 2, chromas_norm: 2,
                 smooth_chromas: 0, post_filtering: false,
                 n_fft: 4096, hop_length: 2048,
                 verbose: true, compression_factor: 0)
    @templates = TemplateBank.new(
      binary: templates == :bin,
      chroma_algorithm: chroma_algorithm,
      norm: templates_norm,
      hop_length: hop_length,
      n_fft: n_fft,
      compression_factor: compression_factor
    )

    @chroma_algorithm = chroma_algorithm
    @chromas_norm = chromas_norm
    @smooth_chromas = smooth_chromas
    @post_filtering = post_filtering
    @n_fft = n_fft
    @hop_length = hop_length
    @compression_factor = compression_factor

    @verbose = verbose
  end

  def id
    @id ||= attributes.join("_")
  end

  def attributes
    @attributes ||= [
      @chroma_algorithm,
      @templates.name,
      @chromas_norm,
      @n_fft,
      @hop_length,
      @smooth_chromas,
      @post_filtering || 'no-pf',
      @compression_factor
    ]
  end

  def name
    @name ||= [
      @chroma_algorithm,
      @templates.name,
      "suav. temp. #{@smooth_chromas}",
      "#{@post_filtering ? 'com' : 'sem'} pos filtr."
    ].join(', ')
  end

  def description
    @description ||= <<~TXT
      Chord Recognition experiment with the following parameters:

      \tchroma_algorithm     => #{@chroma_algorithm}
      \ttemplates            => #{@templates.name}
      \ttemplates_norm       => #{@templates_norm}
      \tchromas_norm         => #{@chromas_norm}
      \tsmooth_chromas       => #{@smooth_chromas}
      \tpost_filtering       => #{@post_filtering}
      \tn_fft                => #{@n_fft}
      \thop_length           => #{@hop_length}
      \tcompression_factor   => #{@compression_factor}

    TXT
  end

  def report
    _result = best_result
    numbers = _result['mean'], _result['stdev'], _result['max']

    puts
    puts numbers.map { |number| format_for_result(number) }.join(' & ')
    puts

    nil
  end

  def best_fold
    fold, result = results.max_by { |fold, result| result['precision'] }
    {
      fold => result
    }
  end

  def best_precision
    best_result['precision']
  end

  def best_result
    results.max_by { |fold, result| result['precision'] }.last
  end

  def results
    @results ||= already_ran? ? load_results : run
  end

  def all_results
    @all_results ||= Song.all.map do |song|
      attributes = song.evaluation(self).merge({ 'song': song })
      OpenStruct.new attributes
    end

    @all_results.sort_by(&:precision)
  end

  def directory
    @directory ||= File.expand_path("../../experiments/#{id}", __FILE__)
  end

  def recognition_params
    [
      @templates,
      {
        chroma_algorithm: @chroma_algorithm,
        chromas_norm: @chromas_norm,
        smooth_chromas: @smooth_chromas,
        post_filtering: @post_filtering,
        hop_length: @hop_length,
        n_fft: @n_fft,
        compression_factor: @compression_factor
      }
    ]
  end

  private

  def already_ran?
    File.exists?(results_path)
  end

  def run
    results = {}

    total_folds = @templates.songs.size
    @templates.songs.each_with_index do |song_list, fold|
      total_songs = song_list.size
      fold_results = song_list.map.with_index do |song, i|
        if @verbose
          percent = 1.0 * (i + 1) * (fold + 1) / (total_songs * total_folds)
          puts "running #{id}: #{(percent * 100).round(2).to_s.rjust(6, ' ')}%"
        end

        song.evaluation(self)
      end

      results["fold#{fold}"] = average(fold_results)
    end

    save_results(results)
    save_description

    results
  end

  def average(results)
    precisions = results.map { |result| result['precision'] }
    mean = precisions.mean
    stdev = precisions.standard_deviation

    {
      'mean' => mean,
      'stdev' => stdev,
      'precision' => mean,
      'max' => precisions.max,
      'min' => precisions.min
    }
  end

  def save_description
    File.open(path_of(:description, :txt), "w") { |f| f << description }
  end

  def save_results(results)
    File.open(results_path, "w") { |f| f << results.to_yaml }
  end

  def load_results
    YAML.load(File.read results_path)
  end

  def results_path
    path_of :results
  end

  def path_of(file, file_format=:yml)
    "#{directory}/#{[file].flatten.join("/")}.#{file_format}"
  end

  def format_for_result(number)
    "${#{(100.0 * number).round(2)}}\\%$"
  end
end
