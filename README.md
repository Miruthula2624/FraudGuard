# 🛡️ Hybrid Job Scam Detection System 
### *Enterprise-Grade Dual-Engine Intelligence for Safer Recruitment*


## 📖 Project Overview

The **Hybrid Job Scam Detection System** is a cutting-edge cybersecurity platform designed to protect job seekers from the growing epidemic of digital fraud. Unlike traditional software that relies solely on simple keywords, this system employs a **Harmonized Intelligence Architecture**. It fuses a high-coverage **Regex Rule Engine** (Node.js) with a deep **Voting Ensemble Machine Learning Model** (Python), providing a safety net that is both fast and incredibly accurate.

Whether a scam arrives as a plain text message, a sophisticated email, or a screenshot of a fake job post, our system extracts, analyzes, and classifies the threat in milliseconds.

---

## 📑 Table of Contents
1. [Core Features](#-core-features)
2. [Advanced Tech Stack](#-advanced-tech-stack)
3. [System Architecture](#-system-architecture)
4. [Deep Dive: The Analysis Logic](#-deep-dive-the-analysis-logic)
5. [Deep Dive: Machine Learning Pipeline](#-deep-dive-machine-learning-pipeline)
6. [Directory Structure](#-directory-structure)
7. [API Reference](#-api-reference)
8. [Installation & Setup](#-installation--setup)
9. [Database Schema](#-database-schema)
10. [Security Framework](#-security-framework)
11. [Roadmap & Future Enhancements](#-roadmap--future-enhancements)
12. [Troubleshooting & FAQ](#-troubleshooting--faq)

---

## 🚀 Core Features

### 🔍 OCR & Image Analysis
- Integrated with `Tesseract.js` for high-precision text extraction from images.
- Supports `.jpg`, `.jpeg`, and `.png` formats.
- Pre-processing logic to handle noisy backgrounds in screenshots.

### 🛡️ Hybrid Detection (Rule + ML)
- **Engine A (Rules)**: 400+ hand-crafted regex patterns covering 12 fraud sectors.
- **Engine B (ML)**: A Voting Ensemble model trained on **1,100+ real-world samples**.
- **Blended Scoring**: Uses a weighted probability merger to reduce false positives.

### 📊 Comprehensive Dashboard
- **Scan History**: Persistent storage of every scan metadata.
- **Visual Confidence**: Real-time progress bars showing ML probability across 9 categories.
- **Indicator Breakdown**: Explains *why* a message was flagged (e.g., "Urgent Language", "Money Request").

### 🔐 Enterprise-Grade Security
- **Bcrypt**: Industrial-strength password hashing with a salt factor of 10.
- **Session-Based Auth**: Secure server-side session management (no token exposure in LocalStorage).
- **SQL Sanitization**: 100% protection against SQL Injection using parameterized queries.

---

## 🛠️ Advanced Tech Stack

### Frontend (User Interface)
- **Framework**: React 18 (Vite-powered for lightning-fast HMR).
- **Styling**: Tailwind CSS with custom **Glassmorphism** design system.
- **Animations**: Framer Motion for smooth state transitions and micro-interactions.
- **Icons**: Lucide-React for clean, lightweight visuals.

### Backend (The Orchestrator)
- **Runtime**: Node.js & Express.
- **File Handling**: Multer for secure, multi-part binary uploads.
- **Intelligence Bridge**: Axios for seamless communication with the Python Flask microservice.
- **Session Management**: `express-session` with secure cookie configuration.

### Machine Learning Tier
- **Language**: Python 3.10+.
- **Model Framework**: Scikit-Learn.
- **API Framework**: Flask with `flask-cors`.
- **Serialization**: Joblib for high-performance weight loading.

---

## 🏗️ System Architecture

```text
fake-job-posting/
├── backend/                # Node.js Server (The API Hub)
│   ├── config/             # Database connection & Environment setup
│   ├── middleware/         # Authentication gating & validation
│   ├── routes/             # REST Endpoints (Auth, Scan, User History)
│   ├── utils/              # The 400+ pattern Rule-based logic engine
│   └── uploads/            # Secure sandbox for temporary OCR processing
├── frontend/               # React Application (The Client Portal)
│   ├── src/
│   │   ├── components/     # Reusable UI Atoms & Molecules
│   │   ├── pages/          # Login, Register, Scanner, Dashboard
│   │   ├── context/        # Authenticated User State Management
│   │   └── utils/          # API services & helper functions
├── ml/                     # Python Flask Service (The Brain)
│   ├── model/              # Serialized Weights (.joblib) & Label index
│   ├── predict_api.py      # Flask REST API serving predictions
│   ├── train_model.py      # Model training, validation & evaluation
│   ├── training_data.csv   # Master dataset (1,100+ labeled rows)
│   └── generate_big_data.py# Script for synthetic data expansion
└── database/               # Relational Storage
    └── schema.sql          # MySQL definition & table structures
```

---

## 🧠 Deep Dive: The Analysis Logic

Our system doesn't just look for bad words; it analyzes the **intent and structure** of communication.

### 1. The Rule Engine (utils/analyzer.js)
This engine is designed for **High Recall**. It consists of constant-time pattern lookups across specialized categories:
- **Urgent Language**: Patterns like `act fast`, `immediately`, `within 2 hours`.
- **Money Requests**: Flags `security deposit`, `kit fee`, `laptop charges`, `UPI to...`.
- **Personal Data**: Detects requests for `OTP`, `CVV`, `Aadhaar`, or `PAN card`.
- **Indian Context**: Specifically tuned for Indian scams (GPay requests, `Lakhs` promises).

### 2. The Machine Learning Model (ml/train_model.py)
This engine is designed for **High Precision**. It uses a **Soft-Voting Ensemble** which combines:
- **Logistic Regression**: The reliable backbone for text classification.
- **Naive Bayes**: Excellent at identifying frequencies of "scammy" keywords.
- **Random Forest**: Best at detecting non-linear structures and patterns in long messages.

### 3. The Merger Logic (routes/scan.js)
The final classification is not a democratic vote but a **Weighted Blender**:
- **Final Confidence = (ML Prediction * 0.6) + (Rule Score * 0.4)**
- **Why?**: ML is smarter but biased towards the data it has seen. Rules are dumber but covers classic patterns. Together, they are nearly impossible to fool.

---

## 🧪 Deep Dive: Machine Learning Pipeline

### Data Preprocessing
To prevent the model from memorizing specific phone numbers or URLs, we use a **Masking Pipeline**:
- `http://google.com` $\rightarrow$ `urltoken`
- `9876543210` $\rightarrow$ `phonetoken`
- `rs 50,000` $\rightarrow$ `moneytoken`
This forces the model to learn the *context* surrounding the scam rather than the specific details.

### Classification Categories
The model classifies input into one of 9 distinct labels:
1. `fake_job`: High risk fraudulent job posts.
2. `scam_message`: SMS/WhatsApp phishing.
3. `scam_email`: Email-based fraud.
4. `investment_scam`: "Earn 10x" stock/crypto scams.
5. `romance_scam`: Relationship-based emotional engineering.
6. `lottery_scam`: "You have won a prize" fraud.
7. `genuine_job`: Standard legitimate hiring notices.
8. `legitimate_email`: Standard work communication.
9. `legitimate_message`: Safe personal messages.

---

## 📡 API Reference

### Backend Endpoints (Port 5000)
| Endpoint | Method | Params | Description |
| :--- | :--- | :--- | :--- |
| `/api/auth/register` | `POST` | `name, email, password` | Creates a new account |
| `/api/auth/login` | `POST` | `email, password` | Authenticats & starts session |
| `/api/scan/text` | `POST` | `content` | Analyzes raw strings |
| `/api/scan/file` | `POST` | `file` (form-data) | OCR + Analysis |
| `/api/history` | `GET` | - | Fetches user's previous scan reports |

### ML Microservice (Port 5001)
| Endpoint | Method | Params | Description |
| :--- | :--- | :--- | :--- |
| `/predict` | `POST` | `text` | Returns Class Label + Probabilities |
| `/health` | `GET` | - | Checks if ML Model is loaded |
| `/labels` | `GET` | - | Returns all supported scam types |

---

## 🛠️ Installation & Setup

### Phase 1: Prerequisites
- **Node.js** v16 or higher.
- **Python** 3.10 or higher.
- **MySQL** 8.0 or higher.

### Phase 2: Database Layer
1. Create a database named `job_scam_db`.
2. Import the schema:
   ```bash
   mysql -u root -p job_scam_db < database/schema.sql
   ```

### Phase 3: Machine Learning Intelligence
1. Navigate to `/ml`.
2. Install dependencies:
   ```bash
   pip install scikit-learn flask pandas numpy joblib flask-cors
   ```
3. Train the model (takes ~10 seconds):
   ```bash
   python train_model.py
   ```
4. Start the service:
   ```bash
   python predict_api.py
   ```

### Phase 4: Backend Integration
1. Navigate to `/backend`.
2. Install modules: `npm install`.
3. Create `.env` and fill in DB details:
   ```env
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=your_mysql_password
   DB_NAME=job_scam_db
   SESSION_SECRET=a_very_secure_random_string
   ML_API_URL=http://127.0.0.1:5001/predict
   ```
4. Run: `npm run dev`.

### Phase 5: User Interface
1. Navigate to `/frontend`.
2. Install modules: `npm install`.
3. Run: `npm run dev`.
4. Visit `http://localhost:5173`.

---

## 🔒 Security Framework

- **SQL Injection**: We never concatenate strings in queries. We use `?` placeholders which are safely escaped by the `mysql2` driver.
- **XSS Protection**: React automatically escapes all data rendered in the DOM, preventing script injection.
- **CSRF**: We use `SameSite: LST` cookies for our session tokens to prevent unauthorized cross-origin requests.
- **Privacy**: The OCR engine works locally (within the server) and doesn't send images to third-party clouds.

---

## 🚧 Troubleshooting & FAQ

**Q: The model says "ML Offline" in the dashboard.**
**A**: Ensure you have run `python ml/predict_api.py` and it is listening on port 5001.

**Q: OCR is not detecting text well.**
**A**: High-contrast, clear screenshots work best. Very low-resolution or blurry images might reduce Tesseract's accuracy.

**Q: Can I add more training data?**
**A**: Yes! Add rows to `ml/training_data.csv` and re-run `python ml/train_model.py`. The system will instantly pick up the new "intelligence".

---

## 🌟 Acknowledgements
- **Tesseract.js** for the OCR capabilities.
- **Scikit-Learn** for the powerful ensemble modeling.
- **Google Fonts** (Outfit, Inter) for the premium typography.

