# CurrencySnap

> **Modern Offline-First Fintech Currency Converter & Analytics**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State-BLoC%2FCubit-blueviolet)](https://bloclibrary.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-teal)](#architecture)

---

## 🌟 Overview

**CurrencySnap** is a production-grade, offline-first fintech currency converter and rate analytics application built with **Flutter** and **Clean Architecture**. Designed with an **Obsidian Dark & Neon Purple/Indigo Design System** (`#0B0C1E`, `#6C5CE7`), it combines high-contrast financial surface cards, Apple Human Interface Guidelines (HIG) touch ergonomics, and an **Interactive Native Android Home Screen Widget**.

The app features a resilient local caching layer, real-time mid-market rate calculation across 160+ world currencies, national flag integration, a favorites watchlist, and 7-day historical rate trend charts.

---

## ✨ Key Features

- **⚡ Live Mid-Market Conversions**: Real-time rate calculation across 160+ global currencies using an anchor-based cross-rate engine (`from / anchor * to`).
- **📱 Interactive Android Home Screen Widget**:
  - Live currency pair rates and calculation engine directly on the home screen.
  - Interactive stepper buttons (`+10`, `+50`, `+100`, and Reset `C`) without launching the app.
  - Dynamic currency swapping (`⇄`) with real-time reciprocal rates.
- **🗂️ 2-Column Currency Picker Sheet**: Keyboard-safe modal bottom sheet featuring circular national flags (`country_flags`) and multi-field search (by currency code, currency name, or country name).
- **💾 Offline-First Architecture**: Transparent fallback to cached rates via `SharedPreferences` when offline, with sync freshness indicators.
- **⭐ Saved Pairs Watchlist**: Instant bookmarking of frequently converted currency pairs with live unit conversion rates.
- **📈 7-Day Trend Analytics**: Visual rate trend analytics with interactive sparkline charts powered by `fl_chart`.
- **🎯 Obsidian Dark Design System**: High-contrast dark tokens (`#0B0C1E` Scaffold, `#14152D` Surface, `#1B1C38` Input, `#6C5CE7` Accent Glow) with tabular numeric typography alignment.

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

---

## 📁 Directory Structure

```plaintext
lib/
├── bloc/
│   ├── convert/          # ConvertCubit & ConvertState
│   ├── favorites/        # FavoritesCubit & FavoritesState
│   └── settings/         # SettingsCubit & SettingsState
├── core/
│   ├── constants/        # AppConstants & endpoints
│   ├── services/         # WidgetService (HomeWidget sync)
│   └── theme/            # AppColors (Obsidian palette) & AppTheme
├── data/
│   ├── datasources/
│   │   ├── local/        # CurrencyCacheDataSource & FavoritesLocalDataSource
│   │   └── remote/       # CurrencyRemoteDataSource (Dio)
│   ├── models/           # CurrencyRateModel & FavoritePairModel
│   └── repositories/     # CurrencyRepository
├── presentation/
│   ├── bottom_sheets/    # CurrencyPickerSheet (2-column flag grid)
│   ├── navigation/       # AppBottomNav (IndexedStack tab bar)
│   ├── screens/
│   │   ├── favorites/    # FavoritesScreen (Watchlist)
│   │   ├── historical_rates/ # HistoricalRateChartScreen
│   │   ├── home/         # HomeScreen (Converter Dashboard)
│   │   ├── settings/     # SettingScreen (Grouped settings)
│   │   └── splash/       # SplashScreen (Brand intro)
│   └── widgets/          # Common, Home, Favorites, and Chart widgets
├── routes/               # AppRouter named routes
└── main.dart             # App entrypoint & MultiBlocProvider
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

