# CurrencySnap

> **Modern Offline-First Fintech Currency Converter & Analytics**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State-BLoC%2FCubit-blueviolet)](https://bloclibrary.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-teal)](#architecture)

---

## 🌟 Overview

**CurrencySnap** is a production-grade, offline-first fintech currency converter and rate analytics application built with **Flutter** and **Clean Architecture**. Designed with an **Obsidian Dark & Neon Purple/Indigo Design System**, it combines high-contrast financial surface cards, Apple Human Interface Guidelines (HIG) touch ergonomics, and an **Interactive Native Android Home Screen Widget** with direct Tap-to-Edit deep linking.

The app features a resilient local caching layer, real-time mid-market rate calculation across 160+ world currencies, national flag integration, a favorites watchlist, and 7-day historical rate trend charts.

---

## 🎨 Obsidian Dark Design System

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

- **⚡ Live Mid-Market Conversions**: Real-time rate calculation across 160+ global currencies using an anchor-based cross-rate engine (`from / anchor * to`).
- **📱 Interactive Android Home Screen Widget**:
  - Live currency pair rates and calculation engine directly on the home screen.
  - Interactive stepper buttons (`+10`, `+50`, `+100`, and Reset `C`) without launching the app.
  - Dynamic currency swapping (`⇄`) with real-time reciprocal rates.
  - **Tap-to-Edit Deep Link**: Tapping the conversion display opens the Flutter app and auto-focuses the numeric keyboard on the amount input field.
  - Real-time two-way synchronization between app input changes and widget state.
- **🗂️ 2-Column Currency Picker Sheet**: Keyboard-safe modal bottom sheet featuring circular national flags (`country_flags`) and multi-field search (by currency code, full currency name, or country name).
- **💾 Offline-First Architecture**: Transparent fallback to cached rates via `SharedPreferences` when offline, with sync freshness indicators.
- **⭐ Saved Pairs Watchlist**: Instant bookmarking of frequently converted currency pairs with live unit conversion rates and relative update timestamps.
- **📈 7-Day Trend Analytics**: Visual rate trend analytics with interactive sparkline charts powered by `fl_chart`.
- **⚙️ Apple HIG Grouped Settings**: Grouped inset cards for managing default base/target currencies, theme appearance, and one-tap offline cache clearing.

---

## 🏗️ Architecture

CurrencySnap adheres strictly to **Clean Architecture** principles and the **BLoC (Business Logic Component)** pattern:

```text
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                      │
│   Screens (Home, Favorites, Settings, Splash, Chart)        │
│   Widgets (CurrencyInputCard, SwapButton, FavoritePairTile) │
│   Bottom Sheets (CurrencyPickerSheet)                       │
└──────────────────────────────┬──────────────────────────────┘
                               │ Dispatches Events / State Flow
┌──────────────────────────────▼──────────────────────────────┐
│                    Business Logic (BLoC)                    │
│   ConvertCubit    ───► ConvertState (Initial, Loaded, Error)│
│   FavoritesCubit  ───► FavoritesState (Status, Pair List)   │
│   SettingsCubit   ───► SettingsState (Theme, Defaults)      │
└──────────────────────────────┬──────────────────────────────┘
                               │ Injects Repository Contract
┌──────────────────────────────▼──────────────────────────────┐
│                     Repository Layer                        │
│                   CurrencyRepository                        │
│   (Rate retrieval, cross-currency math, favorites CRUD)     │
└──────────────────────────────┬──────────────────────────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
┌───────────────▼─────────────┐ ┌─────────────▼───────────────┐
│     Remote Data Source      │ │      Local Data Source      │
│   CurrencyRemoteDataSource  │ │   CurrencyCacheDataSource   │
│   (Dio HTTP client / API)   │ │   FavoritesLocalDataSource  │
│                             │ │   (SharedPreferences cache) │
└─────────────────────────────┘ └─────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter & Dart** | Cross-platform UI toolkit and strongly-typed language |
| **`flutter_bloc` & `equatable`** | Predictable, reactive state management using Cubits |
| **`dio`** | Robust HTTP client with timeouts, logging, and error handling |
| **`shared_preferences`** | Key-value persistent storage for offline rate snapshots and saved pairs |
| **`home_widget`** | Native Android Kotlin RemoteViews bridge for Home Screen Widget |
| **`fl_chart`** | Customizable chart engine for 7-day historical rate trends |
| **`country_flags`** | Vector-sharp circular country and regional flag rendering |
| **`intl`** | Number and currency formatting utilities |
| **`connectivity_plus`** | Network state detection for live vs. cached data indication |

---

## 📁 Directory Structure

```plaintext
lib/
├── bloc/
│   ├── convert/              # ConvertCubit & ConvertState
│   ├── favorites/            # FavoritesCubit & FavoritesState
│   └── settings/             # SettingsCubit & SettingsState
├── core/
│   ├── constants/            # AppConstants & Currency mappings
│   ├── errors/               # AppExceptions & error handling
│   ├── network/              # DioClient & HTTP configuration
│   ├── services/             # WidgetService (HomeWidget sync & deep link)
│   ├── theme/                # AppColors (Obsidian palette) & AppTheme
│   └── utils/                # CurrencyFormatter & DateTimeFormatter
├── data/
│   ├── datasources/
│   │   ├── local/            # CurrencyCacheDataSource & FavoritesLocalDataSource
│   │   └── remote/           # CurrencyRemoteDataSource (Dio)
│   ├── models/               # CurrencyRateModel, FavoritePairModel, HistoryModel
│   └── repositories/         # CurrencyRepository
├── presentation/
│   ├── bottom_sheets/        # CurrencyPickerSheet (2-column flag grid)
│   ├── navigation/           # AppBottomNav (IndexedStack tab bar)
│   ├── screens/
│   │   ├── favorites/        # FavoritesScreen (Watchlist)
│   │   ├── historical_rates/ # HistoricalRateChartScreen
│   │   ├── history/          # HistoryScreen (Conversion logs)
│   │   ├── home/             # HomeScreen (Converter Dashboard)
│   │   ├── rates/            # RatesScreen (All rates overview)
│   │   ├── settings/         # SettingScreen (Grouped settings)
│   │   └── splash/           # SplashScreen (Brand intro)
│   └── widgets/              # Common, Home, Favorites, and Chart widgets
└── main.dart                 # App entrypoint & MultiBlocProvider
```

---

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK `^3.x`
- Dart SDK `^3.x`
- Android Studio / VS Code

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Zaiinab06/currency_snap.git
   cd currency_snap
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify codebase integrity:**
   ```bash
   dart analyze .
   flutter test
   ```

4. **Launch application:**
   ```bash
   flutter run --no-tree-shake-icons
   ```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
