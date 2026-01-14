# PRD — UFUK (Horizon)

**Version:** 1.0 (MVP)  
**Status:** Approved  
**Language:** Turkish (TR-First), L10n-ready structure  

---

## 1. Product Vision (North Star)
UFUK is a digital "huzur" (serenity) anchor. It is a minimalist, single-screen Ramadan & prayer-time companion that emphasizes ambient calmness over data density. It requires near-zero user input and adapts its atmosphere to the time of day and spiritual season.

**Core Philosophy:**
- **Ambient-First:** Visuals and atmosphere > Utilities.
- **Zero-Friction:** No login, no onboarding walls, auto-location (with smart fallback).
- **Privacy-Centric:** No user tracking, no account requirement.

---

## 2. Target User
- **Profile:** Mobile users seeking spiritual connection without the visual clutter of traditional "religious apps."
- **Needs:** Quick access to Iftar/Prayer times, daily spiritual inspiration (Ayet/Hadith), and a calming visual experience.
- **Preferences:** Values modern design (Glassmorphism), simplicity, and privacy.

---

## 3. Functional Requirements (MVP)

### 3.1 Location & Time Engine
**Source of Truth:**
- **API:** Aladhan API (Free, standard calculation methods).
- **Location Strategy:** 
  1. Request device location.
  2. **Fallback:** If denied or error, default to **Istanbul** (Europe/Istanbul TZ) immediately. Show subtle CTA: "Konumu aç / Şehir seç" to refine.
- **Caching & Offline:**
  - **Strategy:** "Offline First." Cache 30 days of prayer times for the active location.
  - **Behavior:** App loads instantly from cache. Background refresh when network is available.

### 3.2 Dynamic Atmosphere (The "Vibe")
**Behavior:**
- Background is a fluid, animated gradient that changes based on the calculated "Time Segment" (e.g., Early Morning, Noon, Sunset, Night).
- **Ramadan Mode:**
  - Logic: Active during Hijri Month 9 OR via manual "Fasting Mode" toggle (future).
  - Visuals: Warmer, more spiritual palette (Gold, Amber, Deep Teal) vs. the standard "Fresh/Cool" palette of normal days.
  - **Accessibility:** 
    - **Reduce Motion:** If system setting is on, stop animations; keep static gradient.

### 3.3 Hero Countdown (Smart Logic)
The prominent central element displaying "Time Remaining."

**Priority Logic:**
1. **Ramadan Mode:**
   - **Pre-Iftar:** If time is > Sahur & < Iftar → Show **"İftara Kalan"**.
   - **Pre-Sahur:** If time is > Isha & < Imsak → Show **"Sahura Kalan"**.
   - **Else:** logic falls through to Normal.
2. **Normal Mode:**
   - Always show **"Next Prayer"** (e.g., "İkindi Vakti'ne Kalan").

### 3.4 Glass Carousel (Content Stream)
Horizontal scrolling cards at the bottom. Glassmorphism style (blur + translucency).

**Card Types:**
1. **Prayer Times List:** Vertical compact list of the day's times.
2. **Daily Wisdom (Seeded by Date):**
   - **Ayet:** Verse of the Day.
   - **Hadith:** Short Prophetic saying.
   - **(Nice-to-Have) Tip:** Short spiritual/practical tip (e.g., hydration).
   - **Rotation:** Updates daily at midnight. Does NOT rotate on every app launch (preserves calmness).
3. **Menu/Settings:** Minimal entry point for local preferences.

### 3.5 Share Module
**Trigger:** User taps a Share icon on a content card (Ayet/Hadith).
**Output:**
- **Format:** 9:16 Vertical Image (Story ready).
- **Design:** High-quality background match, typography centered.
- **Branding:** Minimal text watermark "Via UFUK". No QR code in MVP.

### 3.6 Settings (Local Only)
- **Location:** Toggle/Selector.
- **Accessibility:**
  - **High Contrast:** Increases card opacity, reduces blur, maximizes text contrast.
- **Notification Toggles:** (Phase 2, purely local logic for MVP).

### 3.7 Sonic Atmosphere (Phase 5)
**Concept:**
- **Goal:** Deepen the "huzur" (serenity) anchor through auditory ambience. Audio facilitates a trance-like focus (Khushoo).
- **Assets:**
  - `ney.mp3`: Essential spiritual instrument (Reed flute).
  - `nature.mp3`: Context-aware background (e.g., Night crickets, Wind).
**Controls:**
- **Glass Player:** Minimal pill-shaped toggle on the Home Screen (Layer 1).
- **States:** Play / Pause / Volume Slider (Hidden until long press or tap).
**Behavior (Lifecycle Aware):**
- **Background:** Audio MUST pause immediately when app enters background (minimize battery/annoyance).
- **Resume:** Resumes only if it was playing before backgrounding.
- **Ramadan Mode:** Auto-play soft `ney.mp3` during Iftar countdown (last 10 mins) if enabled.

### 3.8 AI Daily Summary (Phase 5.5)
**Concept:**
- **Goal:** Provide a unique, spiritually grounding "Greeting" that feels alive and aware of the moment.
- **Mechanism:** Generative AI (Gemini) creates a 1-2 sentence reflection based on:
  - **Time:** (e.g., "Dawn is breaking...")
  - **Season:** (e.g., "On this cold winter morning...")
  - **Spiritual Context:** (e.g., "As we approach Maghrib...")
