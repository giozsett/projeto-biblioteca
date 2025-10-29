import mysql.connector
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def conectar():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="sua_senha",
        database="meu_banco"
    )

def executar_sql(arquivo, parametros=None, fetch=False):
    caminho = os.path.join(BASE_DIR, "scripts", arquivo)
    with open(caminho, "r", encoding="utf-8") as f:
        sql = f.read()
    
    conexao = conectar()
    cursor = conexao.cursor()
    cursor.execute(sql, parametros or ())
    
    if fetch:
        resultado = cursor.fetchall()
    else:
        resultado = None
        conexao.commit()
    
    conexao.close()
    return resultado
