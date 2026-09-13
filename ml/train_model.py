"""
=============================================================================
  FAKE JOB / SCAM DETECTOR — ML TRAINING SCRIPT
  Model: TF-IDF Vectorizer + Voting Ensemble
         (Logistic Regression + Multinomial Naive Bayes + Random Forest)
  Classes: genuine_job, fake_job, scam_message, scam_email,
           investment_scam, romance_scam, lottery_scam,
           legitimate_email, legitimate_message
=============================================================================
"""

import pandas as pd
import numpy as np
import joblib
import os
import re
import sys

# Fix Windows console encoding to support UTF-8 output
if sys.stdout.encoding != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import MultinomialNB
from sklearn.ensemble import RandomForestClassifier, VotingClassifier
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split, cross_val_score, StratifiedKFold
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from sklearn.preprocessing import LabelEncoder

# ─────────────────────────────────────────────
#  CONFIG
# ─────────────────────────────────────────────
BASE_DIR   = os.path.dirname(os.path.abspath(__file__))
DATA_FILE  = os.path.join(BASE_DIR, "training_data.csv")
MODEL_DIR  = os.path.join(BASE_DIR, "model")
os.makedirs(MODEL_DIR, exist_ok=True)

# ─────────────────────────────────────────────
#  TEXT PREPROCESSING
# ─────────────────────────────────────────────
def preprocess(text):
    text = str(text).lower()
    text = re.sub(r'http\S+|www\S+', ' urltoken ', text)   # mask URLs
    text = re.sub(r'\b\d{10,}\b', ' phonenumber ', text)   # mask phone numbers
    text = re.sub(r'\S+@\S+', ' emailtoken ', text)         # mask email addresses
    text = re.sub(r'rs\.?\s*\d+|₹\s*\d+|\d+\s*lpa|\d+\s*lakh', ' moneytoken ', text)  # mask money
    text = re.sub(r'[^a-z\s]', ' ', text)                  # remove special chars
    text = re.sub(r'\s+', ' ', text).strip()
    return text

