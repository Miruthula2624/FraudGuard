import csv
import random
import os

# Base path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_FILE = os.path.join(BASE_DIR, "training_data.csv")

# Templates for data generation
templates = {
    "genuine_job": [
        "Hiring {role} at {company}. Requirements: {skills}, {exp} years experience. Location: {loc}. Salary: {sal}. Apply at careers.{company_clear}.com",
        "Opening for {role} in {loc}. We need someone with expertise in {skills}. {exp}+ years required. Competitive {sal} offered. Join our {team} team.",
        "Looking for an experienced {role} to join {company}. Must have {skills}. Experience level: {exp} years. Benefits: {ben}. Remote and hybrid options available.",
        "Exciting opportunity for {role} at {company}. Key skills: {skills}. Base: {loc}. Salary: {sal}. Send your CV to hr@{company_clear}.in",
        "We are expanding our {team} division. Hiring {role} with {exp} years of background in {skills}. Package: {sal}. Official website for applications."
    ],
    "fake_job": [
        "EARN {money} PER DAY WORKING FROM HOME! No {req} needed! Just {time} hours daily! WhatsApp {phone}. Limited slots!",
        "Urgent! Work from home {role_scam}. Daily payment {money}. No investment. No target. WhatsApp only: {phone}",
        "Online {role_scam} for students and housewives. Earn {money} daily. Join our Telegram group. 100% job guarantee.",
        "Work from phone {role_scam}. Earn {money} weekly. No interview. Direct selection. Call HR: {phone}",
        "AMAZON review job! Earn {money} per review. No boss. Registration fee {fee} refundable. Join instantly."
    ],
    "scam_message": [
        "ALERT: Your {bank} account will be blocked! Update KYC now: {url}. Offer valid today only.",
        "Congratulations! You won {money} in {brand} Lucky Draw! Claim here: {url}. Pay {fee} delivery.",
        "TRAI notice: Your number will be deactivated in {time} due to illegal activity. Call {phone} immediately.",
        "Your {app} account suspended. Verify identity: {url}. Respond now or account will be permanently deleted.",
        "Pending {type_s} of {money}. Verify bank details here: {url}. Final warning before forfeiture."
    ]
}

# Values for templates
roles = ["Software Engineer", "Data Scientist", "System Admin", "Product Manager", "UI Designer", "HR Specialist", "Sales Manager"]
companies = ["Infosys", "TCS", "Google", "HDFC", "Wipro", "Accenture", "Zomato", "Swiggy"]
skills_list = ["Python, Java", "React, Node.js", "SQL, AWS", "Machine Learning", "Excel, Tally", "Design Thinking", "Project Management"]
locs = ["Bangalore", "Mumbai", "Delhi", "Remote", "Pune", "Hyderabad", "Chennai"]
exps = ["2", "3", "5", "8", "1"]
sals = ["10-15 LPA", "18-25 LPA", "8-12 LPA", "Competitive", "Market Standard"]
bens = ["Health Insurance, PF", "ESOPs, Paid Leave", "Flexible Hours", "Meal Vouchers", "Annual Bonus"]
teams = ["Engineering", "Marketing", "Data", "Operations", "Sales", "Legal"]

money_vals = ["Rs 5000", "Rs 10000", "Rs 2000", "$500", "Rs 1 Lakh"]
reqs = ["Experience", "Degree", "Interview", "Qualification"]
times = ["2", "3", "1", "4"]
phones = ["9876543210", "8822334455", "7788990011", "9012345678"]
role_scams = ["Data Entry", "Form Filling", "SMS Sending", "Typing Work", "Ad Posting"]
fees = ["Rs 499", "Rs 999", "Rs 250", "Rs 1500"]

banks = ["SBI", "ICICI", "HDFC", "PNB", "Bank of Baroda"]
brands = ["Amazon", "Flipkart", "Jio", "Paytm", "Google"]
urls = ["bit.ly/update-now", "tinyurl.com/win-prize", "rb.gy/security-check", "shrt.url/alert"]
types_s = ["Refund", "Payment", "Lottery", "Cashback"]

# Collect existing data if any
existing_data = []
if os.path.exists(DATA_FILE):
    with open(DATA_FILE, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader, None)
        for row in reader:
            if row: existing_data.append(row)

# Generate new data
new_data = []
target_count = 1050
current_count = len(existing_data)

print(f"Current count: {current_count}. Generating {target_count - current_count} more...")

while current_count + len(new_data) < target_count:
    category = random.choice(list(templates.keys()))
    template = random.choice(templates[category])
    
    text = template.format(
        role=random.choice(roles),
        company=random.choice(companies),
        company_clear=random.choice(companies).lower(),
        skills=random.choice(skills_list),
        exp=random.choice(exps),
        loc=random.choice(locs),
        sal=random.choice(sals),
        ben=random.choice(bens),
        team=random.choice(teams),
        money=random.choice(money_vals),
        req=random.choice(reqs),
        time=random.choice(times),
        phone=random.choice(phones),
        role_scam=random.choice(role_scams),
        fee=random.choice(fees),
        bank=random.choice(banks),
        brand=random.choice(brands),
        url=random.choice(urls),
        app=random.choice(brands),
        type_s=random.choice(types_s)
    )
    new_data.append([text, category])

# Write all back
with open(DATA_FILE, "w", encoding="utf-8", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["text", "label"])
    writer.writerows(existing_data)
    writer.writerows(new_data)

print(f"Successfully updated {DATA_FILE} to {target_count} lines.")
