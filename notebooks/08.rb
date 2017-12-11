png_name = '08-stft-e-cqt-bin-suavizacao-temporal-4096.png'

smooth_values_4096 = 0, 5, 8, 9, 10, 12, 15, 18
experiments_4096 = {
  'STFT 4096': smooth_values_4096.map do |k|
    Experiment.new(
      smooth_chromas: k,
      n_fft: 4096,
      hop_length: 2048
    )
  end,
  'CQT 4096': smooth_values_4096.map do |k|
    Experiment.new(
      chroma_algorithm: :cqt,
      smooth_chromas: k,
      n_fft: 4096,
      hop_length: 2048
    )
  end
}

smooth_values_2048 = 0, 5, 10, 20, 30, 40, 50
experiments_2048 = {
  'STFT 2048': smooth_values_2048.map do |k|
    Experiment.new(smooth_chromas: k)
  end,
  'CQT 2048': smooth_values_2048.map do |k|
    Experiment.new(chroma_algorithm: :cqt, smooth_chromas: k)
  end
}

smooth_values = (smooth_values_2048 + smooth_values_4096).uniq.sort

Gruff::Line.new('900x600').tap do |g|
  g.title = 'Precisões com suavização temporal'
  g.x_axis_label = 'Número de janelas suavizadas'
  g.left_margin = g.right_margin = 40
  g.show_vertical_markers = true

  g.labels = 1.upto(10).map { |k| [k * 5, (k * 5).to_s] }.to_h

  experiments_4096.each do |name, list|
    data = list.zip(smooth_values_4096).map do |exp, k|
      [k, exp.results.map { |_, h| h['precision'] }.max]
    end
    data = data.transpose

    g.dataxy name, data[0], data[1]
  end

  experiments_2048.each do |name, list|
    data = list.zip(smooth_values_2048).map do |exp, k|
      [k, exp.results.map { |_, h| h['precision'] }.max]
    end
    data = data.transpose

    g.dataxy name, data[0], data[1]
  end

  g.minimum_value = 0.2
  g.maximum_value = 0.6

  g.write "figs/notebooks/#{png_name}"
end ; 1