# ─────────────────────────────────────────────
#  AUGMENTED TRAINING DATA (in-code examples)
#  Combined with CSV for maximum coverage
# ─────────────────────────────────────────────
AUGMENTED_DATA = [
    # genuine_job
    ("We are looking for an experienced Backend Developer with Node.js and MongoDB skills. 3 years minimum. Salary 12-18 LPA. Apply via LinkedIn.", "genuine_job"),
    ("Wipro is hiring freshers through campus placement. Eligible: 2025 batch B.Tech/BE. Minimum 60% aggregate. Apply through official Wipro careers page.", "genuine_job"),
    ("HDFC Bank requires Relationship Manager for retail banking. Must have 2 years banking experience. Excellent communication skills needed. Fixed salary + incentives.", "genuine_job"),
    ("Opening for Cloud Architect at leading MNC. AWS Solutions Architect certification required. 8+ years experience. Hybrid work model. Benefits include ESOP.", "genuine_job"),
    ("We are hiring a QA Engineer with selenium and API testing experience. Agile environment. Notice period: immediate to 30 days preferred.", "genuine_job"),
    ("Teaching position available at ABC International School. Subject: Mathematics, Grade 6-10. B.Ed required. 5 day week, summer holidays. Apply with resume and reference letters.", "genuine_job"),
    ("Operations Research Analyst needed. Statistical modeling, Python/R, supply chain experience preferred. MBA or Masters in Operations Research required.", "genuine_job"),
    ("Looking for Graphic Designer with 2+ years experience. Adobe Illustrator, Photoshop, InDesign skills. Portfolio required. Permanent position. Delhi based.", "genuine_job"),
    ("Regulatory Affairs Specialist for pharma company. Knowledge of CDSCO, FDA regulations. Life sciences degree required. Competitive package with annual increments.", "genuine_job"),
    ("Senior Sales Executive for B2B SaaS product. 3+ years enterprise sales experience. Target driven role with high variable pay component and travel reimbursement.", "genuine_job"),

    # fake_job
    ("EARN RS 30000 WEEKLY FROM HOME!! No experience!!! Copy paste works!! Join now on Whatsapp 7788992211!!! 100% genuine!! Government certified company!!!", "fake_job"),
    ("Online task available for students. Like YouTube videos earn money. Earn Rs 2000 per day daily payment. No investment just smartphone. Telegram group link inside.", "fake_job"),
    ("Housewife job work from home zero investment earn Rs 800 per hour. No boss no pressure be your own boss. Direct selection no interview. Send message on WhatsApp.", "fake_job"),
    ("MLM opportunity join free earn lakhs. Refer 3 friends each refers 3. Unlimited downline income. Auto pool daily bonus. Network marketing 100% legal guaranteed.", "fake_job"),
    ("AMAZON REVIEW WRITER NEEDED. Write product reviews earn Rs 300 per review. Work from phone 2 hours daily. No experience needed. Daily payout guaranteed.", "fake_job"),
    ("Retired persons senior citizen income opportunity. Work from home earn daily. No travel needed. Any age can do. Earn Rs 15000 monthly sitting at home.", "fake_job"),
    ("Join our meesho reselling team. No investment earn commission. Sell online products and earn 20-30% profit. WhatsApp group for training and support.", "fake_job"),
    ("Prepaid task job. Complete simple task on Telegram and earn Rs 500 per task. Daily unlimited tasks available. Payout instant via UPI. Join now limited seats.", "fake_job"),
    ("Data entry job from home. Type from image earn Rs 1 per word. 500 words per hour means Rs 500 hourly. Monthly earn Rs 60000 easily at home.", "fake_job"),
    ("Instagram promotion task. Follow accounts like posts comment and earn. Daily Rs 1500 payout. Work 1 hour only. Joining fee Rs 199 refundable after first payment.", "fake_job"),

    # scam_message
    ("Your SBI account has been suspended. To reactivate send your account number debit card number CVV and OTP to sbi.helpdesk@gmail.com immediately.", "scam_message"),
    ("Congratulations! You won Rs 1 Lakh in Paytm Lucky Draw. Claim now at bit.ly/paytm-win by entering your UPI PIN to receive transfer.", "scam_message"),
    ("TRAI order: Your mobile number flagged for illegal activity. Your SIM will be blocked in 2 hours. Call 7700445566 to resolve and avoid arrest.", "scam_message"),
    ("Your Aadhaar is linked to 3 criminal cases. Supreme Court order to freeze your accounts. Call CBI officer 9900223344 immediately to avoid digital arrest.", "scam_message"),
    ("Electricity bill payment of Rs 3200 pending. Last warning before disconnection tonight 9 PM. Pay now: bit.ly/msedcl-pay or call 7788001122.", "scam_message"),
    ("Your Jio SIM will expire in 24 hours. Complete esim upgrade by clicking: jio-upgrade-sim.com and paying Rs 50 upgrade fee to continue service.", "scam_message"),
    ("Dear winner your phone number selected in Airtel 5G lottery. Prize Rs 5 Lakh. Call lottery manager 8822334455. Keep confidential. Valid 48 hours only.", "scam_message"),
    ("Task completed! Release your Rs 15000 earning by paying Rs 500 wallet activation fee via UPI to 9900XXXXXX@paytm. Money will be unlocked instantly.", "scam_message"),
    ("FREE OFFER: First 100 users get free iPhone 14! Click to claim: rb.gy/iphone-free. Fill form and pay Rs 99 insurance fee to receive your phone.", "scam_message"),
    ("E-Challan notice: Traffic violation by your vehicle KA01-XXXX. Fine Rs 1500. Pay within 24 hours at parivahan-echallan.site or legal action will be taken.", "scam_message"),

    # scam_email
    ("Subject: Compensation Fund - $2.5 Million. Dear Beneficiary, The FBI has approved release of unclaimed compensation funds. You are entitled to $2.5 million. Send your bank details and passport copy to claim.", "scam_email"),
    ("Your Apple ID has been compromised. Verify immediately at apple-id-secure-verification.com. Enter your Apple ID password, face ID backup and payment card to restore.", "scam_email"),
    ("Dear Job Seeker, We are pleased to hire you for our position in London. Salary GBP 5000. Please pay visa processing fee of Rs 45000 and flight ticket to our agent. Appointment letter attached.", "scam_email"),
    ("World Bank Grant Notice: A grant of $500,000 has been approved for you. To release funds, pay administrative fee of $500 and provide your complete bank account details.", "scam_email"),
    ("Subject: Netflix Account Suspended. Your payment failed and Netflix account is suspended. Update payment at netflix-account-billing.com within 24 hours to continue watching.", "scam_email"),
    ("Dear Friend, I am dying of cancer and want to donate $3 million of my wealth to charity. I have chosen you as a beneficiary. Respond with your bank details. God bless you.", "scam_email"),
    ("Amazon: We noticed unusual sign-in activity on your account. Your account is locked. Verify at amazon-signin-security.net with your email, password and OTP to unlock.", "scam_email"),
    ("Income Tax Refund of Rs 24,350 approved for PAN ABCDE1234F. To receive, verify your bank account and net banking credentials at incometax-refund-portal.in urgently.", "scam_email"),
    ("Dear Investor, Our hedge fund has delivered 300% returns this year. Minimum investment $10,000. Wire transfer or Bitcoin accepted. Guaranteed capital protection. Apply now.", "scam_email"),
    ("Subject: DHL Package - Customs Fee Required. Your parcel from USA is held at customs. Pay Rs 3500 clearance fee at dhl-customs-india.com within 48 hours.", "scam_email"),

    # investment_scam
    ("Invest in our cryptocurrency arbitrage bot! 5% daily returns guaranteed. Minimum deposit Rs 10,000. Withdraw profits hourly. 50,000 active investors. Zero risk!", "investment_scam"),
    ("SEBI Registered? We provide sure shot intraday trading tips! 99% accuracy. Earn Rs 5000 daily from stock market. Subscribe Rs 5000 per month for VIP signals.", "investment_scam"),
    ("Join our forex trading masterclass and copy our signals. Make $500 daily on autopilot. Trading robot works for you. Minimum capital $100. 10x returns guaranteed.", "investment_scam"),
    ("Earn 2% daily on your idle savings! Our P2P lending platform gives 60% annual returns. Withdraw weekly. Principal 100% safe. NBFC registered. Join 2 lakh investors.", "investment_scam"),
    ("NEW TOKEN LAUNCH! Get in early before price 100x! Only 1000 spots available. Buy XCOIN now at pre-launch price. Crypto wallet USDT payment. Listing on major exchanges soon.", "investment_scam"),
    ("Gold investment scheme: Invest Rs 50,000 get Rs 1,00,000 in 1 year! Backed by physical gold storage. SEBI approved. Fixed annual return 100%. Monthly payouts available.", "investment_scam"),
    ("MLM binary plan: Join Rs 1000, refer 2 get Rs 500 each, your 2 refer 2 each. Unlimited levels. Monthly passive income Rs 1 Lakh possible. Auto pool system included.", "investment_scam"),
    ("Metaverse land sale! Buy virtual plots starting $50. Expected 50x returns as metaverse grows. Limited plots available. Pay in USDT or ETH. Early investors only.", "investment_scam"),

    # romance_scam
    ("Hello dear I found your profile on Instagram you look very beautiful. I am a NASA scientist working in USA. I am lonely since divorce. Can we be friends and talk daily?", "romance_scam"),
    ("My sweetheart I love you so much. I am coming to India to meet you but my luggage is stuck at airport customs. Please send Rs 20000 to airport agent to release my bags.", "romance_scam"),
    ("I am a widowed US Army General currently deployed in Syria. I have $2 million savings I want to invest. My finance officer will teach you crypto trading for extra income.", "romance_scam"),
    ("My darling I am in hospital abroad after accident. Surgery cost $10000. I have no family here. Please help me with Rs 50000. I will return everything when I recover.", "romance_scam"),
    ("Hi beautiful! I am merchant navy officer earning well. I want to send you gifts from Singapore but customs wants clearance fee Rs 5000. Please pay agent for release.", "romance_scam"),

    # lottery_scam
    ("BREAKING: Your phone number 98XXXXXXXX won Rs 50 Lakh in PM Modi government lucky draw scheme 2024! To claim call agent Mr Raju 9811XXXXXX. 100% genuine government prize.", "lottery_scam"),
    ("Microsoft Global Lottery: Your email was computer selected. You won $750,000 prize. Contact lottery claim department at microsoftlottery_org@yahoo.com with your personal details.", "lottery_scam"),
    ("BSNL Festive Lucky Draw Result: You are WINNER number 3 of Rs 15 Lakh prize! Your winning ticket ID: BSNL-2024-WIN7291. Call claim processing: 9700XXXXXX within 72 hours.", "lottery_scam"),
    ("You are the 1 Crore visitor to Flipkart! You won Samsung Galaxy S24 Ultra! Pay Rs 149 shipping fee to claim your prize at flipkart-winner-claim.in. Limited time only!", "lottery_scam"),
    ("Covid Relief Prize: Government of India giving Rs 2 Lakh to selected Aadhaar holders. Your Aadhaar selected. Share Aadhaar number, bank account and OTP to receive fund.", "lottery_scam"),

    # legitimate_email
    ("Hi Rahul, Following up on yesterday's call — I have circulated the revised SLA document to all stakeholders. Please review section 4 and confirm if the revised terms work for your team.", "legitimate_email"),
    ("Dear Team, The office will be closed on Friday March 7 on account of Holi festival. Wishing everyone a wonderful Holi. Normal operations resume Monday March 10.", "legitimate_email"),
    ("Attached is the vendor invoice #INV-2024-0892 for the consulting services rendered in February. Please process payment by month end as per agreed terms. PO number: PO-8821.", "legitimate_email"),
    ("This is a confirmation that your domain renewal for yourdomain.com has been processed. Your domain is valid until March 2026. No action required. Support: support@registrar.com", "legitimate_email"),
    ("Thank you for registering for the National Cybersecurity Conference 2025. Your ticket is confirmed. Event: April 5, 9 AM. Venue: Taj Convention Centre, Bangalore. See you there!", "legitimate_email"),

    # legitimate_message
    ("Hi I will be 30 minutes late for the meeting. Traffic is bad. Please start without me and I will join as soon as I arrive. Sorry for inconvenience.", "legitimate_message"),
    ("Your Zomato order is on the way! Estimated arrival: 7:45 PM. Track live in app. Order ID: ZOM-99281. Any issues call: 1800-XXX-XXXX.", "legitimate_message"),
    ("Dear Parent, This is a reminder that PTM is scheduled for Saturday 10 AM. Please bring your ward's progress report. Contact class teacher for any queries.", "legitimate_message"),
    ("IRCTC: Your ticket PNR 2345678901 for Chennai-Mumbai Rajdhani on Feb 25 is confirmed. Coach B4 Seat 34. Print or show this SMS at departure.", "legitimate_message"),
    ("Blood donation camp at St Johns Hospital on March 2, 9 AM - 2 PM. Come donate, save lives. Free health checkup for donors. Contact: 080-XXXX-XXXX to register.", "legitimate_message"),
]

