CREATE TABLE conta (
    id_conta        SERIAL PRIMARY KEY,
    email           VARCHAR(150) NOT NULL UNIQUE,
    senha_hash      VARCHAR(255) NOT NULL,
    tipo            VARCHAR(20)  NOT NULL CHECK (tipo IN ('pesquisador', 'aluno')),
    data_criacao    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pesquisador (
    id_pesquisador  SERIAL PRIMARY KEY,
    id_conta        INT NOT NULL UNIQUE REFERENCES conta(id_conta),
    nome            VARCHAR(150) NOT NULL,
    numero_lattes   VARCHAR(50),
    email           VARCHAR(150),
    vinculo         VARCHAR(100),
    origem          VARCHAR(100)
);

CREATE TABLE curso (
    id_curso        SERIAL PRIMARY KEY,
    nome_curso      VARCHAR(150) NOT NULL
);

CREATE TABLE aluno (
    id_aluno        SERIAL PRIMARY KEY,
    id_conta        INT NOT NULL UNIQUE REFERENCES conta(id_conta),
    id_curso        INT NOT NULL REFERENCES curso(id_curso),
    nome            VARCHAR(150) NOT NULL,
    matricula       VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE agencia_fomento (
    id_agencia      SERIAL PRIMARY KEY,
    nome            VARCHAR(150) NOT NULL
);

CREATE TABLE edital (
    id_edital       SERIAL PRIMARY KEY,
    id_agencia      INT NOT NULL REFERENCES agencia_fomento(id_agencia),
    nome_edital     VARCHAR(150) NOT NULL,
    ano             INT
);

CREATE TABLE grupo_pesquisa (
    id_grupo        SERIAL PRIMARY KEY,
    nome_grupo      VARCHAR(150) NOT NULL,
    link_dgp        VARCHAR(255),
    ano_criacao     INT
);

CREATE TABLE projeto_pesquisa (
    id_projeto      SERIAL PRIMARY KEY,
    id_grupo        INT NOT NULL REFERENCES grupo_pesquisa(id_grupo),
    id_edital       INT NULL REFERENCES edital(id_edital),
    titulo          VARCHAR(255) NOT NULL,
    resumo          TEXT,
    data_inicio     DATE,
    data_fim        DATE,
    status          VARCHAR(30),
    origem          VARCHAR(100)
);

CREATE TABLE publicacao (
    id_publicacao   SERIAL PRIMARY KEY,
    id_projeto      INT NOT NULL REFERENCES projeto_pesquisa(id_projeto),
    tipo            VARCHAR(50),
    ano             INT,
    doi             VARCHAR(100) UNIQUE,
    veiculo         VARCHAR(150),
    titulo          VARCHAR(255) NOT NULL
);

CREATE TABLE area_conhecimento (
    id_area         SERIAL PRIMARY KEY,
    nome_area       VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE vaga (
    id_vaga         SERIAL PRIMARY KEY,
    id_projeto      INT NOT NULL REFERENCES projeto_pesquisa(id_projeto),
    titulo          VARCHAR(150),
    requisitos      TEXT,
    status          VARCHAR(30),
    qtd_vagas       INT DEFAULT 1,
    data_abertura   DATE
);

CREATE TABLE autoria (
    id_pesquisador  INT NOT NULL REFERENCES pesquisador(id_pesquisador),
    id_publicacao   INT NOT NULL REFERENCES publicacao(id_publicacao),
    ordem           INT NOT NULL,
    PRIMARY KEY (id_pesquisador, id_publicacao)
);

CREATE TABLE participacao (
    id_pesquisador  INT NOT NULL REFERENCES pesquisador(id_pesquisador),
    id_projeto      INT NOT NULL REFERENCES projeto_pesquisa(id_projeto),
    data_entrada    DATE,
    papel           VARCHAR(100),
    PRIMARY KEY (id_pesquisador, id_projeto)
);

CREATE TABLE membro (
    id_pesquisador  INT NOT NULL REFERENCES pesquisador(id_pesquisador),
    id_grupo        INT NOT NULL REFERENCES grupo_pesquisa(id_grupo),
    papel_grupo     VARCHAR(100),
    PRIMARY KEY (id_pesquisador, id_grupo)
);

CREATE TABLE possui_area (
    id_projeto      INT NOT NULL REFERENCES projeto_pesquisa(id_projeto),
    id_area         INT NOT NULL REFERENCES area_conhecimento(id_area),
    PRIMARY KEY (id_projeto, id_area)
);

CREATE TABLE candidatura (
    id_aluno        INT NOT NULL REFERENCES aluno(id_aluno),
    id_vaga         INT NOT NULL REFERENCES vaga(id_vaga),
    status          VARCHAR(30),
    data_candidatura DATE,
    PRIMARY KEY (id_aluno, id_vaga)
);

CREATE INDEX idx_projeto_grupo ON projeto_pesquisa(id_grupo);
CREATE INDEX idx_projeto_edital ON projeto_pesquisa(id_edital);
CREATE INDEX idx_publicacao_projeto ON publicacao(id_projeto);
CREATE INDEX idx_vaga_projeto ON vaga(id_projeto);
CREATE INDEX idx_edital_agencia ON edital(id_agencia);
CREATE INDEX idx_aluno_curso ON aluno(id_curso);
