import os
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'  # Disable oneDNN custom operations

from flask import Flask, request, jsonify, render_template
from tensorflow.keras.models import load_model
from tensorflow.keras.layers import TextVectorization
import numpy as np
import pandas as pd
import joblib
from reportanalysis.report_analyzer import analyze_reports
import io
#from petfoodrecipe.pet_food_model import PetFoodModel

app = Flask(__name__)

# Global variables to store models and preprocessors
animal_model = None
toxicity_model = None
pet_food_model = None
preprocessor = None
label_encoder = None
vectorizer = None
models_loaded = False

def load_models():
    global toxicity_model#, pet_food_model, preprocessor, label_encoder, vectorizer, models_loaded, animal_model
    
    if not models_loaded:
        print("Loading models...")
        # Load models and preprocessors for animal condition prediction
        # animal_model = load_model('animalcondition/animal_danger_model.h5')
        # preprocessor = joblib.load('animalcondition/preprocessor.pkl')
        # label_encoder = joblib.load('animalcondition/label_encoder.pkl')

        # Load model for comment toxicity prediction
        toxicity_model = load_model('checkcommenttoxicity/toxicity.h5')

        # Load dataset to adapt the TextVectorization
        df = pd.read_csv('checkcommenttoxicity/train.csv')
        MAX_FEATURES = 200000

        vectorizer = TextVectorization(max_tokens=MAX_FEATURES,
                                       output_sequence_length=2000,
                                       output_mode='int')
        vectorizer.adapt(df['comment_text'].values)

        # Load the pet food prediction model
        # pet_food_model = PetFoodModel.load_model('./petfoodrecipe/pet_food_model.joblib')

        models_loaded = True
        print("Models loaded successfully.")

@app.before_request
def before_request():
    load_models()

@app.route('/')
def home():
    return render_template('index.html')

# @app.route('/check_animal_condition', methods=['POST'])
# def predict_animal():
#     data = request.json
    
#     required_fields = ['AnimalName', 'symptoms1', 'symptoms2', 'symptoms3', 'symptoms4', 'symptoms5']
#     if not all(field in data for field in required_fields):
#         return jsonify({'error': 'Missing required fields'}), 400
    
#     input_df = pd.DataFrame([data])
#     input_df = input_df[required_fields]
    
#     input_encoded = preprocessor.transform(input_df).toarray()
    
#     # Make prediction
#     prediction = animal_model.predict(input_encoded)
    
#     # Convert prediction to label
#     predicted_label = label_encoder.inverse_transform([round(prediction[0][0])])[0]
    
#     return jsonify({
#         'prediction': str(predicted_label),
#         'probability': float(prediction[0][0])
#     })

# @app.route('/check_comment_toxicity', methods=['POST'])
# def predict_toxicity():
#     data = request.json
#     comment_text = data['text']
    
#     vectorized_text = vectorizer([comment_text])
    
#     prediction = (toxicity_model.predict(vectorized_text) > 0.5).astype(int).tolist()
    
#     return jsonify({'prediction': prediction})
@app.route('/check_comment_toxicity', methods=['POST'])
def predict_toxicity():
    data = request.json
    comment_text = data['text']
    
    # Vectorize the input text
    vectorized_text = vectorizer([comment_text])
    
    # Get prediction scores for each of the four fields
    prediction_scores = toxicity_model.predict(vectorized_text).tolist()[0]
    
    # Check if any score is above 0.5
    is_toxic = any(score > 0.5 for score in prediction_scores)
    
    # Return the binary toxicity result
    return jsonify({'is_toxic': is_toxic})


@app.route('/analyze_medical_reports', methods=['POST'])
def analyze_medical_reports():
    if 'files' not in request.files:
        return jsonify({'error': 'No files part in the request'}), 400
    
    files = request.files.getlist('files')
    
    if not files or files[0].filename == '':
        return jsonify({'error': 'No files selected for uploading'}), 400
    
    try:
        file_objects = []
        for file in files:
            file_object = io.BytesIO(file.read())
            file_object.name = file.filename
            file_objects.append(file_object)
        
        results = analyze_reports(file_objects)
        
        return jsonify({'analysis': results})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# @app.route('/predict_pet_food', methods=['POST'])
# def predict_pet_food():
#     data = request.json
#     breed = data.get('breed')
#     ingredients = data.get('ingredients')

#     if not breed or not ingredients:
#         return jsonify({'error': 'Missing breed or ingredients'}), 400

#     try:
#         recipe, cooking_method = pet_food_model.predict(breed, ingredients)
#         return jsonify({
#             'recipe_name': recipe,
#             'cooking_method': cooking_method,
#             'note': 'This prediction is based on the closest match in our database.'
#         })
#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=False, port=8000, host='0.0.0.0')