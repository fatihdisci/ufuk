# TechDesign — UFUK (Horizon)
**Role:** Principal Mobile Architect  
**Version:** 1.1 (Engine Ready)  
**Ref:** `PRD-v1.0`

---

## 1. Technology Stack & Decision Records (ADR)

### 1.1 Core Framework
- **Flutter (Stable)**: Interaction consistency across iOS/Android.
- **Dart 3.x**: Leveraging Records and Pattern Matching for "Time Segment" logic.

### 1.2 Key Packages & Justification
| Feature | Package | Justification (Why?) |
| :--- | :--- | :--- |
| **Networking** | `dio` | **Better than `http`.** Native support for interceptors (essential for centralized error handling & retries), request cancellation, and simpler timeout configs. |
| **State Mgmt** | `ValueNotifier` + `Provider` (DI only) | **Minimalism.** The app is single-screen. BLoC/Riverpod introduces unnecessary boilerplate/cognitive load. We need simple reactive primitives binding specific UI components to their data sources. |
| **Local DB** | `hive` + `hive_flutter` | **Performance.** It's Synchronous (read) & NoSQL. Essential for "Instant Cold Start" where we render UI immediately from cache before the async engine boots. `shared_preferences` is too slow for complex objects (PrayerTimes). |
| **Location** | `geolocator` | Industry standard, handles permission flows gracefully. |
| **Animations** | `flutter_animate` | Declarative, chainable animations. vital for the "Atmosphere" transitions without writing complex `AnimationController` boilerplate. |
| **Glass** | Native `BackdropFilter` | **Performance Risk.** We will use `ClipRRect` + `BackdropFilter` but strictly limit the blur area to the Cards, NOT the full screen background (which is just a gradient). |

---

## 2. Architecture: "The Ambient Engine"

We follow a strict separation between the **Atmosphere Engine** (Logic) and the **Glass View** (UI).

### 2.1 Layered Architecture
```ascii
[ UI Layer (Widgets) ]
       ⬇ (Observes)
[ ViewModels / Controllers (ValueNotifiers) ]
       ⬇ (Calls)
[ Domain Layer (Engine / UseCases) ]
       ⬇ (Data Types)
[ Data Layer (Repositories / Sources) ]
```

### 2.2 Domain Logic (The Brain)
1.  **`AtmosphereEngine`**:
    *   **Input**: `DateTime.now()`, `PrayerTimes` (Today).
    *   **Output**: `CurrentSegment` enum (Sahur, Morning, Noon, Asr, Iftar, Isha, LateNight).
    *   **Logic**: Calculates the precise "State of the Sky".
2.  **`TimeDilationService`** (Countdown):
    *   **Input**: `RamadanMode` (bool), `CurrentSegment`.
    *   **Output**: `UsageFocus` (Next Prayer vs Iftar vs Sahur).
    *   Uses a `Timer.periodic(1 sec)` to update a `ValueNotifier<Duration>`.

### 2.3 Data Layer (The Source)
*   **`PrayerRepository`**:
    *   `getTimes(params)`:
        1.  Check Memory Cache (Run-time).
        2.  Check Hive Disk Cache (Offline-first).
        3.  Fetch API (Aladhan).
        4.  Save to Hive & Memory.
*   **`LocationRepository`**:
    *   Strategy: `LastKnown` -> `Current` -> `Fallback (Istanbul)`.
    *   *Critical:* Never block the UI waiting for GPS. Start with Fallback/Cache, refine if GPS returns.

---

## 3. UI Architecture: "Single Stack"

### 3.1 The Tree
```dart
Scaffold
  Stack
    0: AmbientBackground (AnimatedContainer / CustomPainter) -> Listens to SegmentNotifier
    1: SafeArea
       Column
         Header (Location Name, Settings Btn)
         Spacer (Hero Area)
         HeroCountdown (Big Typography) -> Listens to CountdownNotifier
         Spacer
         GlassCarousel (PageView) -> Listens to ContentNotifier
```

### 3.2 Glassmorphism Performance Strategy
*   **Problem:** BackdropFilter is expensive (GPU expensive).
*   **Solution:**
    1.  Use `RepaintBoundary` around the `GlassCarousel`.
    2.  Static Gradient Background (no active blur on BG).
    3.  Cards have `BackdropFilter` with low blur radius (e.g., 10-15px).
    4.  **Reduce Motion:** If system `disableAnimations` is true, switch to solid semi-transparent colors instead of blur.

---

## 4. Scaling & Localization Structure

*   **i18n Readiness:**
    *   Even for Turkish MVP, do NOT hardcode strings.
    *   Use `l10n/app_tr.arb`.
    *   Example: `"iftar_remaining": "İftara {duration} kaldı"`
*   **Assets:**
    *   `/assets/data/content_v1.json` (Versioning allows future over-the-air updates via remote config if needed).

---

## 5. Monetization Implementation (Non-Intrusive)

### 5.1 Native Carousel Ads
*   **Concept:** The Ad is just another "Card" in the carousel.
*   **Placement:** Index 2 or 3.
*   **Tech:** `google_mobile_ads` (Native Template).
*   **Styles:** Custom CSS/Style to match Glassmorphism (Transparent bg, white text).

### 5.2 Rewarded Implementation
*   **Trigger:** User taps "Share" on a Hadith.
*   **Flow:**
    1.  Check `isPro` (future).
    2.  If Free: Load Rewarded Ad (Pre-load).
    3.  Show "Watch short ad to remove watermark?" (Optional) OR just force interstitial for heavy users (Cap frequency).
    *   *Decision for MVP:* Keep it simple. No ads on Share for v1.0. Focus on retention. Architecture supports adding it later.

---

## 6. Risk Analysis & Mitigation

| Risk | Impact | Mitigation |
| :--- | :--- | :--- |
| **API Limit (Aladhan)** | Low | It's free/generous. We cache for 30 days. One user = ~12 requests/year ideally. |
| **Battery Drain** | High | The "Countdown" timer and "Ambient" animations. **Mitigation:** Use `WidgetsBindingObserver` to PAUSE timers/animations when app is `paused` (background). |
| **GPS Denied** | High | Empty screen = Churn. **Mitigation:** Hardcoded "Istanbul" fallback seeded in the app. User sees data immediately, then prompt for better location. |
| **Burn-in (OLED)** | Low | Not "Always On" display app, but ambient. Gradients shift slowly to prevent pixel fixity. |

---

## 7. Folder Structure

```
lib/
├── main.dart                  # Entry point, Dependency Injection setup
├── core/
│   ├── config/                # Environment, Constants
│   ├── theme/                 # AppTheme, GlassTokens (Radius, Blur, Opacity)
│   └── utils/                 # DateTime extensions, String formatters
├── data/
│   ├── services/              # ApiService (Dio), LocationService
│   ├── local/                 # HiveManager
│   └── repositories/          # Real impl of domain interfaces
├── domain/                    # Pure Dart logic
│   ├── models/                # PrayerTime, DailyContent
│   └── logic/                 # AtmosphereEngine, Segmentation
└── presentation/
    ├── home/                  # The One Screen
    │   ├── block/             # HomeController (ValueNotifier)
    │   └── widgets/           # HeroCountdown, GlassCard, AmbientBg
    └── shared/                # Common buttons, Loaders
```
