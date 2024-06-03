from flask import Flask, request, jsonify, url_for
from tensorflow.keras.preprocessing import image
import numpy as np
from tensorflow.keras.models import load_model
import os
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS

# Load the saved model
loaded_model = load_model("finetuned_model.h5")

# Path to training data directory
training_data_path = r"D:\KEC PROJECTS\2 YEAR\4 sem\Hack Sphere\New folder\New Plant Diseases Dataset(Augmented)\New Plant Diseases Dataset(Augmented)\train"

# Get the class labels
class_labels = sorted(os.listdir(training_data_path))

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    if file:
        # Save the file to a temporary location
        file_path = os.path.join('static', 'uploads', file.filename)
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        file.save(file_path)

        print(f"File saved to {file_path}")

        # Load and preprocess the image
        img = image.load_img(file_path, target_size=(256, 256))
        img_array = image.img_to_array(img) / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        # Make predictions
        predictions = loaded_model.predict(img_array)
        print(f"Predictions: {predictions}")

        # Decode the predictions
        class_index = np.argmax(predictions)
        predicted_class = class_labels[class_index]
        print(f"Predicted class: {predicted_class}")

        # Generate the full URL for the image
        image_url = url_for('static', filename=f'uploads/{file.filename}', _external=True)

        return jsonify({
            'prediction': predicted_class,
            'img_path': image_url
        })

if __name__ == '__main__':
    app.run(debug=True)
