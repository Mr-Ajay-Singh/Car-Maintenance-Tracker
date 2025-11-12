# Psoriasis Tracker - Product Requirements Document

## 🧩 1. App Overview

### App Name (suggestions):
- PsoriasisCare
- FlareTrack
- PsoriLog
- DermaTrack

### Goal:
Help users track, analyse, and manage their psoriasis symptoms, triggers, and treatments — and get AI-powered insights to improve skin health.

---

## 🧱 2. Core Features (MVP)

### ✅ Daily Symptom Tracker
- **Track:**
  - Flare intensity (1–10 scale)
  - Itching, redness, pain, scaling
  - Affected body areas (with body map UI or dropdowns)
  - Photos upload (compare progress over time)
  - Notes (mood, triggers, stress, weather)

### ✅ Trigger Tracker
- **Users can log:**
  - Diet (food categories)
  - Weather (auto-detect via location)
  - Stress levels (slider)
  - Sleep quality
  - Skincare products used
  - Medications taken
- **App shows correlation like:**
  - "Your flares increase when sleep < 6 hrs and humidity < 30%."

### ✅ Treatment Tracker
- Track medications (topical/oral)
- Phototherapy sessions
- Moisturisers and creams used
- Dosage + reminders
- Treatment effectiveness rating

### ✅ Photo Journal (Gallery)
- Date-wise images to visually monitor skin changes
- Optional AI progress insights:
  - "Redness decreased by 25% compared to last week."

### ✅ Reports & Insights
- **Weekly/Monthly summaries:**
  - Flare trends
  - Common triggers
  - Treatment success rates
  - Exportable report (PDF) for dermatologists

### ✅ Reminders
- Medicine reminders
- Moisturising reminders
- Follow-up appointment reminders

---

## 💎 3. Premium / Monetisation Features (Low Effort, High Value)

| Feature | Description | Monetisation Model |
|---------|-------------|-------------------|
| AI Flare Detection | Analyse uploaded photos and detect severity level automatically | Subscription / One-time unlock |
| Weather-based Flare Alerts | Get notified if local weather may trigger a flare | Subscription |
| Export Reports | PDF reports for doctors | Free users get 1/month, Premium unlimited |
| Trigger Correlation Insights | AI shows top 3 triggers based on data | Premium |
| Data Sync + Cloud Backup | Sync data between devices | Premium |
| Custom Skincare Routine Builder | Track routine and reminders | Premium |

---

## 🧠 4. Advanced / AI Features (Phase 2)

- **AI Image Analysis:**
  - Detect psoriasis severity (mild/moderate/severe) using ML model

- **AI Suggestions:**
  - Suggest routines like: "Based on your last 30 days, moisturising twice daily reduces flare frequency."

- **Chat Assistant:**
  - Provide personalised guidance and FAQ support

---

## 📊 5. Database Design (Simplified)

### Tables / Collections:

1. **users**
   - id, name, email, premium_status

2. **symptom_logs**
   - userId, date, intensity, itching, pain, redness, areas, notes

3. **triggers**
   - userId, date, food, stress, weather, sleep

4. **treatments**
   - userId, name, dosage, start_date, end_date, effectiveness

5. **photos**
   - userId, date, image_url, body_area

6. **reminders**
   - type, time, message

---

## 📋 Development Notes

This document serves as the single source of truth for the Psoriasis Tracker application requirements. All features should be developed according to these specifications, with MVP features taking priority before Phase 2 advanced features.
