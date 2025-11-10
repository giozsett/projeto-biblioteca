# app_site/db/inicializar.py
import os
from db.conexao import conectar

def executar_script(arquivo_sql):
    caminho = os.path.join(os.path.dirname(__file__), "scripts", arquivo_sql)
    conexao = conectar()
    cursor = conexao.cursor()

    with open(caminho, "r", encoding="utf-8") as f:
        conteudo = f.read()

    # Divide por ponto e vírgula, mas evita erros com blocos DELIMITER
    comandos = [c.strip() for c in conteudo.split(";") if c.strip()]
    for comando in comandos:
        try:
            cursor.execute(comando)
        except Exception as e:
            print(f"Erro ao executar comando em {arquivo_sql}: {e}")

    conexao.commit()
    conexao.close()

def inicializar_banco():
    scripts = [
        "01_criacao_tabelas.sql",
        "02_insercoes_iniciais.sql",
        "03_procedures.sql",
        "04_triggers.sql"
    ]
    for s in scripts:
        print(f"Executando {s}...")
        executar_script(s)
    print("Banco inicializado com sucesso!")
