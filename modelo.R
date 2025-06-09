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
# ---------------------------------------------------
# install.packages('brms')
library(brms)
library(bayesplot)
library(ggplot2)
library(posterior)

setwd("~/UNICAMP/ME705")

# Carregar os dados
dados <- read.csv('Student_Performance.csv')
dados$Extracurricular.Activities <- as.factor(dados$Extracurricular.Activities)

# Ajustar o modelo bayesiano
modelo <- brm(
  formula = Performance.Index ~ Hours.Studied + Previous.Scores + Extracurricular.Activities + Sleep.Hours + Sample.Question.Papers.Practiced,
  data = dados,
  family = gaussian(),   # Distribuição gaussiana para a resposta
  chains = 2,            # Número de cadeias MCMC
  iter = 2000,           # Número total de iterações por cadeia
  warmup = 500,          # Número de iterações de burn-in (descartadas)
  seed = 123,            # Semente para reprodutibilidade
  cores = 4              # Número de núcleos para paralelização
)

# Salvar o modelo ajustado para uso futuro
saveRDS(modelo, file = "modelo_brms.rds")

modelo <- readRDS("modelo_brms.rds")
# Explicação das opções utilizadas:
# - chains: número de cadeias independentes de MCMC (padrão: 4)
# - iter: número total de iterações por cadeia (padrão: 2000)
# - warmup: número de iterações iniciais descartadas (burn-in)
# - seed: semente para garantir resultados reprodutíveis
# - cores: número de núcleos de CPU usados para paralelização
#
# O método MCMC permite obter amostras da distribuição a posteriori dos parâmetros do modelo,
# possibilitando a estimação de intervalos de credibilidade e a avaliação da incerteza dos efeitos.
#método avançados de amostragem MCMC (Markov Chain Monte Carlo) e são implementados no backend pelo software Stan.

# Salvar o plot geral do modelo
plot(modelo)
# Para visualizar os resultados:
print(modelo)


# Para obter os intervalos de credibilidade:
posterior_summary(modelo, probs = c(0.025, 0.975))
# Resultado:
#                                         Estimate    Est.Error          Q2.5         Q97.5
# b_Intercept                        -3.407275e+01 1.227367e-01 -3.430844e+01 -3.383134e+01
# b_Hours.Studied                     2.853079e+00 7.635331e-03  2.838148e+00  2.868118e+00
# b_Previous.Scores                   1.018408e+00 1.154709e-03  1.016182e+00  1.020636e+00
# b_Extracurricular.ActivitiesYes     6.132912e-01 4.113115e-02  5.325034e-01  6.917357e-01
# b_Sleep.Hours                       4.804911e-01 1.204817e-02  4.570616e-01  5.034083e-01
# b_Sample.Question.Papers.Practiced  1.935118e-01 6.884574e-03  1.799088e-01  2.069274e-01
# sigma                               2.038718e+00 1.468985e-02  2.009984e+00  2.067978e+00
# Intercept                           5.522470e+01 1.992508e-02  5.518644e+01  5.526383e+01
# lprior                             -7.514499e+00 8.156958e-05 -7.514661e+00 -7.514339e+00
# lp__                               -2.131679e+04 1.778501e+00 -2.132105e+04 -2.131423e+04
# Para diagnósticos das cadeias (removido plot redundante)
# plot(modelo, NUTS = TRUE)  # Removido para evitar repetição

# Gerando amostra de 2000 valores da posteriori da variavel resposta
amostra <- posterior_predict(modelo, ndraws = 2000)

# Calculando a média e o desvio padrão da amostra
media <- mean(amostra)
desvio_padrao <- sd(amostra)

# Exibindo os resultados
cat("Média da amostra: ", media, "\n")
cat("Desvio padrão da amostra: ", desvio_padrao, "\n")

# Gerando e salvando histograma da amostra
histograma <- hist(amostra, main = "Histograma da amostra", xlab = "Valores", ylab = "Frequência", col = "lightblue", plot = FALSE)
# Usando ggplot2 para salvar o histograma

