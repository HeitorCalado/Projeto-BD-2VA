# Projeto-BD-2VA

Projeto de Banco de Dados 2VA - Modelagem, Docker e povoamento do banco de dados

## Integrantes do Grupo

- Heitor Calado Duque de Araujo
- Laura Vitoria
- Carlos Gabryel Espinhara
- Carlos Lucas Feitoza

## Contexto do Projeto

Este projeto implementa o esquema lógico relacional de um sistema de gestão de pesquisa acadêmica, mapeado a partir do Diagrama Conceitual (MER) desenvolvido na etapa anterior. O banco de dados modela pesquisadores, alunos, grupos de pesquisa, projetos, publicações, editais de fomento e vagas de bolsa, incluindo os relacionamentos entre essas entidades.

**Dados de conexão:**
- SGBD: PostgreSQL 16
- Usuário: `admin`
- Senha: `admin123`
- Nome do banco: `projeto_pesquisa`
- Porta: `5432`

**Como subir o banco:**
```
docker compose up
```
O banco sobe já com o esquema criado e povoado automaticamente, via os scripts `schema.sql` e `povoamento.sql` executados na inicialização do container.

## Dicionário de Dados

### conta
Armazena as credenciais de login do sistema. Cada conta autentica exatamente um pesquisador ou um aluno.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_conta | SERIAL | PK | Identificador único da conta |
| email | VARCHAR(150) | NOT NULL, UNIQUE | E-mail de login |
| senha_hash | VARCHAR(255) | NOT NULL | Hash da senha do usuário |
| tipo | VARCHAR(20) | NOT NULL, CHECK IN ('pesquisador','aluno') | Define se a conta pertence a um pesquisador ou a um aluno |
| data_criacao | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Data de criação da conta |

### pesquisador
Representa um pesquisador vinculado a grupos e projetos de pesquisa.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_pesquisador | SERIAL | PK | Identificador único do pesquisador |
| id_conta | INT | NOT NULL, UNIQUE, FK → conta(id_conta) | Conta de login associada |
| nome | VARCHAR(150) | NOT NULL | Nome completo do pesquisador |
| numero_lattes | VARCHAR(50) | — | Link/identificador do currículo Lattes |
| email | VARCHAR(150) | — | E-mail de contato do pesquisador |
| vinculo | VARCHAR(100) | — | Vínculo institucional (ex: Docente, Doutorando) |
| origem | VARCHAR(100) | — | Instituição de origem do pesquisador |

### curso
Representa um curso de graduação/pós-graduação ao qual um aluno pertence.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_curso | SERIAL | PK | Identificador único do curso |
| nome_curso | VARCHAR(150) | NOT NULL | Nome do curso |

### aluno
Representa um estudante que pode se candidatar a vagas de pesquisa.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_aluno | SERIAL | PK | Identificador único do aluno |
| id_conta | INT | NOT NULL, UNIQUE, FK → conta(id_conta) | Conta de login associada |
| id_curso | INT | NOT NULL, FK → curso(id_curso) | Curso ao qual o aluno está vinculado |
| nome | VARCHAR(150) | NOT NULL | Nome completo do aluno |
| matricula | VARCHAR(30) | NOT NULL, UNIQUE | Número de matrícula institucional |

### agencia_fomento
Representa uma agência que financia editais de pesquisa (ex: CNPq, CAPES).

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_agencia | SERIAL | PK | Identificador único da agência |
| nome | VARCHAR(150) | NOT NULL | Nome da agência de fomento |

### edital
Representa um edital lançado por uma agência de fomento para financiar projetos.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_edital | SERIAL | PK | Identificador único do edital |
| id_agencia | INT | NOT NULL, FK → agencia_fomento(id_agencia) | Agência que lançou o edital |
| nome_edital | VARCHAR(150) | NOT NULL | Nome/título do edital |
| ano | INT | — | Ano de lançamento do edital |

### grupo_pesquisa
Representa um grupo de pesquisa institucional, cadastrado no Diretório dos Grupos de Pesquisa (DGP/CNPq).

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_grupo | SERIAL | PK | Identificador único do grupo |
| nome_grupo | VARCHAR(150) | NOT NULL | Nome do grupo de pesquisa |
| link_dgp | VARCHAR(255) | — | Link para o cadastro no DGP/CNPq |
| ano_criacao | INT | — | Ano de criação do grupo |

### projeto_pesquisa
Representa um projeto de pesquisa conduzido por um grupo, podendo ser financiado por um edital.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_projeto | SERIAL | PK | Identificador único do projeto |
| id_grupo | INT | NOT NULL, FK → grupo_pesquisa(id_grupo) | Grupo de pesquisa responsável pelo projeto |
| id_edital | INT | NULL, FK → edital(id_edital) | Edital financiador (opcional — projeto pode não ter financiamento) |
| titulo | VARCHAR(255) | NOT NULL | Título do projeto |
| resumo | TEXT | — | Resumo/descrição do projeto |
| data_inicio | DATE | — | Data de início do projeto |
| data_fim | DATE | — | Data de encerramento do projeto (nulo se em andamento) |
| status | VARCHAR(30) | — | Situação atual: Em andamento, Concluído, Planejado, Suspenso |
| origem | VARCHAR(100) | — | Origem da demanda do projeto |

