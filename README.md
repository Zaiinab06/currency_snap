# CurrencySnap

> **Production-Grade Offline-First Fintech Currency Converter & Analytics Application**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State-BLoC%2FCubit-blueviolet)](https://bloclibrary.dev)
[![Storage](https://img.shields.io/badge/Storage-Hive%20%2B%20SharedPreferences-orange)](#-storage-architecture)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--First%20Clean%20Architecture-teal)](#-architecture--directory-structure)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🌟 Overview

**CurrencySnap** is a production-grade, offline-first fintech currency converter and rate analytics application built with **Flutter** and **Feature-First Clean Architecture**. Designed with an **Obsidian Dark & Neon Purple Design System**, it combines high-contrast financial surface cards, ergonomic touch interactions, and an **Interactive Native Android Home Screen Widget** with direct Tap-to-Edit deep linking.

The app features a resilient local caching layer powered by **Hive**, real-time mid-market rate calculations across 160+ world currencies, national flag integration, a favorites watchlist, and 7-day historical rate trend charts.

---

## 🎨 Obsidian Dark & Neon Purple Design System

CurrencySnap features a high-contrast financial design system tailored for readability, WCAG AA compliance, and visual hierarchy.

| Token | Hex Value | Purpose |
|---|---|---|
| **Scaffold Background** | `#0B0C1E` | Ultra-dark midnight scaffold background |
| **Card Surface** | `#14152D` | Primary surface background for converted cards & lists |
| **Input Card Surface** | `#1B1C38` | High-contrast secondary background for amount inputs |
| **Primary Accent** | `#6C5CE7` | Electric neon purple for primary CTA buttons & active indicators |
| **Secondary Accent** | `#8C7CFF` | Vibrant lavender for icons, subtitles, and interactive pills |
| **Live Indicator** | `#00E676` | Radiant neon green for live API rate sync badge |
| **Warning / Cached** | `#FFB300` | Amber gold for offline cached rate notifications |
| **Reset / Destructive** | `#FF5252` | Vivid coral red for widget reset actions & removal |

---

## ✨ Key Features

- **⚡ Live Mid-Market Rate Engine**: Real-time rate calculation across 160+ global currencies using an anchor-based cross-rate engine (`from / anchor * to`).
- **📱 Interactive Native Android Home Screen Widget**:
  - Live currency pair rates and calculation engine directly on the Android home screen.
  - **Interactive Stepper Buttons**: One-tap amount modifiers (`+10`, `+50`, `+100`) without opening the app.
  - **Instant Reset (`C`)**: Quickly reverts amount to base default ($100.00).
  - **Dynamic Currency Swap (`⇄`)**: Inverts base and target currencies and calculates reciprocal rates in real-time.
  - **Tap-to-Edit Deep Link**: Tapping the conversion display opens the app via `currencysnap://autofocus` and auto-focuses the numeric keyboard on the amount input field.
  - **Live / Cached Status**: Displays online sync indicators (`● Live` / `● Cached`) and relative timestamps directly on the widget.
- **💾 Dual-Tier Offline Storage Strategy**:
  - **Hive**: Primary high-speed NoSQL database for caching exchange rates, favorite pairs, and conversion history.
  - **SharedPreferences**: Dedicated platform key-value store for native Android background widget synchronization and basic preferences.
- **🗂️ 2-Column Currency Picker Sheet**: Keyboard-safe modal bottom sheet featuring circular national flags (`country_flags`) and multi-field search (by currency code, currency name, or country name).
- **⭐ Saved Pairs Watchlist**: Instant bookmarking of frequently converted currency pairs with live unit conversion rates and relative update timestamps.
- **📈 7-Day Trend Analytics & Sparklines**: Visual rate trend analytics with interactive sparkline charts powered by `fl_chart`.
- **📜 Conversion Audit History**: Persistent history log tracking all conversions with one-tap replay, item deletion, and clear-all capabilities.
- **⚙️ Apple HIG Grouped Settings**: Grouped inset cards for managing default base/target currencies, theme appearance (Obsidian Dark / Clean Light), and one-tap offline cache clearing.

---

## 🏗️ Architecture & Directory Structure

CurrencySnap strictly adheres to **Feature-First Clean Architecture**, separating domain logic, data persistence, and presentation state management into isolated, testable modules.

```text
lib/
├── core/                                # Shared foundational modules across features
│   ├── constants/                       # AppConstants & Currency mappings
│   ├── errors/                          # AppExceptions & Failure domain entities
│   ├── network/                         # DioClient & NetworkInfo connectivity checks
│   ├── services/                        # IWidgetSyncService & WidgetServiceImpl (HomeWidget bridge)
│   ├── theme/                           # AppColors (Obsidian Dark tokens) & AppTheme
│   ├── utils/                           # CurrencyFormatter & DateTimeFormatter
│   └── widgets/                         # Shared UI components (ErrorBanner, LoadingIndicator, etc.)
│
├── features/                            # Feature-First architectural slices
│   ├── converter/                       # Real-time conversion & cross-rate engine
│   │   ├── data/                        # Remote (Dio) & Cache data sources, models, repository impl
│   │   ├── domain/                      # Entities, repository contracts, ConvertCurrency & GetLiveRates use cases
│   │   └── presentation/                # ConvertCubit, HomeScreen, SplashScreen, CurrencyPickerSheet, widgets
│   ├── favorites/                       # Starred pairs watchlist
│   │   ├── data/                        # FavoritesLocalDataSource (Hive + SharedPreferences fallback), models
│   │   ├── domain/                      # FavoritePairEntity, repository contracts, GetFavorites & ToggleFavorite use cases
│   │   └── presentation/                # FavoritesCubit, FavoritesScreen, FavoritePairTile
│   ├── historical_rates/                # 7-day sparkline charts & rate analytics
│   │   ├── data/                        # HistoricalRatesRemoteDataSource, repository impl
│   │   ├── domain/                      # HistoricalRatePoint entity, GetHistoricalRatesUseCase
│   │   └── presentation/                # RatesCubit, HistoricalRateChartScreen, RatesScreen, RateChartWidget
│   ├── history/                         # Conversion audit log
│   │   ├── data/                        # HistoryLocalDataSource (Hive box persistence), models
│   │   ├── domain/                      # ConversionHistoryEntity, AddHistory, ClearHistory, GetHistory use cases
│   │   └── presentation/                # HistoryCubit, HistoryScreen, HistoryItemTile
│   ├── navigation/                      # App root navigation shell
│   │   └── presentation/                # AppBottomNav with IndexedStack state preservation
│   ├── onboarding/                      # First-time user onboarding
│   │   └── presentation/                # OnboardingNameScreen
│   └── settings/                        # User preferences & cache controls
│       ├── data/                        # SettingsLocalDataSource, SettingsRepositoryImpl
│       ├── domain/                      # UserSettingsEntity, SettingsRepository contract
│       └── presentation/                # SettingsCubit, SettingScreen, SettingsSection, SettingsTile
│
├── presentation/                        # Global presentation scaffolding
├── routes/                              # Centralized routing (AppRouter with CupertinoPageRoute)
├── injection_container.dart             # Dependency injection via GetIt service locator
└── main.dart                            # Application bootstrap & MultiBlocProvider
```

---

## 💾 Storage Architecture

CurrencySnap implements a strict separation of concerns for local persistence:

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                        Local Storage Architecture                       │
├────────────────────────────────────┬────────────────────────────────────┤
│           Primary Storage          │        Background Sync Store       │
│               [Hive]               │        [SharedPreferences]         │
├────────────────────────────────────┼────────────────────────────────────┤
│ • Exchange Rates Cache             │ • Android RemoteViews Key-Values   │
│ • Favorites Watchlist Box          │ • Interactive Widget State         │
│ • Conversion History Audit Box     │ • Theme & Currency User Settings   │
│ • High-performance NoSQL format   │ • Native Platform Channel Bridge   │
└────────────────────────────────────┴────────────────────────────────────┘
```

1. **Hive (Primary Storage Engine)**:
   - Utilized for all high-volume, structured data: `favorites_box`, `history_box`, and exchange rate caching.
   - Provides lightning-fast serialization and disk read/write performance for offline-first resilience.
2. **SharedPreferences (HomeWidget Sync & Preferences)**:
   - Strictly utilized for low-overhead key-value persistence needed by the native Android Kotlin `RemoteViews` background widget engine (`CurrencyWidgetProvider` & `WatchlistWidgetProvider`) and basic settings storage.

---

## 📱 Interactive Native Android Home Screen Widget

CurrencySnap features a custom Android Home Screen AppWidget built with Kotlin `RemoteViews` and connected to Flutter via `home_widget`:

```text
┌───────────────────────────────────────────────────────────────────────┐
│                           CURRENCYSNAP WIDGET                         │
│  USD → PKR                                              ● Live        │
│  1 USD = 277.66 PKR                                 Updated: 10:45 AM │
├───────────────────────────────────────────────────────────────────────┤
│                                                                       │
│      150 USD = 41,649.00 PKR                                          │
│      (Tap to Open & Auto-Focus Keyboard ↗)                            │
│                                                                       │
├───────────────────────────────────────────────────────────────────────┤
│  [  ⇄ Swap  ]   [ +10 ]   [ +50 ]   [ +100 ]   [ C Reset ]            │
└───────────────────────────────────────────────────────────────────────┘
```

- **Interactive Stepper Buttons**: Tap `+10`, `+50`, or `+100` on the widget surface to increment the calculation amount instantly without launching the app.
- **Reset Action (`C`)**: Reverts the amount to the default $100.00 base.
- **Dynamic Swap (`⇄`)**: Reverses the currency pair and computes reciprocal exchange values locally via Kotlin broadcast receiver.
- **Tap-to-Edit Deep Link**: Tapping the conversion result triggers `currencysnap://autofocus` with `auto_focus_amount: true`, opening `HomeScreen` and automatically activating the amount input keyboard.
- **Live / Cached Status**: Displays online sync indicators (`● Live` in `#00E676` or `● Cached` in `#FFB300`).

---

## 🛠️ Tech Stack & Libraries

| Technology | Version | Purpose |
|---|---|---|
| **Flutter SDK** | `^3.x` | Cross-platform UI toolkit |
| **Dart SDK** | `^3.12.2` | Strongly typed modern language |
| **`flutter_bloc`** | `^9.1.1` | Predictable, reactive state management using Cubits |
| **`hive` / `hive_flutter`** | `^2.2.3` / `^1.1.0` | High-performance offline NoSQL local database |
| **`dio`** | `^5.11.0` | Robust HTTP client with interceptors and timeouts |
| **`shared_preferences`** | `^2.5.5` | Key-value store for native HomeWidget background sync |
| **`home_widget`** | `^0.9.3` | Native Android Kotlin RemoteViews bridge |
| **`fl_chart`** | `^1.2.0` | 7-day sparkline and financial trend charts |
| **`country_flags`** | `^3.1.0` | Crisp circular national flag rendering |
| **`get_it`** | `^9.2.1` | Service locator dependency injection container |
| **`connectivity_plus`** | `^7.3.1` | Real-time network connectivity detection |
| **`intl`** | `^0.20.3` | Currency, number, and date/time formatting |

---

## ⚙️ Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.12.2`
- **Dart SDK**: `>= 3.12.2`
- **Android Studio** / **VS Code** with Flutter extensions
- **Android Device / Emulator**: Android SDK API 21+

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Zaiinab06/currency_snap.git
   ```

2. **Navigate into the project directory:**
   ```bash
   cd currency_snap
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Verify codebase integrity:**
   ```bash
   dart analyze .
   flutter test
   ```

5. **Launch application:**
   ```bash
   flutter run --no-tree-shake-icons
   ```

---

## 🧪 Testing

CurrencySnap includes comprehensive unit and widget tests covering state management, domain use cases, and repositories:

```bash
flutter test
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
