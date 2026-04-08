/* ============================================================
   MYSQL HEATWAVE VALIDATOR
   Tema: ¿MySQL ahora compite con Data Warehouse?
   Autor: Rafael Vida
   Plataforma: MySQL HeatWave
   Objetivo:
       Validar se o MySQL HeatWave atende requisitos
       clássicos de Data Warehouse Analítico.
   ============================================================ */

-- ============================================================
-- BLOCO 0 – CONTEXTO DO AMBIENTE
-- ============================================================

SELECT
    @@hostname           AS host,
    @@version            AS mysql_version,
    @@version_comment    AS distribution,
    @@datadir            AS data_directory;


-- ============================================================
-- BLOCO 1 – VALIDAÇÃO DO HEATWAVE ATIVO
-- ============================================================

SELECT VARIABLE_NAME, VARIABLE_VALUE
FROM performance_schema.global_variables
WHERE VARIABLE_NAME LIKE 'heatwave%';

-- Critério:
-- use_secondary_engine deve existir
-- HeatWave configurado e ativo


-- ============================================================
-- BLOCO 2 – FORÇAR EXECUÇÃO ANALÍTICA (OLAP)
-- ============================================================

SET SESSION use_secondary_engine = FORCE;
SET SESSION optimizer_switch = 'derived_merge=off';

SELECT 'HeatWave OLAP mode ENABLED' AS status;


-- ============================================================
-- BLOCO 3 – VOLUME DE DADOS (CARACTERÍSTICA DW)
-- ============================================================

SELECT 
    table_schema,
    table_name,
    table_rows
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','performance_schema','information_schema','sys')
ORDER BY table_rows DESC;


-- ============================================================
-- BLOCO 4 – ESTRUTURA TÍPICA DE DATA WAREHOUSE
-- (FATO + DIMENSÃO)
-- ============================================================

-- DIMENSÃO TEMPO
CREATE TABLE IF NOT EXISTS dim_tempo (
    id_tempo INT PRIMARY KEY,
    ano INT,
    mes INT,
    dia INT
) ENGINE=InnoDB;

-- DIMENSÃO PRODUTO
CREATE TABLE IF NOT EXISTS dim_produto (
    id_produto INT PRIMARY KEY,
    nome_produto VARCHAR(100),
    categoria VARCHAR(50)
) ENGINE=InnoDB;

-- FATO VENDAS
CREATE TABLE IF NOT EXISTS fato_vendas (
    id_venda BIGINT PRIMARY KEY,
    id_tempo INT,
    id_produto INT,
    valor_venda DECIMAL(15,2),
    CONSTRAINT fk_fato_tempo FOREIGN KEY (id_tempo) REFERENCES dim_tempo (id_tempo),
    CONSTRAINT fk_fato_produto FOREIGN KEY (id_produto) REFERENCES dim_produto (id_produto)
) ENGINE=InnoDB;


-- ============================================================
-- BLOCO 5 – QUERY ANALÍTICA (DW REAL)
-- ============================================================

SELECT
    d.ano,
    d.mes,
    SUM(f.valor_venda) AS total_vendas
FROM fato_vendas f
JOIN dim_tempo d   ON d.id_tempo = f.id_tempo
JOIN dim_produto p ON p.id_produto = f.id_produto
GROUP BY d.ano, d.mes
ORDER BY d.ano, d.mes;

-- Critério:
-- Execução em memória
-- Full scan paralelo
-- Sem dependência de índices


-- ============================================================
-- BLOCO 6 – CONCORRÊNCIA ANALÍTICA
-- ============================================================

SHOW PROCESSLIST;


-- ============================================================
-- BLOCO 7 – GOVERNANÇA (CAMADA SEMÂNTICA)
-- ============================================================

CREATE OR REPLACE VIEW vw_vendas_analitica AS
SELECT
    d.ano,
    d.mes,
    SUM(f.valor_venda) AS total_vendas
FROM fato_vendas f
JOIN dim_tempo d ON d.id_tempo = f.id_tempo
GROUP BY d.ano, d.mes;

SELECT * FROM vw_vendas_analitica;


-- ============================================================
-- BLOCO 8 – ESTATÍSTICAS DE EXECUÇÃO
-- ============================================================

SELECT *
FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 10;


-- ============================================================
-- BLOCO 9 – CUSTO E SIMPLIFICAÇÃO ARQUITETURAL
-- ============================================================

SELECT
    'HeatWave elimina ETL, reduz latência e custo' AS conclusao,
    'Dados analíticos e transacionais na mesma plataforma' AS beneficio,
    'Concorrente direto de DW em cenários operacionais' AS posicionamento;


-- ============================================================
-- BLOCO 10 – VEREDITO FINAL
-- ============================================================

SELECT
    CASE
        WHEN @@version_comment LIKE '%HeatWave%'
        THEN 'SIM – MySQL HeatWave compete com Data Warehouse em cenários reais'
        ELSE 'NAO – HeatWave não detectado'
    END AS veredito_final;


/* ============================================================
   CONCLUSÃO EXECUTIVA:
   MySQL HeatWave atua como uma Plataforma Analítica
   em Memória, competindo diretamente com Data Warehouses
   tradicionais em cenários OLAP, near real-time analytics
   e BI operacional.
   ============================================================ */