df_amostra <- data.frame(valor = as.vector(amostra))
g_hist <- ggplot(df_amostra, aes(x = valor)) +
  geom_histogram(fill = "lightblue", color = "black", bins = 30) +
  labs(title = "Histograma da amostra", x = "Valores", y = "Frequência")
ggsave("graficos/histograma_amostra.png", g_hist, width = 10, height = 6, bg = "white")

# Calculando intervalo de credibilidade de 95%
intervalo_credibilidade <- quantile(amostra, c(0.025, 0.975))

# Diagnóstico de convergência

# 1. R-hat e número efetivo de amostras (n_eff)
sumario <- summary(modelo)$fixed
cat("\nDiagnóstico de convergência (R-hat e n_eff):\n")
print(sumario)
# Resultado:
#                                     Estimate   Est.Error    l-95% CI    u-95% CI     Rhat Bulk_ESS Tail_ESS
# Intercept                        -34.0727486 0.122736659 -34.3084375 -33.8313376 1.001116 3427.597 2211.772
# Hours.Studied                      2.8530786 0.007635331   2.8381484   2.8681181 1.000413 4289.504 2111.882
# Previous.Scores                    1.0184077 0.001154709   1.0161817   1.0206365 1.000641 3191.131 2159.847
# Extracurricular.ActivitiesYes      0.6132912 0.041131153   0.5325034   0.6917357 1.000286 2944.068 1861.244
# Sleep.Hours                        0.4804911 0.012048169   0.4570616   0.5034083 1.001520 3356.358 2064.240
# Sample.Question.Papers.Practiced   0.1935118 0.006884574   0.1799088   0.2069274 1.000393 4429.311 2039.887

# 3. Traceplots individuais (opcional, requer bayesplot)
mcmc_trace(as.array(modelo), pars = c("b_Hours.Studied", "b_Previous.Scores", "b_Sleep.Hours"))

# Salvar o gráfico dos traceplots dos parâmetros principais
trace <- mcmc_trace(as.array(modelo), 
                    pars = c("b_Intercept", "b_Hours.Studied", "b_Previous.Scores", 
                             "b_Extracurricular.ActivitiesYes", "b_Sleep.Hours",rac
                             "b_Sample.Question.Papers.Practiced"))

ggsave("graficos/traceplot_parametros.png", trace, width = 10, height = 6, bg = "white")

# Gerar e salvar histogramas para todos os parâmetros da posteriori
draws <- as_draws_df(modelo)
parametros <- names(draws)

for (param in parametros) {
  df_param <- data.frame(valor = draws[[param]])
  g <- ggplot(df_param, aes(x = valor)) +
    geom_histogram(fill = "lightblue", color = "black", bins = 30) +
    labs(title = paste("Histograma de", param), x = param, y = "Frequência")
  ggsave(paste0("graficos/distribuicao_parametros/hist_param_", param, ".png"), g, width = 8, height = 5, bg = "white")
  # Traceplot individual
  trace_ind <- mcmc_trace(as.array(modelo), pars = param)
  ggsave(paste0("graficos/distribuicao_parametros/trace_param_", param, ".png"), trace_ind, width = 8, height = 5, bg = "white")
}

# Trajetória HMC entre dois parâmetros principais com fundo representando a função de log-posterior
scatter_hmc <- mcmc_scatter(
  as.array(modelo),
  pars = c("b_Hours.Studied", "b_Previous.Scores"),
  size = 1, alpha = 0.5,
  dens = TRUE
) +
  ggplot2::labs(
    title = "Trajetória HMC: Hours.Studied vs Previous.Scores",
    x = "b_Hours.Studied",
    y = "b_Previous.Scores",
    subtitle = "O fundo em tons de azul representa a função de log-posterior (mais claro = maior probabilidade)."
  )

