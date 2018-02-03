png_name = '03-stft-e-cqt-templates-bin-e-aprendidos.png'

experiments = {
  'STFT - templates binários': Experiment.new,
  'STFT - templates aprendidos': Experiment.new(templates: :learn),
  'CQT - templates binários': Experiment.new(chroma_algorithm: :cqt),
  'CQT - templates aprendidos': Experiment.new(chroma_algorithm: :cqt,
                                               templates: :learn)
}

Gruff::Bar.new.tap do |g|
  # g.title = 'Precisões'
  g.left_margin = g.right_margin = 60

  g.show_labels_for_bar_values = true

  experiments.each do |name, experiment|
    g.data name, experiment.results.map { |_, h| h['precision'] }.mean
  end

  g.minimum_value = 0
  g.maximum_value = 0.4

  g.write "figs/notebooks/#{png_name}"
end ; 1

