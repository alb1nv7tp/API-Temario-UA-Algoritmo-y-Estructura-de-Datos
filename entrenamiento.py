import json
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.svm import SVC
from sklearn.pipeline import Pipeline
import joblib

ARCHIVO_JSON = "dataset_entrenamiento.json"

def entrenar():
    print("Cargando datos etiquetados...")
    try:
        with open(ARCHIVO_JSON, "r", encoding="utf-8") as archivo:
            datos = json.load(archivo)
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo {ARCHIVO_JSON}. Ejecuta primero el paso 1.")
        return

    textos = []
    etiquetas_tipos = []
    etiquetas_temas = []

    for doc in datos:
        if doc["tipo_documento"] != "" and doc["tema"] != "":
            textos.append(doc["texto_pdf"])
            etiquetas_tipos.append(doc["tipo_documento"])
            etiquetas_temas.append(doc["tema"])

    if len(textos) == 0:
        print("Error: No encontré textos etiquetados. ¡Asegúrate de llenar el JSON!")
        return
        
    print(f"Entrenando con {len(textos)} documentos válidos...")

    # Arquitectura (TF-IDF + SVM Lineal)
    stopwords_es = [
        "de", "la", "que", "el", "en", "y", "a", "los", "del", "se",
        "las", "por", "un", "para", "con", "no", "una", "su", "al"
    ]

    arquitectura_ia = Pipeline([
        ('tfidf', TfidfVectorizer(stop_words=stopwords_es, max_features=5000)),
        ('svm', SVC(kernel='linear', probability=True))
    ])

    #Modelo 1: Para Tipos de Documento
    print("Creando hiperplanos para Tipos de Documento...")
    modelo_tipos = arquitectura_ia
    modelo_tipos.fit(textos, etiquetas_tipos)
    joblib.dump(modelo_tipos, "modelo_tipos.pkl")

    #Modelo 2: Para Temas
    print("Creando hiperplanos para Temas...")
    modelo_temas = arquitectura_ia
    modelo_temas.fit(textos, etiquetas_temas)
    joblib.dump(modelo_temas, "modelo_temas.pkl")

    print("\n¡Entrenamiento completado!")
    print("Se han generado los archivos: 'modelo_tipos.pkl' y 'modelo_temas.pkl'.")

if __name__ == "__main__":
    entrenar()
