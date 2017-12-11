png_name = '07_1.png'

results = {
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
  )
}

g = Gruff::Bar.new(800)
g.left_margin = g.right_margin = 40
results.each do |k, v|
  best_result = v.results.sort_by { |_, e| e['precision'] }.first[1]['precision']
  g.data(k, best_result)
end
g.minimum_value = 0
g.maximum_value = 0.6
g.write "figs/notebooks/#{png_name}"

