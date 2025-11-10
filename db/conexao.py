import mysql.connector

def get_conexao():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='root',
        database='sistemabiblioteca'
    )

def executar_procedure(nome_procedure, params=None):
    conexao = get_conexao()
    cursor = conexao.cursor()
    try:
        cursor.callproc(nome_procedure, params or [])
        resultados = []
        # Aqui pegamos todos os resultados retornados pela procedure
        for result in cursor.stored_results():
            resultados.extend(result.fetchall())
        conexao.commit()
        return resultados
    except Exception as e:
        print(f"Erro ao executar {nome_procedure}: {e}")
        raise
    finally:
        cursor.close()
        conexao.close()



