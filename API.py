from fastapi import FastAPI, UploadFile, File, HTTPException
import pdfplumber
import joblib
import io

app = FastAPI(title="Clasificador de Documentos IA", version="1.0")

print("Cargando modelos de IA...")
try:
    modelo_tipos = joblib.load("modelo_tipos.pkl")
    modelo_temas = joblib.load("modelo_temas.pkl")
    print("¡Modelos cargados con éxito!")
except:
    print("Advertencia: No se encontraron los archivos .pkl. Asegúrate de ejecutar el entrenamiento primero.")

def validar_licencia_cc(texto: str) -> bool:
    texto_limpio = texto.lower()
    patrones_validos = ["creative commons", "cc by", "cc0", "openly licensed", "IPN", "ESCOM", "Instituto Politécnico Nacional", "Instituto Politecnico Nacional"]

    inicio_texto = texto_limpio[:2000]
    
    for patron in patrones_validos:
        if patron in inicio_texto:
            return True
    return False

def obtener_top_3_temas(texto: str):
    probabilidades = modelo_temas.predict_proba([texto])[0]
    etiquetas = modelo_temas.classes_
    
    resultados = []
    for i in range(len(etiquetas)):
        resultados.append({
            "tema": etiquetas[i],
            "probabilidad": round(probabilidades[i], 4)
        })
    
    resultados.sort(key=lambda x: x["probabilidad"], reverse=True)
    return resultados[:3]

@app.post("/clasificar-documento/")
async def clasificar_documento(archivo: UploadFile = File(...)):
    
    if not archivo.filename.endswith(".pdf"):
        raise HTTPException(status_code=400, detail="El archivo debe ser un PDF.")

    try:
        texto_completo = ""
        with pdfplumber.open(archivo.file) as pdf:
            for pagina in pdf.pages:
                texto = pagina.extract_text()
                if texto:
                    texto_completo += texto + " "
                    
        texto_completo = " ".join(texto_completo.split())
        
        if not texto_completo:
            raise HTTPException(status_code=400, detail="El PDF está vacío o es una imagen escaneada sin texto.")

        if not validar_licencia_cc(texto_completo):
             return {
                 "archivo_procesado": archivo.filename,
                 "estado": "rechazado",
                 "mensaje": "El documento no cuenta con una licencia Creative Commons válida (Uso libre)."
             }
        
        tipo_predicho = modelo_tipos.predict([texto_completo])[0]
        prob_tipo = max(modelo_tipos.predict_proba([texto_completo])[0])

        top_temas = obtener_top_3_temas(texto_completo)

        return {
            "archivo_procesado": archivo.filename,
            "estado_extraccion": "completado",
            "licencia_valida": True,
            "clasificacion": {
                "tipo_documento": {
                    "etiqueta": tipo_predicho,
                    "probabilidad": round(prob_tipo, 4)
                },
                "temas_detectados": top_temas
            }
        }

    except Exception as e:
         raise HTTPException(status_code=500, detail=f"Error al procesar el archivo: {str(e)}")
