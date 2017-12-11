g = Gruff::Bar.new(800)
g.left_margin = g.right_margin = 40

g.data('CQT  4096, suavização com k=8 ', 52.7)
g.data('CQT  2048, suavização com k=30', 53.2)
g.data('STFT 4096, suavização com k=10', 46.2)
g.data('STFT 2048, suavização com k=40', 43.4)

g.minimum_value = 30
g.maximum_value = 60
g.write "figs/notebooks/09-resultados-4096.png"
