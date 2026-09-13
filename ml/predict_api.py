"""
=============================================================================
  SCAM DETECTOR — ML PREDICTION API (Flask)
  Runs on port 5001
  Endpoint: POST /predict  { "text": "..." }
  Returns:  { label, confidence, probabilities, content_type }
=============================================================================
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import os
import re

app = Flask(__name__)
CORS(app)

BASE_DIR    = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH  = os.path.join(BASE_DIR, "model", "scam_detector.joblib")
LABELS_PATH = os.path.join(BASE_DIR, "model", "labels.txt")

# ─────────────────────────────────────────────
#  LOAD MODEL AT STARTUP
# ─────────────────────────────────────────────
print("⏳ Loading ML model...")
try:
    pipeline = joblib.load(MODEL_PATH)
    with open(LABELS_PATH) as f:
        LABELS = [l.strip() for l in f.readlines()]
    print(f"✅ Model loaded. Labels: {LABELS}")
except Exception as e:
    print(f"❌ Failed to load model: {e}")
    pipeline = None
    LABELS   = []

# ─────────────────────────────────────────────
#  TEXT PREPROCESSING (must match train_model.py)
# ─────────────────────────────────────────────
def preprocess(text):
    text = str(text).lower()
    text = re.sub(r'http\S+|www\S+', ' urltoken ', text)
    text = re.sub(r'\b\d{10,}\b', ' phonenumber ', text)
    text = re.sub(r'\S+@\S+', ' emailtoken ', text)
    text = re.sub(r'rs\.?\s*\d+|₹\s*\d+|\d+\s*lpa|\d+\s*lakh', ' moneytoken ', text)
    text = re.sub(r'[^a-z\s]', ' ', text)
    text = re.sub(r'\s+', ' ', text).strip()
    return text

# ─────────────────────────────────────────────
#  LABEL → HUMAN FRIENDLY DISPLAY
# ─────────────────────────────────────────────
LABEL_META = {
    "genuine_job":         {"display": "✅ Genuine Job",          "type": "job",     "safe": True},
    "fake_job":            {"display": "❌ Fake Job / Scam",       "type": "job",     "safe": False},
    "scam_message":        {"display": "❌ Scam Message",          "type": "message", "safe": False},
    "scam_email":          {"display": "❌ Scam Mail",             "type": "email",   "safe": False},
    "investment_scam":     {"display": "❌ Investment Scam",       "type": "finance", "safe": False},
    "romance_scam":        {"display": "❌ Romance / Social Scam", "type": "romance", "safe": False},
    "lottery_scam":        {"display": "❌ Lottery / Prize Scam",  "type": "lottery", "safe": False},
    "legitimate_email":    {"display": "✅ Legitimate Email",      "type": "email",   "safe": True},
    "legitimate_message":  {"display": "✅ Legitimate Message",    "type": "message", "safe": True},
}

# ─────────────────────────────────────────────
#  GIBBERISH CHECK
# ─────────────────────────────────────────────
def is_gibberish(text):
    t = text.strip()
    if len(t) < 10: return True
    letters = re.findall(r'[a-zA-Z]', t)
    vowels  = re.findall(r'[aeiouAEIOU]', t)
    if len(letters) > 5:
        ratio = len(vowels) / len(letters)
        if ratio < 0.10 or ratio > 0.90: return True
    words = t.split()
    if len(words) == 1 and len(t) > 8 and t.isalnum(): return True
    alpha_ratio = len(letters) / max(len(t), 1)
    if len(t) > 10 and alpha_ratio < 0.35: return True
    if re.search(r'(.)\1{5,}', t): return True
    return False

# ─────────────────────────────────────────────
#  ROUTES
# ─────────────────────────────────────────────
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "model_loaded": pipeline is not None})

@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()
        text = data.get("text", "").strip()

        if not text:
            return jsonify({"error": "text field is required"}), 400

        # Gibberish guard
        if is_gibberish(text):
            return jsonify({
                "label":         "invalid_input",
                "display":       "⚠️ Invalid Input",
                "confidence":    0,
                "safe":          None,
                "content_type":  "unknown",
                "probabilities": {},
                "ml_used":       True,
                "note":          "Text appears to be random or too short for analysis."
            })

        if pipeline is None:
            return jsonify({"error": "Model not loaded. Run train_model.py first."}), 503

        processed = preprocess(text)
        label     = pipeline.predict([processed])[0]
        proba     = pipeline.predict_proba([processed])[0]
        confidence = round(float(max(proba)) * 100, 1)

        # Build probability dict
        prob_dict = {
            LABELS[i]: round(float(p) * 100, 1)
            for i, p in enumerate(proba)
        }

        meta = LABEL_META.get(label, {
            "display": label.replace("_", " ").title(),
            "type": "unknown",
            "safe": None
        })

        return jsonify({
            "label":         label,
            "display":       meta["display"],
            "confidence":    confidence,
            "safe":          meta["safe"],
            "content_type":  meta["type"],
            "probabilities": prob_dict,
            "ml_used":       True,
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/labels", methods=["GET"])
def get_labels():
    return jsonify({"labels": LABELS, "meta": LABEL_META})

# ─────────────────────────────────────────────
#  MAIN
# ─────────────────────────────────────────────
if __name__ == "__main__":
    print("🚀 Starting Scam Detector ML API on port 5001...")
    app.run(host="0.0.0.0", port=5001, debug=False)
