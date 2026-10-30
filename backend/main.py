from pathlib import Path
from uuid import uuid4

from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

from database import conectar


app = FastAPI(
    title="API - Descarte Consciente",
    description="API para registro de ocorrências de descarte irregular.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pasta onde as imagens das ocorrências serão armazenadas
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

# Disponibiliza as imagens através da URL /uploads
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

@app.get("/")
def inicio():
    return {"mensagem": "API do Descarte Consciente funcionando!"}


@app.post("/ocorrencias", status_code=201)
async def registrar_ocorrencia(
    categoria: str = Form(...),
    descricao: str = Form(...),
    latitude: float | None = Form(None),
    longitude: float | None = Form(None),
    imagem: UploadFile | None = File(None),
):
    caminho_imagem = None

    try:
        # Se uma imagem foi enviada, salva na pasta uploads
        if imagem and imagem.filename:
            extensao = Path(imagem.filename).suffix.lower()

            extensoes_permitidas = {".jpg", ".jpeg", ".png", ".webp"}

            if extensao not in extensoes_permitidas:
                raise HTTPException(
                    status_code=400,
                    detail="Formato de imagem não permitido.",
                )

            nome_arquivo = f"{uuid4()}{extensao}"
            caminho_imagem = f"uploads/{nome_arquivo}"

            conteudo = await imagem.read()

            with open(caminho_imagem, "wb") as arquivo:
                arquivo.write(conteudo)

        # Salva os dados e o caminho da imagem no PostgreSQL
        with conectar() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO ocorrencias
                        (categoria, descricao, latitude, longitude, imagem)
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING id, categoria, descricao,
                              latitude, longitude, imagem, data_criacao;
                    """,
                    (
                        categoria,
                        descricao,
                        latitude,
                        longitude,
                        caminho_imagem,
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
                        "imagem": registro[5],
                        "data_criacao": registro[6],
                    },
                }

    except HTTPException:
        raise

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
                           latitude, longitude, imagem, data_criacao
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
                        "imagem": registro[5],
                        "data_criacao": registro[6],
                    }
                    for registro in registros
                ]

    except Exception as erro:
        print(f"Erro ao listar ocorrências: {erro}")
        raise HTTPException(
            status_code=500,
            detail="Não foi possível consultar as ocorrências.",
        )
