
-- Criação da tabela de componentes da rede
CREATE OR REPLACE TABLE INSTALACAO_OPERACAO (
    INSTALACAO_ID INT,
    IOP_NUM STRING,
    INSTALACAO_CHAVE_PAI_ID INT,
    CHAVE_ID STRING
);

-- Criação da tabela de consumidores
CREATE OR REPLACE TABLE CONSUMIDOR (
    CR_NUMERO INT,
    INSTALACAO_ID INT
);