- **Caching & Efficiency:**
  - **Frequency:** Generated ONCE per day (after midnight reset).
  - **Offline/Fallback:** If API fails or offline, show pre-written "Huzur" affirmations from local JSON.
  - **Storage:** Persisted in Hive to prevent re-fetching on app restart.
**UI Integration:**
- **Placement:** A special "Featured Card" in the Glass Carousel (Index 0).
- **Style:** Distinct typography (Italicized/Serif) to denote "Voice of the App".

---

## 4. Monetization (Post-MVP Readiness)
*Not visible in MVP launch, but code structure must support it.*

- **Format:** Native Ads strictly. Designed to look like a Glass Card in the carousel.
- **Rules:**
  - No ads on first screen render (user must swipe).
  - **No-Go Zones:** Ads are programmatically disabled 15 mins before Iftar (and 10 mins before Imsak in Ramadan).

---

## 5. Non-Functional Requirements (NFR)

### 5.1 Usability & Accessibility
- **Font Scaling:** UI must adapt to system font size changes.
- **Motion:** Respect system "Reduce Motion" preference.
- **Contrast:** Default is "Soft/Aesthetic". "High Contrast" mode is a functional requirement for accessibility.

### 5.2 Performance
- **Frame Rate:** Stable 60fps animations.
- **Startup Time:** < 500ms (Render cached content immediately).

### 5.3 Privacy
- **Data:** No PII collected. Location data stays on device (used only for API call).

### 5.4 Localization (i18n)
- **MVP:** Turkish (TR) only.
- **Code:** Strings must be externalized (e.g., `.arb` files or standard l10n classes) to allow easy English addition later without refactoring user stories.

---

## 6. User Stories (Sample)

1. **The Instant Glance:** *As a user, I open the app and immediately know how long is left until Iftar without tapping buttons, even if I have no internet.*
2. **The Spiritual Share:** *As a user, I find a beautiful Hadith in the carousel and share it to my Instagram Story with one tap, looking professional and clean.*
3. **The Night Reader:** *As a user checking Imsak time in the dark, the interface is dim and legible, not blinding white.*

---

## 7. Technical Implementation Strategy

### 7.1 Architecture
- **Framework:** Flutter (Stable).
- **State Management:** ValueNotifier / ChangeNotifier (Keep it simple).
- **Local Storage:** Hive or SharedPreferences (for simple settings + cached JSON).

### 7.2 Data Models
- `PrayerTimesCache`: { cityId, date, timesJson }
- `DailyContent`: { date, ayetSource, ayetText, hadithSource, hadithText }
- `UserSettings`: { locationOverride, isHighContrast, etc. }

### 7.3 Assets
- **Fonts:** Premium, readable sans-serif (e.g., Google Fonts: Outfit or Plus Jakarta Sans).
- **Icons:** Minimalist line icons (Lucide or similar).

---

## 8. UX/UI Polish (Phase 6)

### 8.1 Aurora Atmosphere (Phase 6.1)
**Goal:** Replace the static dark background with a living, breathing gradient that transitions smoothly based on the `TimeSegment`.

- **State Mapping:**
  | TimeSegment | Gradient Colors |
  |---|---|
  | Dawn/Sahur | Deep Navy → Soft Indigo |
  | Morning | Warm Peach → Light Sky Blue |
  | Noon | Bright Sky Blue → White |
  | Afternoon | Golden Yellow → Orange |
  | Sunset/Maghrib | Deep Orange → Magenta |
  | Night/Isha | Dark Purple → Near Black |

- **Animation:** Use `AnimatedContainer` with implicit `Curves.easeInOut` transitions (duration ~2-3 seconds for serene feel).
- **Constraint:** No heavy shaders. Must maintain 60fps on mid-range devices.

### 8.2 Liquid Interactions (Phase 6.2)
**Goal:** Add micro-interactions to make the app feel responsive and fluid.

- **Entrance Animations:**
  - Carousel cards: Staggered `SlideTransition` + `FadeTransition` using `flutter_animate`.
  - Hero Clock: Subtle scale-up on first load.
- **Touch Feedback:**
  - All interactive buttons (Play, Share, Refresh) use a "Bouncy" scale effect (`scaleX: 0.95` on press, then `1.0` on release with `Curves.elasticOut`).
  - Haptic Feedback (`HapticFeedback.lightImpact()`) on every tap.
- **Package:** `flutter_animate` for declarative, clean animation logic.

---

## 9. Settings & Navigation (Phase 7)

### 9.1 Architecture Shift
**Goal:** Transition from Single-Page App to Multi-Page Architecture.

- **Navigation Strategy:** Simple `Navigator.push` / `pop` (No need for `GoRouter` in MVP).
- **Entry Point:** A new "Settings" icon button in the top-left of `HomeScreen` (next to `GlassPlayer`).

### 9.2 SettingsScreen Features
- **Notification Toggles:** Adhan reminder (on/off), Push Notifications (on/off).
- **Location Management:** Display current location, "Reset/Change Location" button.
- **Privacy & About:** Link to Privacy Policy, App Credits (Sources, Developer Info).
- **Future-Proofing (Disabled in MVP):**
  - Theme Override (Light/Dark/System).
  - Language Override (TR/EN).

### 9.3 Design Language
- **Consistency:** All UI elements in `SettingsScreen` must use `GlassTokens` (blur, opacity, border-radius).
- **Layout:** Simple vertically scrollable list with grouped sections (e.g., "Notifications", "Location", "About").

