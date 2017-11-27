png_name = '04-stft-e-cqt-bin-suavizacao-temporal.png'

smooth_values = 0, 5, 10, 20, 30, 40, 50

experiments = {
  'STFT': smooth_values.map do |k|
    Experiment.new(smooth_chromas: k)
  end,
  'CQT': smooth_values.map do |k|
    Experiment.new(chroma_algorithm: :cqt, smooth_chromas: k)
  end
}

Gruff::Line.new.tap do |g|
  # g.title = 'Precisões com suavização temporal'
  g.x_axis_label = 'Número de janelas suavizadas'
  g.left_margin = g.right_margin = 40
  g.show_vertical_markers = true

  g.labels = smooth_values.map { |k| [k, k.to_s] }.to_h

  experiments.each do |name, list|
    data = list.zip(smooth_values).map do |exp, k|
      [k, exp.results.map { |_, h| h['precision'] }.max]
    end
    data = data.transpose

    g.dataxy name, data[0], data[1]
  end

  g.minimum_value = 0.2
  g.maximum_value = 0.6

  g.write "figs/notebooks/#{png_name}"
end ; 1

