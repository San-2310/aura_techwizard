import torch
from transformers import AutoTokenizer, AutoModel
import nltk
from nltk.tokenize import sent_tokenize
import numpy as np
import PyPDF2
import pytesseract
from PIL import Image
import io

nltk.download('punkt')

tokenizer = AutoTokenizer.from_pretrained("dmis-lab/biobert-v1.1")
model = AutoModel.from_pretrained("dmis-lab/biobert-v1.1")

def get_sentence_embeddings(sentences):
    inputs = tokenizer(sentences, padding=True, truncation=True, return_tensors="pt")
    with torch.no_grad():
        outputs = model(**inputs)
    sentence_embeddings = outputs.last_hidden_state[:, 0, :].numpy()
    return sentence_embeddings

def cosine_similarity(a, b):
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

def extract_text_from_pdf(file_object):
    pdf_reader = PyPDF2.PdfReader(file_object)
    text = ""
    for page in pdf_reader.pages:
        text += page.extract_text()
    return text

def extract_text_from_image(file_object):
    image = Image.open(file_object)
    text = pytesseract.image_to_string(image)
    return text

def analyze_text(text):
    sentences = sent_tokenize(text)
    embeddings = get_sentence_embeddings(sentences)
    
    key_phrases = [
        "The patient is diagnosed with",
        "The recommended treatment is",
        "Risk factors include",
        "The prognosis is",
        "Follow-up care includes"
    ]
    key_embeddings = get_sentence_embeddings(key_phrases)
    
    analysis_results = []
    for phrase, key_emb in zip(key_phrases, key_embeddings):
        similarities = [cosine_similarity(key_emb, sent_emb) for sent_emb in embeddings]
        most_similar_idx = np.argmax(similarities)
        analysis_results.append(f"{phrase}: {sentences[most_similar_idx]}")
    
    results = "\n\n".join(analysis_results)
    return results

def analyze_reports(file_objects):
    combined_text = ""
    for file_object in file_objects:
        file_object.seek(0)  
        if file_object.name.lower().endswith('.pdf'):
            text = extract_text_from_pdf(file_object)
        elif file_object.name.lower().endswith(('.jpg', '.jpeg', '.png')):
            text = extract_text_from_image(file_object)
        else:
            return f"Unsupported file type: {file_object.name}. Please upload PDF or image files."
        combined_text += text + "\n\n"

    if not combined_text.strip():
        return "No text could be extracted from the uploaded files. Please ensure the files contain readable text."

    return analyze_text(combined_text)