# Respiro 🧘‍♂️💨

**Respiro (Micro-Breathing & Sensory Focus)** is a premium, 100% self-contained, offline-first breathing and stress-relief utility app built with Flutter. Acting as "first aid for the mind," the application is designed to be opened instantly during moments of high stress or anxiety, operating with **exactly $0.00 in backend costs**.

---

## 🏛️ Core Philosophy & Design

Respiro provides immediate, highly polished physical and visual guidance to calm the nervous system during stress or panic attacks, running completely privately without standard sign-up hurdles.

### Premium Twilight Visual System
- **Theme**: Deep glowing twilight dark-first theme (Midnight Navy `#0A0E1A`, Twilight Indigo `#121829`) accented by breathing Mint (`#64DFDF`) and Solar Pink (`#FFB3C1`).
- **Concentric Canvas Ripples**: Custom-drawn, high-performance canvas paints (`BreathingPainter`) that expand and contract organically to guide inhalation, holding, and exhalation.
- **Equalizer Micro-animations**: Delicate vertical bar physics that animate dynamically when offline sound loops are active, providing visual focus feedback.

---

## 🌟 Features

### 1. Classical Breathing Techniques
- **Box Breathing (4-4-4-4)**: Equal ratios to restore neural balance.
- **4-7-8 Technique**: Dr. Weil's natural tranquilizer, ideal for sleep.
- **Cardiac Coherence (5-5)**: Harmonizes heart rates and reduces cortisol.

### 2. Tactile Guided Vibration (Zero-Eyes Breathing)
- Custom-paced haptic vibration flows using the `vibration` plugin:
  - **Inhalation**: Gentle, continuous micro-vibrations.
  - **Holds**: Still, peaceful silence.
  - **Exhalation**: Calm, slower pulsing rhythms.
- Allows users to close their eyes and fully guide their session solely by physical touch.

### 3. High-Fidelity Focus Loops
- A gapless offline sound mixer utilizing the `just_audio` package.
- Bundles loops directly inside `assets/sounds/`:
  - **Brown Noise** (`brown_noise.mp3`)
  - **Calm Ocean** (`ocean.mp3`)
  - **Forest Rain** (`rain.mp3`)
  - **Pink Noise** (`pink_noise.mp3`)
- Real-time slider controlling background sound volume.

### 4. Calm Analytics (Local SQLite Logs)
- Tracks completed calming cycles and calculates total calm minutes.
- Evaluates successive practice dates to reward daily calming streaks.
- Displays logs in a beautiful glassmorphic history list.

### 5. Custom Control Center
- Dynamic real-time bilingual English/Spanish localization.
- Safety safety valves: Wipes local database logs in a single tap.
- Direct external link triggers supporting indie development donation sheets.

---

## 🗄️ Database Mappings (SQLite)

Data is saved locally inside `respiro.db` via a singleton `DatabaseService` class.

### Table Schema: `session_logs`
- `id` (VARCHAR/TEXT, PRIMARY KEY): UUID v4 String.
- `patternId` (VARCHAR): Mapped exercise technique (e.g. `'box_breathing'`).
- `durationSeconds` (INTEGER): Total practice time completed in seconds.
- `timestamp` (VARCHAR): ISO-8601 Date String representation.

---

## 🚀 Building & Running

### Prerequisites
- Flutter SDK (Channel stable)
- Android SDK (minSdk 21)

### Steps
1. Navigate to the project directory:
   ```bash
   cd respiro
   ```
2. Fetch package dependencies:
   ```bash
   flutter pub get
   ```
3. Generate localized assets:
   ```bash
   flutter gen-l10n
   ```
4. Build or launch on active emulation targets:
   ```bash
   flutter run
   ```

---

## 🔒 Absolute Privacy Guarantee
Respiro collects **no telemetry**, **no diagnostic profiles**, and **no cloud analytics**. All statistics, daily streaks, written records, and sound preferences stay permanently sandboxed in your device's local storage.
