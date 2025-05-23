# modelo.R - Modelagem Bayesiana para o Índice de Performance dos Estudantes

# (c) Apresentação do modelo usado e explicação de suas componentes
# -------------------------------------------------------------------
# O modelo utilizado é uma regressão linear Bayesiana, onde o objetivo é prever o 'Performance.Index'
# a partir das variáveis explicativas do conjunto de dados:
#   - Hours.Studied
#   - Previous.Scores
#   - Extracurricular.Activities (convertida para fator)
#   - Sleep.Hours
#   - Sample.Question.Papers.Practiced
#
# O modelo pode ser representado por:
#   Performance.Index ~ Intercepto + β1*Hours.Studied + β2*Previous.Scores + β3*Extracurricular.Activities + β4*Sleep.Hours + β5*Sample.Question.Papers.Practiced + erro
#
# Onde cada β representa o efeito de cada variável sobre o índice de performance.
# No contexto Bayesiano, cada parâmetro do modelo possui uma distribuição a priori, e a inferência é feita sobre as distribuições a posteriori desses parâmetros.

# (d) Inferência MCMC
# -------------------
# A inferência dos parâmetros do modelo foi realizada via MCMC (Markov Chain Monte Carlo),
# que é um método para amostrar da distribuição a posteriori dos parâmetros.
#
# Para isso, foi utilizado o pacote 'brms', que facilita a modelagem Bayesiana em R e utiliza o 'Stan' como backend.
#
# Exemplo de implementação usando o pacote 'brms':
# ---------------------------------------------------
# install.packages('brms')
library(brms)

# Carregar os dados
dados <- read.csv('Student_Performance.csv')
dados$Extracurricular.Activities <- as.factor(dados$Extracurricular.Activities)

# Ajustar o modelo bayesiano
modelo <- brm(
  formula = Performance.Index ~ Hours.Studied + Previous.Scores + Extracurricular.Activities + Sleep.Hours + Sample.Question.Papers.Practiced,
  data = dados,
  family = gaussian(),   # Distribuição gaussiana para a resposta
  chains = 4,            # Número de cadeias MCMC
  iter = 2000,           # Número total de iterações por cadeia
  warmup = 500,          # Número de iterações de burn-in (descartadas)
  seed = 123,            # Semente para reprodutibilidade
  cores = 4              # Número de núcleos para paralelização
)

# Explicação das opções utilizadas:
# - chains: número de cadeias independentes de MCMC (padrão: 4)
# - iter: número total de iterações por cadeia (padrão: 2000)
# - warmup: número de iterações iniciais descartadas (burn-in)
# - seed: semente para garantir resultados reprodutíveis
# - cores: número de núcleos de CPU usados para paralelização
#
# O método MCMC permite obter amostras da distribuição a posteriori dos parâmetros do modelo,
# possibilitando a estimação de intervalos de credibilidade e a avaliação da incerteza dos efeitos.

# Para visualizar os resultados:
print(modelo)
plot(modelo)

# Para obter os intervalos de credibilidade:
posterior_summary(modelo, probs = c(0.025, 0.975))

# Para diagnósticos das cadeias:
plot(modelo, NUTS = TRUE)

# Observação: O pacote 'brms' utiliza o algoritmo No-U-Turn Sampler (NUTS), uma extensão do Hamiltonian Monte Carlo (HMC),
# que é eficiente para modelos bayesianos complexos.

# Gerando amostra de 10000 valores da posteriori
amostra <- posterior_predict(modelo, ndraws = 6000)

# Calculando a média e o desvio padrão da amostra
media <- mean(amostra)
desvio_padrao <- sd(amostra)

# Exibindo os resultados
cat("Média da amostra: ", media, "\n")
cat("Desvio padrão da amostra: ", desvio_padrao, "\n")

# Gerando histograma da amostra
hist(amostra, main = "Histograma da amostra", xlab = "Valores", ylab = "Frequência", col = "lightblue")

# Calculando intervalo de credibilidade de 95%
intervalo_credibilidade <- quantile(amostra, c(0.025, 0.975))

# Diagnóstico de convergência

# 1. R-hat e número efetivo de amostras (n_eff)
sumario <- summary(modelo)$fixed
cat("\nDiagnóstico de convergência (R-hat e n_eff):\n")
print(sumario)

# 2. Traceplots para todos os parâmetros (já presente, mas reforçado)
plot(modelo, NUTS = TRUE)

# 3. Traceplots individuais (opcional, requer bayesplot)
# library(bayesplot)
# mcmc_trace(as.array(modelo), pars = c("b_Hours.Studied", "b_Previous.Scores", "b_Sleep.Hours"))