# ─────────────────────────────────────────────
#  LOAD + MERGE DATA
# ─────────────────────────────────────────────
print("[*] Loading training data...")
df_csv = pd.read_csv(DATA_FILE)
df_aug = pd.DataFrame(AUGMENTED_DATA, columns=["text", "label"])
df     = pd.concat([df_csv, df_aug], ignore_index=True).dropna()
df["text"] = df["text"].apply(preprocess)

print(f"[OK] Total training samples: {len(df)}")
print("\n[*] Class distribution:")
print(df["label"].value_counts())

X = df["text"].values
y = df["label"].values

# ─────────────────────────────────────────────
#  TFIDF VECTORIZER
# ─────────────────────────────────────────────
vectorizer = TfidfVectorizer(
    ngram_range=(1, 3),      # unigrams, bigrams, trigrams
    max_features=15000,
    sublinear_tf=True,
    min_df=1,
    analyzer="word",
    strip_accents="unicode",
    token_pattern=r"(?u)\b[a-z][a-z]+\b",
)

# ─────────────────────────────────────────────
#  INDIVIDUAL MODELS
# ─────────────────────────────────────────────
lr_model  = LogisticRegression(max_iter=2000, C=5.0, solver="lbfgs", random_state=42)
nb_model  = MultinomialNB(alpha=0.1)
rf_model  = RandomForestClassifier(n_estimators=200, max_depth=None, min_samples_split=2, random_state=42, n_jobs=-1)

