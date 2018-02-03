png_name = '11-cqt-stft-learn-compressao.png'

compression_factors = 0, 5, 10, 20, 30, 50, 80, 100
smooth_windows = 0, 5, 10, 12

experiments = {
  'STFT' => compression_factors.map do |compression_factor|
    Experiment.new(
      templates: :learn,
      chroma_algorithm: :stft,
      compression_factor: compression_factor
    )
  end,
  'CQT' => compression_factors.map do |compression_factor|
    Experiment.new(
      templates: :learn,
      chroma_algorithm: :cqt,
      compression_factor: compression_factor
    )
  end,
}

Gruff::Line.new('900x600').tap do |g|
  g.x_axis_label = 'Fator de compressão'
  g.y_axis_label = 'Precisão'

  # g.left_margin = g.right_margin = 40
  g.show_vertical_markers = true

  g.labels = compression_factors.map { |f| [f, f.to_s] }.to_h

  experiments.each do |name, list|
    data = list.zip(compression_factors).map do |exp, k|
      [k, exp.results.map { |_, h| h['precision'] }.max]
    end
    data = data.transpose

    g.dataxy name, data[0], data[1]
  end

  g.minimum_value = 0.25
  g.maximum_value = 0.32

  g.write "figs/notebooks/#{png_name}"
end ; 1

