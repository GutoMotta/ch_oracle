# Diário de bordo

## 30 de julho de 2017
A ideia era encontrar no Müller alguma forma de avaliar um algoritmo de reconhecimento de acordes (o que descobri que está na seção **5.2.2**) e implementá-la. O problema é que isso depende de uma base de dados de acordes anotados.

Havia encontrado uma BD que seria útil no site [Isophonics](http://www.isophonics.net). Entrando no site hoje, estava fora do ar (não sei como lidar).

Mas, em linhas gerais, tenho que "arredondar" a forma de chamar o Choracle, para conseguir rodar um script e sair reconhecendo acordes em uma base.

Também tenho que escrever o **EvaluateChR**, um script para avaliar um reconhecimento comparando o output com um arquivo de anotações de acorde gerado manualmente.

Com isso pronto, posso começar a experimentar valores diferentes de threshold para saber como ele impacta na qualidade do reconhecimento.