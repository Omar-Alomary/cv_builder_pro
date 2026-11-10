

# 📄 CV Builder Pro

**A comprehensive, fully responsive Flutter application for building professional resumes.**
*Supports full Arabic (RTL) and English (LTR) localization, AI-powered ATS checking, and high-quality PDF export.*

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)]()

</div>

---

## 📌 Overview

**CV Builder Pro** is a state-of-the-art resume builder built with Flutter. It empowers users to create visually stunning, ATS-friendly resumes effortlessly. With a focus on user experience and performance, the app offers real-time previews, seamless template switching, and intelligent data extraction from existing PDFs or JSON files.

## ✨ Key Features

- 📱 **Fully Responsive UI:** Adapts perfectly to mobile phones, tablets, and desktop screens (320px to 1920px+).
- 🌍 **Bilingual Support:** Instant switching between Arabic (RTL) and English (LTR) with built-in custom fonts (Cairo & Poppins).
- 🌓 **Dark & Light Mode:** A modern, eye-friendly design supporting both themes seamlessly.
- 🎨 **10 Professional Templates:** Includes 5 Arabic and 5 English templates (Modern, Classic, Business, Technical, and ATS-optimized).
- 🎯 **Smart ATS Checker:** Analyzes the resume, provides a score out of 100, and gives actionable suggestions to pass Applicant Tracking Systems.
- 📥 **Resume Import:** Extracts contact info, education, and experience from existing PDF, JSON, or TXT files.
- 💾 **Auto-Save:** Automatically saves progress to prevent data loss.
- 📄 **High-Quality PDF Export:** Generates precise PDFs with full support for Arabic ligatures and complex text layouts.
- 🔒 **Code Obfuscation:** Production builds are secured against reverse engineering.

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **GetX** | State management, dependency injection, and routing |
| **GetStorage** | Fast, lightweight local key-value storage |
| **pdf & printing** | PDF generation and native printing |
| **file_picker & image_picker** | Native file and image selection |
| **share_plus** | Native file sharing |

## 📂 Project Architecture

The project follows a **Feature-First Architecture** for maximum scalability and maintainability:

```text
lib/
├── app/               # Global app settings, themes, and routes
├── core/              # Constants, utilities, and core services
├── data/              # Models, JSON serializers, and repositories
├── controllers/       # GetX Controllers (State Management)
├── translations/      # Localization files (AR / EN)
├── shared_widgets/    # Reusable UI components (Buttons, Cards, etc.)
└── features/          # Feature-specific UI modules
    ├── home/          # Dashboard and recent resumes
    ├── templates/     # Template gallery and previews
    ├── resume_builder/# Multi-step form and customization
    ├── ats_checker/   # ATS analysis and suggestions
    ├── import_resume/ # File import and parsing
    └── settings/      # App preferences and profile
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.10.8)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode / VS Code

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Omar-Alomary/cv_builder_pro.git
   cd cv_builder_pro
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Analyze code for errors:**
   ```bash
   flutter analyze
   ```

4. **Run the app (Debug mode):**
   ```bash
   flutter run
   ```

5. **Build a secure, obfuscated Release APK:**
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
   ```

## 👨‍💻 Author

**Omar Al-Omari**
*   Flutter Developer
*   📍 Sana'a, Yemen

## 📝 License

This project is intended for personal and commercial use. All rights reserved © 2026 Omar Al-Omari.


