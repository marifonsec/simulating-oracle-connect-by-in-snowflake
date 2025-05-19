
# Contando clientes em redes hierárquicas no Snowflake

## ❓ Desafio (Problemática)

Em redes técnicas — como redes elétricas — os componentes (subestações, chaves, transformadores, etc.) se organizam de forma hierárquica e dinâmica.  
Cada componente podem ter outros componentes a jusante e a montante e, consumidores associados a determinados componentes.

O objetivo era simples (na teoria):

> **Contar quantos consumidores estão associados a cada componente da rede, considerando todos os nós jusantes, sem entrar em loop.**

### ⚠️ Por que isso é difícil?

- A topologia da rede é dinâmica: a hierarquia dos componentes podem mudar conforme manobras (ex: abrir ou fechar uma chave).
- Algumas estruturas podem estar, erroneamente, desenhado na hierarquia, promovendo loops.
- O script original em Oracle resolvia isso com:
  ```sql
  CONNECT BY nocycle PRIOR INSTALACAO_ID = INSTALACAO_CHAVE_PAI_ID
  ```
  ...o que automaticamente percorre a rede e evita loops.

### 🧱 Limitação encontrada

No Snowflake, não existe suporte ao `CONNECT BY`.  
A recursividade só é possível via `WITH RECURSIVE`, — que, naturalmente, não existe uma proteção automática contra loops.

O desafio era:  
🔄 Recriar esse comportamento **manualmente**, de forma confiável e performática.

---

## ✅ Solução adotada

Implementei uma **CTE recursiva (`WITH RECURSIVE`)** com as seguintes estratégias:

### 1. Caminho acumulado (`CAMINHO`)
- Criei uma coluna que acumula o rastro dos nós já visitados na recursão.
- Exemplo: `123456->654321->789123`
- Isso permite saber se já passamos por um nó.

### 2. Proteção contra loops com `POSITION(...)`
- Antes de seguir para o próximo nó, usamos:
  ```sql
  WHERE POSITION(IOP.INSTALACAO_ID IN H.CAMINHO) = 0
  ```
- Isso garante que não visitamos novamente um nó já incluído no caminho.

### 3. Rastreabilidade da raiz
- Mantive os valores do nó raiz (`INT_NUM_ROOT`, `MSLINK_ROOT`) desde o início da recursão, simulando o `CONNECT_BY_ROOT`.

---
## 🧰 Sobre os dados e scripts incluídos

Para facilitar o entendimento e a reprodução da lógica, incluí neste repositório alguns **dados simulados** gerados por IA e os scripts:

Os dados são duas tabelas, a de instalação e de consumidores:
- `instalacao.csv`: componentes da rede (ex: chaves, trafos), com relações hierárquicas (pai-filho).
- `consumidor.csv`: consumidores finais ligados a algumas dessas instalações.

Esses dados não representam nenhuma estrutura real, apenas simulam a dinâmica necessária para testar a lógica recursiva.

Já sobre os scripts, temos:
- `create_tables.sql`: cria as tabelas `INSTALACAO_OPERACAO` e `CONSUMIDOR` no ambiente Snowflake.
- `script-oracle.sql`: mostra como o problema era resolvido no Oracle, usando `CONNECT BY nocycle`.
- `script-snowflake.sql`: versão em Snowflake usando `WITH RECURSIVE`, controle de caminho (`CAMINHO`) e `POSITION(...)` para prevenir loops — simulando o comportamento do Oracle.

Você pode usar esses arquivos para testar localmente a solução, adaptar à sua realidade ou simplesmente entender como a recursividade funciona em bancos modernos sem suporte nativo a `CONNECT BY`.

---
## 📌 Destaques técnicos

- Simulação do `CONNECT BY nocycle` do Oracle no Snowflake
- Recursão segura com prevenção de ciclos
- Compatível com redes dinâmicas e cenários de contingência
- Lógica genérica, adaptável a outros tipos de rede (ex: telecom, saneamento)

---

## ✍️ Autor(a)

Desenvolvido por [Mariana 💡](https://www.linkedin.com/in/mariana-fonseca-f/), engenheira de dados apaixonada por resolver desafios reais com soluções robustas e escaláveis.
