# Projeto de Modelagem Bayesiana do Índice de Performance dos Estudantes  

## Estrutura do Projeto

- **modelo.R**: Script principal do projeto, localizado na raiz do diretório.  
- **graficos/**: Pasta onde são salvos os gráficos gerados pelo script.
- **Student_Performance.csv**: Arquivo de dados utilizado para análise.

## Descrição do Script `modelo.R`

O arquivo `modelo.R` realiza a modelagem estatística do índice de performance dos estudantes utilizando uma abordagem Bayesiana. O script executa as seguintes etapas principais:

1. **Carregamento e preparação dos dados**: Lê o arquivo de dados e ajusta as variáveis necessárias.
2. **Ajuste do modelo Bayesiano**: Utiliza o pacote `brms` para ajustar uma regressão linear Bayesiana, considerando variáveis como horas de estudo, notas anteriores, atividades extracurriculares, horas de sono e prática de questões.
3. **Inferência e diagnóstico**: Realiza inferência via MCMC, calcula estatísticas dos parâmetros (como média, erro padrão, intervalos de credibilidade e R-hat), e gera diagnósticos de convergência.
4. **Visualização**: Gera e salva gráficos de traceplots, histogramas das amostras e gráficos de predição.
5. **Comparação com modelo clássico**: Compara os resultados do modelo Bayesiano com uma regressão linear clássica.
6. **Avaliação do modelo**: Calcula métricas de erro (MAE, MSE, RMSE, R²) e gera gráficos de resíduos.

O script é autoexplicativo e modular, facilitando a análise e a reprodução dos resultados.