ggsave("graficos/trajectoria_hmc.png", scatter_hmc, width = 8, height = 6, bg = "white")

# Gráfico de pares com densidade de fundo
pares <- mcmc_pairs(
  as.array(modelo),
  pars = c("b_Hours.Studied", "b_Previous.Scores")
)
ggsave("graficos/pares_hmc.png", pares, width = 8, height = 6, bg = "white")

# Extraindo as amostras dos parâmetros
draws <- as_draws_df(modelo)
df_hmc <- data.frame(
  Hours.Studied = draws$b_Hours.Studied,
  Previous.Scores = draws$b_Previous.Scores,
  iter = 1:nrow(draws)
)

# Trajetoria do HMC
posterior_samples <- as_draws_df(modelo)  # ou as_draws_array(fit), ou as.data.frame(fit)

library(dplyr)

samples_df <- posterior_samples %>%
  select(.chain, .iteration, b_Hours.Studied, b_Previous.Scores)

library(ggplot2)

trajetorias_custom <- ggplot(samples_df, aes(x = b_Hours.Studied, y = b_Previous.Scores, group = .chain, color = factor(.chain))) +
  geom_path(alpha = 0.6) +     # conecta os pontos em cada cadeia → mostra a trajetória!
  geom_point(alpha = 0.6, size = 0.8) +
  theme_minimal() +
  labs(title = "Trajetória das amostras HMC",
       x = "b_Hours.Studied",
       y = "b_Previous.Scores",
       color = "Cadeia")

ggsave("graficos/trajectoria_hmc_custom.png", trajetorias_custom, width = 8, height = 6, bg = "white")
# -----------------------------
# Comparação com regressão linear clássica (lm)
# -----------------------------
# Ajustar o modelo linear clássico
modelo_lm <- lm(Performance.Index ~ Hours.Studied + Previous.Scores + Extracurricular.Activities + Sleep.Hours + Sample.Question.Papers.Practiced, data = dados)

# Extrair coeficientes do modelo linear
coef_lm <- coef(modelo_lm)

# Extrair estimativas dos parâmetros do modelo bayesiano (média posteriori)
summary_bayes <- summary(modelo)$fixed
coef_bayes <- summary_bayes[, "Estimate"]

coef_lm = c (-34.0755881, 2.8529821,  1.0184342,  0.6128976, 0.4805598  ,   0.1938021 )
coef_bayes <-c( -34.0727486,   2.8530786,   1.0184077,   0.6132912,   0.4804911,   0.1935118)

nomes_parametros <- rownames(summary_bayes)

# Montar data.frame comparativo (assumindo ordem igual nas três listas)
comparacao <- data.frame(
  Parametro = nomes_parametros,
  Bayesiano = coef_bayes,
  Linear = coef_lm,
  Diferenca = abs(coef_bayes - coef_lm)
)

# Exibir tabela comparativa
cat("\nTabela comparativa dos parâmetros (Bayesiano x Linear):\n")
print(comparacao)
#resultado:
#                                                         Parametro   Bayesiano      Linear    Diferenca
# (Intercept)                                             Intercept -34.0727486 -34.0755881 2.839487e-03
# Hours.Studied                                       Hours.Studied   2.8530786   2.8529821 9.651268e-05
# Previous.Scores                                   Previous.Scores   1.0184077   1.0184342 2.647168e-05
# Extracurricular.ActivitiesYes       Extracurricular.ActivitiesYes   0.6132912   0.6128976 3.935729e-04
# Sleep.Hours                                           Sleep.Hours   0.4804911   0.4805598 6.866598e-05
# Sample.Question.Papers.Practiced Sample.Question.Papers.Practiced   0.1935118   0.1938021 2.902989e-04
# Gerar dados para predição
library(dplyr)

