# ME705
Projeto de inferência bayesiana


O parâmetro `family` na função `brm` (e em outros modelos de regressão no R) define a **distribuição de probabilidade** assumida para a variável resposta (no caso, `Performance.Index`). Ele determina como o modelo irá tratar os resíduos (erros) e qual função de ligação será usada entre as variáveis preditoras e a resposta.

### O que significa `family = gaussian()`
- `gaussian()` indica que estamos assumindo que a variável resposta segue uma **distribuição normal (ou gaussiana)**.
- Isso significa que, para cada combinação das variáveis explicativas, o valor de `Performance.Index` é modelado como uma variável aleatória normalmente distribuída em torno de uma média (definida pela equação do modelo) e com um certo desvio padrão (sigma).
- Em termos matemáticos:  
  \( Performance.Index \sim N(\mu, \sigma^2) \)  
  onde \(\mu\) é a média prevista pelo modelo (função linear das variáveis explicativas) e \(\sigma\) é o desvio padrão dos resíduos.

### Por que foi escolhido `gaussian()`?
- O `gaussian()` é apropriado quando a variável resposta é **contínua** e pode assumir qualquer valor real, como notas, índices, medidas físicas, etc.
- No seu caso, o `Performance.Index` é um índice numérico contínuo, então a suposição de normalidade é razoável.
- Se a variável resposta fosse, por exemplo, uma contagem (inteiros não-negativos), poderíamos usar `family = poisson()`. Se fosse uma variável binária (sim/não), usaríamos `family = bernoulli()`.

### Resumindo:
- `family = gaussian()` foi escolhido porque o objetivo é modelar uma variável resposta contínua, assumindo que os resíduos seguem uma distribuição normal, o que é padrão para regressão linear.

Se quiser explorar outros tipos de família para diferentes tipos de dados, posso explicar mais exemplos!


Ótima dúvida! Vou explicar como interpretar os principais valores do diagnóstico de convergência do MCMC no contexto do seu modelo Bayesiano com o `brms`:

---

### 1. **R-hat (ou \(\hat{R}\))**

- **O que é:**  
  O R-hat compara a variabilidade entre as cadeias MCMC com a variabilidade dentro de cada cadeia.
- **Como interpretar:**  
  - **R-hat ≈ 1.00:** As cadeias convergiram bem, ou seja, estão todas amostrando da mesma distribuição.
  - **R-hat > 1.01:** Pode indicar que as cadeias ainda não convergiram. Valores acima de 1.05 são preocupantes e sugerem que o modelo precisa de mais iterações ou ajustes.
- **O que fazer se R-hat for alto:**  
  - Aumentar o número de iterações (`iter`).
  - Aumentar o `warmup`.
  - Verificar se o modelo está bem especificado.

---

### 2. **Eff.Sample (n_eff, número efetivo de amostras)**

- **O que é:**  
  Mede quantas amostras independentes equivalentes você tem, levando em conta a autocorrelação das cadeias.
- **Como interpretar:**  
  - **Valores altos (acima de 1000):** Ótimo, indica que as amostras são quase independentes.
  - **Valores baixos (abaixo de 200):** Pode indicar autocorrelação alta, ou seja, as cadeias estão “lentas” para explorar o espaço dos parâmetros.
- **O que fazer se n_eff for baixo:**  
  - Aumentar o número de iterações.
  - Verificar se o modelo está muito complexo ou mal especificado.

---

### 3. **Traceplots**

- **O que é:**  
  Gráficos que mostram a evolução dos valores amostrados para cada parâmetro ao longo das iterações.
- **Como interpretar:**  
  - As cadeias devem parecer “misturadas”, sem padrões, pulos ou tendências.
  - Se as cadeias ficam “presas” em regiões diferentes, ou apresentam tendências, pode indicar falta de convergência.

---

### 4. **Resumo prático**

- **Se todos os R-hat estão próximos de 1 e n_eff é alto:**  
  Seu modelo convergiu bem, os resultados são confiáveis.
- **Se algum R-hat está acima de 1.01 ou n_eff é baixo:**  
  Reavalie o modelo, aumente iterações ou ajuste a especificação.

---

