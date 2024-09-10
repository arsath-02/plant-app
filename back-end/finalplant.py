from flask import Flask, request, jsonify, url_for
from tensorflow.keras.preprocessing import image
import numpy as np
from tensorflow.keras.models import load_model
import os
from flask_cors import CORS

app = Flask(__name__)
CORS(app) 

loaded_model = load_model("finetuned_model.h5")

class_labels = [
    'Tomato___Late_blight', 'Tomato___healthy', 'Grape___healthy', 
    'Orange___Haunglongbing_(Citrus_greening)', 'Soybean___healthy', 
    'Squash___Powdery_mildew', 'Potato___healthy', 
    'Corn_(maize)___Northern_Leaf_Blight', 'Tomato___Early_blight', 
    'Tomato___Septoria_leaf_spot', 'Corn_(maize)___Cercospora_leaf_spot_Gray_leaf_spot', 
    'Strawberry___Leaf_scorch', 'Peach___healthy', 'Apple___Apple_scab', 
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus', 'Tomato___Bacterial_spot', 
    'Apple___Black_rot', 'Blueberry___healthy', 'Cherry_(including_sour)___Powdery_mildew', 
    'Peach___Bacterial_spot', 'Apple___Cedar_apple_rust', 'Tomato___Target_Spot', 
    'Pepper,_bell___healthy', 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)', 
    'Potato___Late_blight', 'Tomato___Tomato_mosaic_virus', 'Strawberry___healthy', 
    'Apple___healthy', 'Grape___Black_rot', 'Potato___Early_blight', 
    'Cherry_(including_sour)___healthy', 'Corn_(maize)___Common_rust_', 
    'Grape___Esca_(Black_Measles)', 'Raspberry___healthy', 
    'Tomato___Leaf_Mold', 'Tomato___Spider_mites_Two-spotted_spider_mite', 
    'Pepper,_bell___Bacterial_spot', 'Corn_(maize)___healthy'
]

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    if file:
        file_path = os.path.join('static', 'uploads', file.filename)
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        file.save(file_path)

        print(f"File saved to {file_path}")

        img = image.load_img(file_path, target_size=(256, 256))
        img_array = image.img_to_array(img) / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        predictions = loaded_model.predict(img_array)
        print(f"Predictions: {predictions}")

        class_index = np.argmax(predictions)
        predicted_class = class_labels[class_index]
        print(f"Predicted class: {predicted_class}")

        image_url = url_for('static', filename=f'uploads/{file.filename}', _external=True)

        return jsonify({
            'prediction': predicted_class,
            'img_path': image_url
        })

if __name__ == '__main__':
    app.run(debug=True)

