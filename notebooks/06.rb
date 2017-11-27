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

draw '06-distribuicoes-stft-bin-smooth.png', {
  'STFT - sem suavização (k=0)': Experiment.new,
  'STFT - suavização com k=10': Experiment.new(smooth_chromas: 10),
  'STFT - suavização com k=30': Experiment.new(smooth_chromas: 30),
  'CQT - sem suavização (k=0)': Experiment.new(chroma_algorithm: :cqt),
  'CQT - suavização com k=10': Experiment.new(
    chroma_algorithm: :cqt,
    smooth_chromas: 10
  ),
  'CQT - suavização com k=30': Experiment.new(
    chroma_algorithm: :cqt,
    smooth_chromas: 30
  ),
}
