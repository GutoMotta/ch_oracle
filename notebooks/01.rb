png_name = '01-templates-binarios-e-aprendidos.png'

experiments = {
  'Templates Binários': Experiment.new,
  'Templates Aprendidos': Experiment.new(templates: :learn)
}

Gruff::Bar.new.tap do |g|
  # g.title = 'Precisões'
  g.left_margin = g.right_margin = 60

  g.show_labels_for_bar_values = true

  experiments.each do |name, experiment|
    g.data name, experiment.results.map { |_, h| h['precision'] }.max
  end

  g.minimum_value = 0
  g.maximum_value = 1

  g.write "figs/notebooks/#{png_name}"
end

