# AGENTS.md — UFUK (Horizon) Constitution

## 1. North Star
**Mission:** Build a digital "huzur" (serenity) anchor. A single-screen, ambient-first Flutter app that connects users to prayer times and spiritual content with zero friction and premium aesthetics.
**Motto:** "Calmness over Clutter."

---

## 2. Constraints & Tech Stack
**Strict Adherence Required:**
- **Framework:** Flutter (Stable channel).
- **Language:** Dart 3.x (Use Records/Patterns).
- **Key Packages:**
  - `dio` (Networking)
  - `hive` (Local NoSQL Cache)
  - `geolocator` (Location)
  - `flutter_animate` (UI Transitions)
  - `ValueNotifier` (State Management - Keep it simple!)

---

## 3. Coding Conventions
- **Clean Architecture:** Strict separation of `presentation` (UI), `domain` (Logic), and `data` (Repos).
- **Glassmorphism:** Use `BackdropFilter` sparingly (only on Cards). Do NOT blur the full screen.
- **Null Safety:** Strict. No `!` unless absolutely guaranteed.
- **Async Pattern:** Favor `Future` and `Stream` builders where appropriate, but prefer initializing critical data (like cache) *before* `runApp` for instant start.
- **Style:**
  - File names: `snake_case.dart`
  - Classes: `PascalCase`
  - Variables: `camelCase`
  - **Linter:** `flutter_lints` (strict).

---

## 4. Operational Rules (The "Agent Protocol")
1.  **Safety First:** NEVER run destructive commands (`rm -rf`, `flutter clean` without backup) without explicit user approval.
2.  **Plan Before Action:** If a request involves editing >1 file, you **MUST** generate an `implementation_plan.md` artifact first.
3.  **Documentation:**
    - Update `PROGRESS.md` after *every* significant completed task.
    - Check off items in `task.md`.
4.  **Verification:**
    - Always verify "Happy Path" (it works).
    - Always verify "Offline Path" (it works without net).
    - Always verify "No Permission Path" (it falls back gracefully).

---

## 5. Implementation Phases
**Phase 1: Foundation (Engine)**
- Project Init, Assets, Theme.
- Data Layer: Hive + Dio setup.
- Domain: Location logic + Prayer Times calculation.

**Phase 2: Atmosphere (Vibe)**
- Ambient Background Engine (Segments).
- Glassmorphism Design Tokens.
- The Single Stack (UI Skeleton).

**Phase 3: Features & Flow**
- Hero Countdown Logic.
- Carousel Content (Ayet/Hadith).
- Settings & Local Toggles.

**Phase 4: Polish & Verify**
- Offline Mode Verification.
- Accessibility (Text Scale, High Contrast).
- Share Module.

---

## 6. Self-Correction
If you get stuck or an API fails:
1.  Check `TechDesign.md` for the approved fallback strategy.
2.  If the strategy fails, asking the user is better than guessing.
