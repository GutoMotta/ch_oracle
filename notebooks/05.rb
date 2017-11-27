def draw(png_name, experiments, first: 180)
  Gruff::Line.new(1000).tap do |g|
    g.left_margin = g.right_margin = 40

    max = 0
    experiments.each do |name, experiment|
      data = experiment.all_results.map(&:precision).sort.first(first)
      max = [data.max, max].max

      g.data name, data
    end

    g.minimum_value = 0
    g.maximum_value = max.round(1)

    g.dot_radius = 4 - first / 60

    g.write "figs/notebooks/#{png_name}"
  end ; 1
end

draw '05-distribuicoes-stft-bin-aprendidos.png', {
  'STFT - templates binários': Experiment.new,
  'STFT - templates aprendidos': Experiment.new(templates: :learn),
}


draw '05-distribuicoes-cqt-bin-aprendidos.png', {
  'CQT - templates binários': Experiment.new(chroma_algorithm: :cqt),
  'CQT - templates aprendidos': Experiment.new(chroma_algorithm: :cqt,
                                               templates: :learn)
}

draw '05-distribuicoes-inicial.png', {
  'STFT - templates binários': Experiment.new,
  'STFT - templates aprendidos': Experiment.new(templates: :learn),
  'CQT - templates binários': Experiment.new(chroma_algorithm: :cqt),
  'CQT - templates aprendidos': Experiment.new(chroma_algorithm: :cqt,
                                               templates: :learn)
}, first: 10

