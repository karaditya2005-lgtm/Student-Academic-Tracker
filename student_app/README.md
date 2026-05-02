# EduTrack — Student Performance App

A full-featured Flutter app for student academic tracking with AI tutoring.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 Register | Create account with name, email, class, roll no., school |
| 🪪 Auto UID | Unique Student UID (e.g. `STU-A3B9F1C2`) generated on register |
| 🔑 Login | Login via Email+Password OR Student UID |
| 📊 Dashboard | Visual performance overview with bar charts, grades, suggestions |
| 📝 Input Data | Enter marks per subject, study hours slider, attendance slider |
| 🏫 Digital ID | Full ID card with UID display + one-tap copy |
| 🤖 AI Chatbot | Claude-powered study tutor with chat history |

---

## 🚀 Setup Instructions

### 1. Prerequisites
- Flutter SDK ≥ 3.0.0 installed
- Android Studio / VS Code with Flutter plugin
- A device or emulator

### 2. Create the Project
```bash
flutter create student_app
cd student_app
```

### 3. Replace Files
Copy all files from this package into your `student_app/` folder:
- Replace `pubspec.yaml`
- Replace `lib/main.dart`
- Copy all files in `lib/models/`, `lib/services/`, `lib/screens/`

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Setup AI Chatbot (Optional but Recommended)
1. Get a free API key from https://console.anthropic.com
2. Open `lib/screens/chatbot_screen.dart`
3. Replace `YOUR_ANTHROPIC_API_KEY_HERE` with your actual key:
```dart
static const _apiKey = 'sk-ant-api03-...your-key...';
```

> ⚠️ For production, never hardcode API keys. Use `flutter_dotenv` or a backend proxy.

### 6. Run the App
```bash
flutter run
```

---

## 📁 File Structure

```
lib/
├── main.dart                    ← App entry + Splash screen
├── models/
│   ├── user_model.dart          ← User data model
│   └── performance_model.dart  ← Marks, grades, suggestions
├── services/
│   ├── auth_service.dart        ← Register, login, storage (SharedPreferences)
│   └── theme.dart               ← App colors, fonts, theme
└── screens/
    ├── login_screen.dart        ← Login with tabs (Email | UID)
    ├── register_screen.dart     ← Registration form
    ├── home_screen.dart         ← Main app shell with bottom nav
    ├── dashboard_tab.dart       ← Performance overview + charts
    ├── input_performance_tab.dart ← Add results/hours/attendance
    ├── digital_id_screen.dart   ← Digital ID card with UID
    └── chatbot_screen.dart      ← AI study tutor chat
```

---

## 🎨 Design Choices
- **Font**: Poppins (Google Fonts)
- **Primary Color**: Indigo `#4F46E5`
- **Charts**: `fl_chart` package (bar chart per subject)
- **Storage**: `shared_preferences` (local, no internet needed except chatbot)
- **UID Format**: `STU-XXXXXXXX` (uppercase hex)

---

## 📦 Dependencies Used

```yaml
shared_preferences: ^2.2.2   # Local data storage
uuid: ^4.3.3                 # UID generation
fl_chart: ^0.68.0            # Bar charts
google_fonts: ^6.1.0         # Poppins font
http: ^1.2.0                 # API calls for chatbot
intl: ^0.19.0                # Date formatting
```

---

## 🔒 Data & Privacy
All data is stored **locally on the device** using `SharedPreferences`. No data is sent to any server (except chatbot messages to Claude API if configured).