# Fixar as outras variáveis nos valores médios/moda
valores_medio <- dados %>%
  summarise(
    Hours.Studied = mean(Hours.Studied, na.rm = TRUE),
    Extracurricular.Activities = names(sort(table(Extracurricular.Activities), decreasing = TRUE))[1],
    Sleep.Hours = mean(Sleep.Hours, na.rm = TRUE),
    Sample.Question.Papers.Practiced = mean(Sample.Question.Papers.Practiced, na.rm = TRUE)
  )

# Sequência de valores para Previous.Scores
novo_prev <- seq(min(dados$Previous.Scores), max(dados$Previous.Scores), length.out = 100)

# Data frame para predição
dados_pred <- data.frame(
  Hours.Studied = valores_medio$Hours.Studied,
  Previous.Scores = novo_prev,
  Extracurricular.Activities = valores_medio$Extracurricular.Activities,
  Sleep.Hours = valores_medio$Sleep.Hours,
  Sample.Question.Papers.Practiced = valores_medio$Sample.Question.Papers.Practiced
)

# Obter predições do modelo bayesiano
pred_bayes <- posterior_predict(modelo, newdata = dados_pred)

# Calcular média e intervalo de credibilidade
media_pred <- apply(pred_bayes, 2, mean)
ic_pred <- apply(pred_bayes, 2, quantile, probs = c(0.025, 0.975))

# Montar data frame para plot
df_plot <- data.frame(
  Previous.Scores = novo_prev,
  media = media_pred,
  ic_inf = ic_pred[1, ],
  ic_sup = ic_pred[2, ]
)

# Plotar reta ajustada, intervalo de credibilidade e pontos reais
g_reta <- ggplot(df_plot, aes(x = Previous.Scores, y = media)) +
  geom_point(data = dados, aes(x = Previous.Scores, y = Performance.Index), 
             color = "black", alpha = 0.5, size = 1.5) +
  geom_ribbon(aes(ymin = ic_inf, ymax = ic_sup), fill = "lightblue", alpha = 0.5) +
  geom_line(color = "blue", size = 1) +
  labs(
    title = "Reta ajustada pelo modelo Bayesiano",
    x = "Previous Scores",
    y = "Índice de Performance",
    subtitle = "Faixa azul: intervalo de credibilidade de 95%. Pontos pretos: dados reais."
  ) +
  theme_minimal()

ggsave("graficos/reta_bayesiana_previous_scores.png", g_reta, width = 8, height = 6, bg = "white")

# Diagnóstico de erro do modelo Bayesiano

# Obter predições médias para os dados observados
pred_obs <- posterior_predict(modelo, newdata = dados)
media_pred_obs <- apply(pred_obs, 2, mean)

# Calcular métricas de erro
erro <- dados$Performance.Index - media_pred_obs
mae <- mean(abs(erro))
mse <- mean(erro^2)
rmse <- sqrt(mse)

# R² Bayesiano
r2_bayes <- bayes_R2(modelo)
media_r2 <- mean(r2_bayes)

cat("\nDiagnóstico de erro do modelo Bayesiano:\n")
cat("MAE (Erro Médio Absoluto):", round(mae, 3), "\n")
cat("MSE (Erro Quadrático Médio):", round(mse, 3), "\n")
cat("RMSE (Raiz do Erro Quadrático Médio):", round(rmse, 3), "\n")
cat("R² Bayesiano (média):", round(media_r2, 3), "\n")

# Gráfico: Resíduos vs Valores observados de y
df_erro <- data.frame(
  erro = erro,
  y_real = dados$Performance.Index
)

g_resid_y <- ggplot(df_erro, aes(x = y_real, y = erro)) +
  geom_point(color = "blue", alpha = 0.6, size = 1.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "Resíduos vs Valores observados de Performance.Index",
    x = "Performance.Index (observado)",
    y = "Resíduo (Erro)",
    subtitle = "Linha vermelha tracejada indica resíduo zero"
  ) +
  theme_minimal()

ggsave("graficos/residuos_vs_y.png", g_resid_y, width = 8, height = 6, bg = "white")


