png_name = '13-stft-learn-bin-compressao-smooth.png'

compression_factors = 0, 5

experiments = {
  'STFT com L = 0' => compression_factors.map do |compression_factor|
    Experiment.new(
      chroma_algorithm: :stft,
      templates: :learn,
      compression_factor: compression_factor,
      smooth_chromas: 0
    )
  end + [Experiment.new(smooth_chromas: 0)],
  'STFT com L = 5' => compression_factors.map do |compression_factor|
    Experiment.new(
      chroma_algorithm: :stft,
      templates: :learn,
      compression_factor: compression_factor,
      smooth_chromas: 5
    )
  end + [Experiment.new(smooth_chromas: 5)],
  'STFT com L = 10' => compression_factors.map do |compression_factor|
    Experiment.new(
      chroma_algorithm: :stft,
      templates: :learn,
      compression_factor: compression_factor,
      smooth_chromas: 10
    )
  end + [Experiment.new(smooth_chromas: 10)],
  'STFT com L = 12' => compression_factors.map do |compression_factor|
    Experiment.new(
      chroma_algorithm: :stft,
      templates: :learn,
      compression_factor: compression_factor,
      smooth_chromas: 15
    )
  end + [Experiment.new(smooth_chromas: 15)],
}

Gruff::Bar.new('800x600').tap do |g|
  g.x_axis_label = 'Parâmetro L de suavização temporal'
  g.y_axis_label = 'Precisão'


  g.bar_spacing = 0.7

  g.labels = {
    0 => '0',
    1 => '5',
    2 => '10',
    3 => '15',
  }

  g.minimum_value = 0
  g.maximum_value = 0.5

  g.data 'STFT, templates aprendidos, sem compressão    ', experiments.values.map { |a| a[0] }.map(&:best_precision)
  g.data 'STFT, templates aprendidos, compressão fator 5', p(experiments.values.map { |a| a[1] }.map(&:best_precision))
  g.data 'STFT, templates binários, sem compressão        ', p(experiments.values.map { |a| a[2] }.map(&:best_precision))

  g.write "figs/notebooks/#{png_name}"
end ; 1

