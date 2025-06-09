# EDA.R - Análise Exploratória de Dados para Student_Performance.csv

# Carregar pacotes necessários
library(ggplot2)
library(dplyr)
library(GGally)

# Criar pasta para os gráficos, se não existir
dir.create('graficos/EDA', showWarnings = FALSE)

# 1. Carregar os dados
dados <- read.csv('Student_Performance.csv')

# 2. Visualizar as primeiras linhas e estrutura
glimpse(dados)
head(dados)
colnames(dados)
# 3. Resumo estatístico
dados %>% summary()

# 4. Verificar valores ausentes
cat('Valores ausentes por coluna:\n')
print(colSums(is.na(dados)))

# 5. Histogramas para variáveis numéricas
num_cols <- c('Hours.Studied', 'Previous.Scores', 'Sleep.Hours', 'Sample.Question.Papers.Practiced', 'Performance.Index')
for (col in num_cols) {
  p <- ggplot(dados, aes_string(x=col)) +
    geom_histogram(bins=20, fill='skyblue', color='black') +
    theme_bw() +
    ggtitle(paste('Histograma de', col))
  ggsave(filename = paste0('graficos/EDA/histograma_', col, '.png'), plot = p, width = 6, height = 4)
}

# 6. Boxplots para variáveis numéricas
for (col in num_cols) {
  p <- ggplot(dados, aes_string(y=col)) +
    geom_boxplot(fill='orange', color='black') +
    theme_bw() +
    ggtitle(paste('Boxplot de', col))
  ggsave(filename = paste0('graficos/EDA/boxplot_', col, '.png'), plot = p, width = 4, height = 6)
}

# 7. Gráfico de barras para atividades extracurriculares
if('Extracurricular.Activities' %in% colnames(dados)) {
  p <- ggplot(dados, aes(x=Extracurricular.Activities)) +
    geom_bar(fill='purple', color='black') +
    theme_bw() +
    ggtitle('Distribuição de Atividades Extracurriculares')
  ggsave(filename = 'graficos/EDA/bar_atividades_extracurriculares.png', plot = p, width = 6, height = 4)
}

# 8. Matriz de correlação
if (all(num_cols %in% colnames(dados))) {
  p <- ggpairs(dados[, num_cols])
  ggsave(filename = 'graficos/EDA/matriz_correlacao.png', plot = p, width = 10, height = 10)
}

# 9. Relação entre horas de estudo e índice de performance
p <- ggplot(dados, aes(x=Hours.Studied, y=Performance.Index)) +
  geom_point(color='blue') +
  geom_smooth(method='lm', se=FALSE, color='red') +
  theme_bw() +
  ggtitle('Horas de Estudo vs Índice de Performance')
ggsave(filename = 'graficos/EDA/horas_estudo_vs_performance.png', plot = p, width = 6, height = 4)

