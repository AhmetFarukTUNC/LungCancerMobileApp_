from flask import Flask, request, render_template
from PIL import Image
import numpy as np
import os
import tensorflow as tf  # Model kullanacaksan

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'

# Örnek class names
class_names = ['adenocarcinoma', 'benign', 'squamous_cell_carcinoma']

# Model yükleme (sen kendi model yolunu yaz)
MODEL_PATH = "lung_cancer_model.h5"
model = tf.keras.models.load_model(MODEL_PATH)

# Ana sayfa
@app.route('/')
def home():
    return render_template('index.html')

# Tahmin endpoint'i
@app.route('/predict_web', methods=['POST'])
def predict_web():
    if 'file' not in request.files:
        return "Dosya yüklenmedi!"
    
    file = request.files['file']
    
    if file.filename == '':
        return "Dosya seçilmedi!"
    
    try:
        # Dosyayı kaydet
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
        file.save(filepath)
        
        # Resmi aç
        image = Image.open(filepath).convert("RGB")
        
        # Model input formatına göre resize ve normalize et
        image = image.resize((224, 224))  # Örnek boyut
        processed_image = np.array(image) / 255.0
        processed_image = np.expand_dims(processed_image, axis=0)  # Batch boyutu ekle
        
        # Tahmin
        pred = model.predict(processed_image)
        pred_class_index = np.argmax(pred)
        pred_class_name = class_names[pred_class_index].replace("_", " ")  # _ yerine boşluk
        confidence = pred[0][pred_class_index] * 100  # Yüzde olarak güven oranı
        
        return f"<h2>Tahmin: {pred_class_name}</h2><h3>Doğruluk Oranı: %{confidence:.2f}</h3>"
    
    except Exception as e:
        return f"Hata oluştu: {e}"

if __name__ == '__main__':
    # uploads klasörünün varlığını kontrol et
    if not os.path.exists(app.config['UPLOAD_FOLDER']):
        os.makedirs(app.config['UPLOAD_FOLDER'])
    
    app.run(debug=True)
