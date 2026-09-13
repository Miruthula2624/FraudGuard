USE job_scam_db;

-- Sample User (password is 'password123' hashed)
INSERT INTO users (fullname, email, password) VALUES 
('Anjali Sharma', 'anjali@example.com', '$2a$10$Xm5X6E7G2.j0Y7Xo2/7pueKz6J.v6n0.8M4R5p.b7zG/2t/2/2.G.');

-- Sample Job History
INSERT INTO job_history (user_id, original_content, extracted_text, classification, scam_indicators, confidence_score) VALUES 
(1, 'Urgent hiring for Data Entry! No experience needed. High salary of $5000/week. WhatsApp us at +123456789. Send processing fee of $50.', 
'Urgent hiring for Data Entry! No experience needed. High salary of $5000/week. WhatsApp us at +123456789. Send processing fee of $50.', 
'❌ Scam / Fake Job', '["Urgent/Threatening language: urgent", "Requests for money/fees: payment", "Common scam phrases: work from home, high salary, no experience needed, whatsapp us"]', 85),

(1, 'We are looking for a Software Engineer at Microsoft. Please apply through our official careers portal at microsoft.com/careers.', 
'We are looking for a Software Engineer at Microsoft. Please apply through our official careers portal at microsoft.com/careers.', 
'✅ Genuine Job', '[]', 5);
