# 🚆 RRB NTPC Study Routine & Persistent Alarm Tracker

একটি আধুনিক, সুরক্ষিত এবং চমৎকার অ্যানিমেশন যুক্ত **RRB NTPC Study & Routine Companion** মোবাইল অ্যাপ্লিকেশন।

> **লক্ষ্য:** এই অ্যাপটি আপনার ল্যাপটপে ভারি কোনো সফটওয়্যার (যেমন Android Studio বা Flutter SDK) ছাড়াই **GitHub Actions ক্লাউডে সম্পূর্ণ বিনামূল্যে APK বিল্ড হবে** এবং সরাসরি আপনার মোবাইলে ডাউনলোড করে ব্যবহার করা যাবে।

---

## ✨ অ্যাপটির মূল বৈশিষ্ট্যসমূহ (Key Features)

1. **🚀 GitHub Actions Cloud Build (ল্যাপটপে বিল্ড করার দরকার নেই):**
   - সম্পূর্ণ প্রজেক্টটি গিটহাবে আপলোড করার সাথে সাথে GitHub-এর শক্তিশালী ক্লাউড সার্ভার স্বয়ংক্রিয়ভাবে আপনার জন্য **Android Release APK (`RRB_NTPC_Routine_App.apk`)** তৈরি করে দেবে।

2. **⏰ Persistent Alarm & কাস্টম সাউন্ড (অ্যালার্মের মতো বাজবে):**
   - সাধারণ নোটিফিকেশনের মতো একবার বেজে থেমে যাবে না; **যতক্ষণ না আপনি নিজে অ্যাপে ঢুকে বা নোটিফিকেশনে "বন্ধ করুন" বাটনে চাপবেন, ততক্ষণ অ্যালার্ম বাজতেই থাকবে**।
   - অ্যাপটির নিজস্ব এনার্জেটিক কাস্টম ওয়েক-আপ অ্যালার্ম সাউন্ড (`rrb_alarm.wav`) যুক্ত রয়েছে।
   - ঘুম বা আলসেমি ভাঙার জন্য এতে রয়েছে **"Wake-up NTPC Math Challenge"** (অঙ্ক সমাধান করে অ্যালার্ম বন্ধ করার অপশন)।

3. **🔒 বায়োমেট্রিক ও পিন সিকিউরিটি (PIN & Fingerprint Lock):**
   - ফিঙ্গারপ্রিন্ট (Fingerprint) দিয়ে এক স্পর্শে অ্যাপ আনলক করার সুবিধা।
   - ৪-সংখ্যার সিকিউরিটি পিন (PIN) কিপ্যাড এবং ভুল পিন দিলে চমৎকার শেক (Shake) অ্যানিমেশন।

4. **📚 RRB NTPC Daily Study Tracker (আজ কী পড়লাম সংরক্ষণ):**
   - প্রতিদিনের পড়ার টপিক ও অধ্যায় স্টোর করার ডেডিকেটেড ডায়েরি।
   - বিষয়ভিত্তিক ট্র্যাকিং: **Mathematics, Reasoning, General Awareness / Current Affairs, General Science**।
   - পড়ার সময় (Duration), MCQ প্র্যাকটিসের সংখ্যা, এবং গুরুত্বপূর্ণ ফর্মুলা/নোট লিখে রাখার ব্যবস্থা।
   - স্পেসড রিভিশন (Spaced Revision) ট্র্যাকার।

5. **🎨 Modern UI & Smooth Animations:**
   - আধুনিক ডার্ক থিম, গ্লাস মরফিজম কার্ড এবং গ্রেডিয়েন্ট অ্যাকসেন্ট।
   - পালসিং রিং অ্যানিমেশন (`AnimatedPulseRing`), ট্রেনের গতিময় প্রতীক এবং ডেইলি স্টাডি স্ট্রিক ফায়ার (🔥 Streak)।

---

## 🛠️ GitHub Actions থেকে কীভাবে ১-ক্লিকে APK বিল্ড ও ডাউনলোড করবেন

আপনার কম্পিউটারে কোনো Flutter বা Android Studio লাগবে না। নিচের সহজ ধাপগুলো অনুসরণ করুন:

