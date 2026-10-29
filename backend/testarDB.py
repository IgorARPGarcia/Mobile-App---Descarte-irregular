
from database import conectar

try:
    with conectar() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT version();")
            resultado = cursor.fetchone()

            print("Conexão com PostgreSQL realizada!")
            print(resultado[0])

except Exception as erro:
    print("Erro ao conectar ao PostgreSQL:")
    print(erro)
