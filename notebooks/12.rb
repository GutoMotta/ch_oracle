song = Song.all.shuffle.first

compression_factors = 0, 5, 10, 20, 30, 40, 50, 80, 100
experiments = compression_factors.map do |compression_factor|
  Experiment.new(
    compression_factor: compression_factor,
    chroma_algorithm: :cqt,
    templates: :learn
  )
end

Gruff::Line.new('900x600').tap do |g|
  g.title = 'Precisões com compressão espectral em canções específicas'
  g.x_axis_label = 'Fator de compressão'
  g.left_margin = g.right_margin = 40
  g.show_vertical_markers = true

  g.labels = compression_factors.map { |f| [f, f.to_s] }.to_h

  values_y = experiments.map do |exp|
    song.evaluation(exp)['precision']
  end

  g.dataxy song.title, compression_factors, values_y

  g.minimum_value = 0
  g.maximum_value = 1

  g.write "figs/notebooks/compressao-musicas-especificas.png"
end
