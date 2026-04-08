#!/bin/bash
# ============================================================
# MySQL HeatWave Validator - Runner
# Tema: ¿MySQL ahora compite con Data Warehouse?
#
# Autor: Rafael Vida
# Plataforma: MySQL HeatWave
# Objetivo:
#   Executar o script validador analítico HeatWave
#   e gerar log de execução.
#
# Uso:
#   ./run_heatwave_validator.sh
# ============================================================


# ============================================================
# CONFIGURAÇÕES DE CONEXÃO
# ============================================================

MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_USER="heatwave_user"
MYSQL_PASSWORD="sua_senha_aqui"
MYSQL_DATABASE="seu_database"

SQL_FILE="validator_mysql_heatwave_datawarehouse.sql"
LOG_FILE="heatwave_validator_$(date +%Y%m%d_%H%M%S).log"


# ============================================================
# VALIDAÇÕES INICIAIS
# ============================================================

echo "============================================" | tee -a "$LOG_FILE"
echo "MySQL HeatWave Validator - START"             | tee -a "$LOG_FILE"
echo "Date: $(date)"                               | tee -a "$LOG_FILE"
echo "Host: $MYSQL_HOST"                           | tee -a "$LOG_FILE"
echo "Database: $MYSQL_DATABASE"                   | tee -a "$LOG_FILE"
echo "============================================" | tee -a "$LOG_FILE"

if [ ! -f "$SQL_FILE" ]; then
    echo "❌ ERRO: Arquivo SQL não encontrado: $SQL_FILE" | tee -a "$LOG_FILE"
    exit 1
fi


# ============================================================
# EXECUÇÃO DO VALIDATOR
# ============================================================

echo "▶ Executando validador HeatWave..." | tee -a "$LOG_FILE"

mysql \
  --host="$MYSQL_HOST" \
  --port="$MYSQL_PORT" \
  --user="$MYSQL_USER" \
  --password="$MYSQL_PASSWORD" \
  --database="$MYSQL_DATABASE" \
  --verbose \
  < "$SQL_FILE" >> "$LOG_FILE" 2>&1


# ============================================================
# RESULTADO FINAL
# ============================================================

if [ $? -eq 0 ]; then
    echo "✅ Validador executado com sucesso!" | tee -a "$LOG_FILE"
else
    echo "❌ ERRO durante execução do validador." | tee -a "$LOG_FILE"
fi

echo "============================================" | tee -a "$LOG_FILE"
echo "MySQL HeatWave Validator - END"               | tee -a "$LOG_FILE"
echo "Log gerado em: $LOG_FILE"                     | tee -a "$LOG_FILE"
echo "============================================" | tee -a "$LOG_FILE"