### publicacao
Representa uma publicação científica resultante de um projeto de pesquisa.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_publicacao | SERIAL | PK | Identificador único da publicação |
| id_projeto | INT | NOT NULL, FK → projeto_pesquisa(id_projeto) | Projeto que originou a publicação |
| tipo | VARCHAR(50) | — | Tipo da publicação (Artigo, Capítulo de Livro, Pôster, etc.) |
| ano | INT | — | Ano de publicação |
| doi | VARCHAR(100) | UNIQUE | Digital Object Identifier da publicação |
| veiculo | VARCHAR(150) | — | Periódico/conferência onde foi publicado |
| titulo | VARCHAR(255) | NOT NULL | Título da publicação |

### area_conhecimento
Representa uma área do conhecimento (ex: Inteligência Artificial, Banco de Dados) associada a projetos.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_area | SERIAL | PK | Identificador único da área |
| nome_area | VARCHAR(150) | NOT NULL, UNIQUE | Nome da área de conhecimento |

### vaga
Representa uma vaga de bolsa/participação em um projeto de pesquisa, aberta para candidatura de alunos.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_vaga | SERIAL | PK | Identificador único da vaga |
| id_projeto | INT | NOT NULL, FK → projeto_pesquisa(id_projeto) | Projeto que abriu a vaga |
| titulo | VARCHAR(150) | — | Título/cargo da vaga |
| requisitos | TEXT | — | Requisitos para se candidatar |
| status | VARCHAR(30) | — | Situação da vaga: Aberta, Fechada, Em análise |
| qtd_vagas | INT | DEFAULT 1 | Quantidade de posições disponíveis |
| data_abertura | DATE | — | Data de abertura da vaga |

### autoria (associativa: pesquisador × publicacao)
Relaciona pesquisadores às publicações das quais são autores.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_pesquisador | INT | PK, FK → pesquisador(id_pesquisador) | Pesquisador autor |
| id_publicacao | INT | PK, FK → publicacao(id_publicacao) | Publicação de autoria |
| ordem | INT | NOT NULL | Posição do pesquisador na ordem de autoria |

### participacao (associativa: pesquisador × projeto_pesquisa)
Relaciona pesquisadores aos projetos dos quais participam.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_pesquisador | INT | PK, FK → pesquisador(id_pesquisador) | Pesquisador participante |
| id_projeto | INT | PK, FK → projeto_pesquisa(id_projeto) | Projeto do qual participa |
| data_entrada | DATE | — | Data de entrada no projeto |
| papel | VARCHAR(100) | — | Papel exercido no projeto (ex: Coordenador, Colaborador) |

### membro (associativa: pesquisador × grupo_pesquisa)
Relaciona pesquisadores aos grupos de pesquisa dos quais fazem parte.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_pesquisador | INT | PK, FK → pesquisador(id_pesquisador) | Pesquisador membro |
| id_grupo | INT | PK, FK → grupo_pesquisa(id_grupo) | Grupo de pesquisa |
| papel_grupo | VARCHAR(100) | — | Papel do pesquisador no grupo (ex: Líder, Membro Estudante) |

### possui_area (associativa: projeto_pesquisa × area_conhecimento)
Relaciona projetos às áreas de conhecimento às quais pertencem.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_projeto | INT | PK, FK → projeto_pesquisa(id_projeto) | Projeto de pesquisa |
| id_area | INT | PK, FK → area_conhecimento(id_area) | Área de conhecimento associada |

### candidatura (associativa: aluno × vaga)
Relaciona alunos às vagas para as quais se candidataram.

| Atributo | Tipo | Restrições | Semântica |
|---|---|---|---|
| id_aluno | INT | PK, FK → aluno(id_aluno) | Aluno candidato |
| id_vaga | INT | PK, FK → vaga(id_vaga) | Vaga alvo da candidatura |
| status | VARCHAR(30) | — | Situação da candidatura: Pendente, Aprovada, Reprovada, Em análise |
| data_candidatura | DATE | — | Data em que a candidatura foi feita |

## Metodologia de Povoamento

O povoamento do banco de dados foi realizado via script DML (`povoamento.sql`), com instruções `INSERT` geradas programaticamente através de um script Python. O script utiliza listas curadas de nomes, instituições, cursos, áreas de conhecimento e títulos de projeto plausíveis em português, combinadas de forma aleatória e determinística (seed fixa) para garantir reprodutibilidade.

Foram respeitados os volumes mínimos exigidos: 50 tuplas nas tabelas principais (conta, pesquisador, aluno, projeto_pesquisa, publicacao, vaga) e 15 tuplas nas tabelas secundárias (curso, agencia_fomento, edital, grupo_pesquisa, area_conhecimento). As tabelas associativas (autoria, participacao, membro, possui_area, candidatura) foram povoadas com volume adicional (90 a 120 tuplas cada) para garantir dados suficientes em consultas complexas com junções (JOIN).

A integridade referencial foi mantida através da geração controlada de IDs e do ajuste das sequences (`SERIAL`) ao final do script, evitando conflitos em inserções futuras.
