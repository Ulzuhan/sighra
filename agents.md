# Agent Instructions & Lessons Learned (agents.md) 🧘‍♂️💨

This file acts as a knowledge repository and instruction guide for future AI agents working on **Respiro (Micro-Breathing & Sensory Focus)** and other offline-first stress-relief modules.

---

## 📳 1. Sensory Guided Vibration (Haptic Guides)

Guided haptic loops let users breathe with eyes closed, but vibration configurations must be carefully managed to avoid lints:

- **Null Safety in `hasVibrator()`**:
  - In recent `vibration` plugin versions, `Vibration.hasVibrator()` returns a non-nullable `Future<bool>`.
  - **Do NOT use `await Vibration.hasVibrator() ?? false`**—the analyzer flags this as a dead null-aware check (`dead_null_aware_expression`) and marks any downstream conditional branches as dead code. Use `if (await Vibration.hasVibrator())` directly.
- **Rhythmic Patterns**:
  - `Vibration.vibrate(pattern: [sleepMs, vibrateMs, sleepMs, vibrateMs], repeat: 0)` allows continuous looping.
  - To stop, always call `Vibration.cancel()` and track active vibration flags to prevent concurrent haptic overlaps.

---

## 🎵 2. Gapless Offline Sound Loops (`just_audio`)

For focus sounds that work 100% offline:

- **Looping Assets**:
  - Use `just_audio` which supports precise gapless asset loop rendering.
  - Set the loop mode explicitly via `player.setLoopMode(LoopMode.one)` and load assets locally from `setAsset('assets/sounds/track.mp3')`.
- **Defensive Error Handling**:
  - Always wrap audio loads in try-catch structures. During scaffolding, if actual large MP3 files are omitted to keep directory footprints lightweight, catching asset loading exceptions prevents system-level failures.

---

## 🎨 3. UI Styling & Material ThemeData Lints

- **`ThemeData.cardTheme` parameter**:
  - In `ThemeData`, the property `cardTheme` expects a type of `CardThemeData?`.
  - **Do NOT pass `CardTheme(...)`** (the widget class) directly into `ThemeData.cardTheme`. Pass `CardThemeData(...)` to avoid `argument_type_not_assignable` errors in modern Flutter.
- **Column / Row Alignments**:
  - Double-check alignments in Column/Row definitions. It is very easy to write `MainAxisSize.center` instead of `MainAxisAlignment.center` under pressure. Remember:
    - `MainAxisAlignment` holds `center`, `start`, `end`, `spaceBetween`.
    - `MainAxisSize` only has `min` and `max`.
- **Dynamic Equalizers**:
  - A beautiful visualizer can be built efficiently using single vertical bar widgets driven by an `AnimationController`. Map the controllers to the active ambient track state and use `repeat(reverse: true)` to get elegant bounce animations without adding high-weight media packages.

---

## 📈 4. Local Streak Metrics (SQLite)

- To evaluate user streaks in days without backend systems, fetch unique dates in `YYYY-MM-DD` string format using SQLite query filters:
  ```sql
  SELECT DISTINCT SUBSTR(timestamp, 1, 10) as practice_date FROM session_logs ORDER BY practice_date DESC
  ```
- Parse the resulting string dates in your provider to verify if the latest log occurs today or yesterday, incrementally counting successive calendar day gaps.