# ─────────────────────────────────────────────
#  ENSEMBLE: Voting Classifier
# ─────────────────────────────────────────────
ensemble = VotingClassifier(
    estimators=[("lr", lr_model), ("nb", nb_model), ("rf", rf_model)],
    voting="soft",
    weights=[3, 1, 2]   # LR gets highest weight
)

# ─────────────────────────────────────────────
#  BUILD PIPELINE
# ─────────────────────────────────────────────
pipeline = Pipeline([
    ("tfidf",    vectorizer),
    ("ensemble", ensemble),
])

# ─────────────────────────────────────────────
#  CROSS VALIDATION
# ─────────────────────────────────────────────
print("\n[*] Running 5-fold cross validation...")
skf    = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
cv_scores = cross_val_score(pipeline, X, y, cv=skf, scoring="accuracy")
print(f"[OK] CV Accuracy: {cv_scores.mean()*100:.2f}% +/- {cv_scores.std()*100:.2f}%")

# ─────────────────────────────────────────────
#  TRAIN ON FULL DATA
# ─────────────────────────────────────────────
print("\n[*] Training final model on full dataset...")
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15, random_state=42, stratify=y)
pipeline.fit(X_train, y_train)

# ─────────────────────────────────────────────
#  EVALUATION
# ─────────────────────────────────────────────
y_pred = pipeline.predict(X_test)
acc    = accuracy_score(y_test, y_pred)
print(f"\n[OK] Test Accuracy: {acc*100:.2f}%")
print("\n[*] Classification Report:")
print(classification_report(y_test, y_pred))