### ধাপ ১: GitHub-এ একটি নতুন Repository তৈরি করুন
1. [github.com](https://github.com) এ লগইন করুন।
2. উপরে ডানদিকের **`+`** আইকনে ক্লিক করে **"New repository"** সিলেক্ট করুন।
3. রিপোজিটরির নাম দিন (যেমন: `rrb-ntpc-routine-app`)।
4. রিপোজিটরিটি **Public** বা **Private** রেখে **"Create repository"** বাটনে ক্লিক করুন।

### ধাপ ২: ফাইলগুলো GitHub-এ আপলোড করুন
- **সহজ উপায় (ব্রাউজার দিয়ে):**
  1. আপনার নতুন রিপোজিটরির পেজে গিয়ে **"uploading an existing file"** লিঙ্কে ক্লিক করুন।
  2. আপনার কম্পিউটারের এই লোকেশনের সব ফাইল ও ফোল্ডার সিলেক্ট করে ড্র্যাগ-অ্যান্ড-ড্রপ করুন:
     `D:\projects\rrb_ntpc_routine_app`
  3. নিচে **"Commit changes"** বাটনে ক্লিক করুন।
  *(উল্লেখ্য: `.github/workflows/build_apk.yml` ফাইলটি অবশ্যই রিপোজিটরির রুটে যেন থাকে।)*

### ধাপ ৩: GitHub Actions-এ স্বয়ংক্রিয় APK বিল্ড
1. আপনার রিপোজিটরির উপরের মেনু থেকে **"Actions"** ট্যাবে ক্লিক করুন।
2. দেখতে পাবেন **"Build & Release RRB NTPC Routine APK"** ওয়ার্কফ্লোটি স্বয়ংক্রিয়ভাবে চলতে শুরু করেছে (হলুদ রঙের আইকন)।
3. আনুমানিক ২-৩ মিনিট পর এটি সফলভাবে সম্পন্ন হয়ে সবুজ টিকচিহ্ন (✅) দেখাবে।

### ধাপ ৪: APK ডাউনলোড করুন এবং ফোনে ইনস্টল করুন
1. সবুজ টিকচিহ্ন যুক্ত ওয়ার্কফ্লো রানের উপর ক্লিক করুন।
2. পেজের নিচের দিকে স্ক্রোল করে **"Artifacts"** সেকশনটি দেখতে পাবেন।
3. সেখানে থাকা **`RRB_NTPC_Routine_App`** এ ক্লিক করুন। সাথে সাথে আপনার প্রস্তুতকৃত অ্যান্ড্রয়েড APK ফাইলটি ডাউনলোড হয়ে যাবে!
4. ফাইলটি আপনার অ্যান্ড্রয়েড ফোনে নিয়ে ইনস্টল করে নিন এবং RRB NTPC প্রস্তুতির জন্য প্রতিদিনের রুটিন ও স্টাডি ট্র্যাকিং শুরু করুন!

---

## 📂 ফাইল স্ট্রাকচার

```text
rrb_ntpc_routine_app/
├── .github/
│   └── workflows/
│       └── build_apk.yml          # GitHub Actions CI/CD script
├── android/                       # Native Android configuration
│   ├── app/
│   │   ├── build.gradle           # Android build rules & desugaring
│   │   └── src/main/
│   │       ├── AndroidManifest.xml # WakeLock, FullScreen, Biometrics
│   │       ├── kotlin/.../MainActivity.kt # Biometric FlutterFragmentActivity
│   │       └── res/raw/rrb_alarm.wav      # Custom notification sound
├── assets/
│   ├── audio/rrb_alarm.wav        # Looping persistent alarm audio
│   └── icons/app_icon.png         # Modern app icon
├── lib/
│   ├── main.dart                  # App entrypoint & initial routing
│   ├── models/
│   │   ├── routine_item.dart      # Routine data model
│   │   └── study_log.dart         # RRB NTPC study log model
│   ├── screens/
│   │   ├── alarm_ringing_screen.dart # Looping persistent ringing UI
│   │   ├── auth_screen.dart / lock_screen.dart # PIN & Fingerprint UI
│   │   ├── home_screen.dart       # Dashboard & statistics
│   │   ├── routine_screen.dart    # Routine scheduler & alarm config
│   │   ├── settings_screen.dart   # Security & sound settings
│   │   └── study_log_screen.dart  # Daily study journal for NTPC
│   ├── services/
│   │   ├── alarm_service.dart     # Background notification & audio engine
│   │   ├── auth_service.dart      # Local_auth biometrics & pin check
│   │   └── storage_service.dart   # Offline SharedPreferences & streak
│   ├── theme/
│   │   └── app_theme.dart         # Material 3 Dark Theme
│   └── widgets/
│       ├── animated_pulse_ring.dart # Wave pulsing bell animation
│       ├── custom_pin_pad.dart      # Keypad with haptic feedback
│       ├── ntpc_countdown_card.dart # Motivation & streak card
│       └── study_stat_card.dart     # Metrics display
└── pubspec.yaml                   # Flutter dependencies
```
