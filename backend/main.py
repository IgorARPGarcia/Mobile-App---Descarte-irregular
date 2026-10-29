from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from database import conectar


app = FastAPI(
    title="API - Descarte Consciente",
    description="API para registro de ocorrências de descarte irregular.",
    version="1.0.0",
)


class Ocorrencia(BaseModel):
    categoria: str
    descricao: str
    latitude: float | None = None
    longitude: float | None = None


@app.get("/")
def inicio():
    return {"mensagem": "API do Descarte Consciente funcionando!"}


@app.post("/ocorrencias", status_code=201)
def registrar_ocorrencia(ocorrencia: Ocorrencia):
    try:
        with conectar() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO ocorrencias
                        (categoria, descricao, latitude, longitude)
                    VALUES (%s, %s, %s, %s)
                    RETURNING id, categoria, descricao,
                              latitude, longitude, data_criacao;
                    """,
                    (
                        ocorrencia.categoria,
                        ocorrencia.descricao,
                        ocorrencia.latitude,
                        ocorrencia.longitude,
                    ),
                )

                registro = cursor.fetchone()

                return {
                    "mensagem": "Ocorrência registrada com sucesso!",
                    "ocorrencia": {
                        "id": registro[0],
                        "categoria": registro[1],
                        "descricao": registro[2],
                        "latitude": registro[3],
                        "longitude": registro[4],
                        "data_criacao": registro[5],
                    },
                }

    except Exception as erro:
        print(f"Erro ao registrar ocorrência: {erro}")
        raise HTTPException(
            status_code=500,
            detail="Não foi possível registrar a ocorrência.",
        )


@app.get("/ocorrencias")
def listar_ocorrencias():
    try:
        with conectar() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT id, categoria, descricao,
                           latitude, longitude, data_criacao
                    FROM ocorrencias
                    ORDER BY data_criacao DESC;
                    """
                )

                registros = cursor.fetchall()

                return [
                    {
                        "id": registro[0],
                        "categoria": registro[1],
                        "descricao": registro[2],
                        "latitude": registro[3],
                        "longitude": registro[4],
                        "data_criacao": registro[5],
                    }
                    for registro in registros
                ]

    except Exception as erro:
        print(f"Erro ao listar ocorrências: {erro}")
        raise HTTPException(
            status_code=500,
            detail="Não foi possível consultar as ocorrências.",
        )