# ─────────────────────────────────────────────
#  SAVE MODEL + METADATA
# ─────────────────────────────────────────────
model_path = os.path.join(MODEL_DIR, "scam_detector.joblib")
joblib.dump(pipeline, model_path, compress=3)
print(f"\n[SAVED] Model saved: {model_path}")

# Save label list
labels = sorted(df["label"].unique().tolist())
labels_path = os.path.join(MODEL_DIR, "labels.txt")
with open(labels_path, "w") as f:
    f.write("\n".join(labels))
print(f"[SAVED] Labels saved: {labels_path}")

# ─────────────────────────────────────────────
#  QUICK SANITY TESTS
# ─────────────────────────────────────────────
test_cases = [
    ("EARN 50000 DAILY WORK FROM HOME NO EXPERIENCE NEEDED WHATSAPP NOW 9876543210!!!", "[expected: fake_job]"),
    ("Your SBI account will be blocked. Share OTP immediately at bit.ly/sbi-kyc", "[expected: scam_message]"),
    ("We are hiring a Python developer, 3 years exp, salary 12 LPA, apply at careers.company.com", "[expected: genuine_job]"),
    ("You have won KBC lottery Rs 25 Lakh! Contact agent at 9800001111. Keep confidential!", "[expected: lottery_scam]"),
    ("Invest Rs 10000 earn Rs 50000 guaranteed returns daily profit crypto trading bot", "[expected: investment_scam]"),
    ("Hi I saw your profile you are beautiful I am US Army soldier can we be friends", "[expected: romance_scam]"),
    ("Dear Beneficiary, claim your $2M inheritance fund, send bank account to attorney", "[expected: scam_email]"),
    ("Please find attached the project report for review before Friday board meeting", "[expected: legitimate_email]"),
    ("Your Zomato order is on its way, estimated delivery 7:30 PM, order ID ZOM-12345", "[expected: legitimate_message]"),
    ("121knkjsabhdsa random gibberish", "[expected: low confidence on any class]"),
]

print("\n\n[TEST] Sanity Test Results:")
print("-" * 70)
for text, expected in test_cases:
    processed  = preprocess(text)
    pred       = pipeline.predict([processed])[0]
    proba      = pipeline.predict_proba([processed])[0]
    confidence = round(float(max(proba)) * 100, 1)
    print(f"INPUT: {text[:60]}...")
    print(f"  Predicted : {pred}  (confidence: {confidence}%)  Expected: {expected}")
    print()

print("[DONE] Training complete! Model ready for the Flask API.")
