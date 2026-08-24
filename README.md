# CurrencySnap

> **Modern Offline-First Fintech Currency Converter & Analytics**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State-BLoC%2FCubit-blueviolet)](https://bloclibrary.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-teal)](#architecture)

---

## 🌟 Overview

**CurrencySnap** is a production-grade, offline-first fintech currency converter and rate analytics application built with **Flutter** and **Clean Architecture**. Designed following the **Google Stitch Design System**, it combines a deep forest green palette (`#163300`) with high-energy lime accents (`#9FE870`), surface cards, and Apple Human Interface Guidelines (HIG) touch ergonomics.

The app features a resilient local caching layer, real-time mid-market rate calculation across 160+ world currencies, national flag integration, a favorites watchlist, and 7-day historical rate trend charts.

---

## ✨ Key Features

- **⚡ Live Mid-Market Conversions**: Real-time rate calculation across 160+ global currencies using an anchor-based cross-rate engine (`from / anchor * to`).
- **🗂️ 2-Column Currency Picker Sheet**: Keyboard-safe modal bottom sheet featuring circular national flags (`country_flags`) and multi-field search (by currency code, full currency name, or country name).
- **💾 Offline-First Architecture**: Transparent fallback to cached rates via `SharedPreferences` when offline, with cache freshness indicators.
- **⭐ Saved Pairs Watchlist**: Instant bookmarking of frequently converted currency pairs with live unit conversion rates and relative update timestamps.
- **📈 7-Day Trend Analytics**: Visual rate trend analytics with interactive sparkline charts powered by `fl_chart`.
- **⚙️ Apple HIG Grouped Settings**: Grouped inset cards for managing default base/target currencies, theme appearance, and one-tap offline cache clearing.
- **🎯 100% Google Stitch Design System**: Custom palette tokens (`#163300` Forest Green, `#9FE870` Lime, `#FFFFFF` Surface, `#E5E7EB` Card Border) with 44×44pt touch targets and 16pt border radii.

---

## 🏗️ Architecture

CurrencySnap adheres strictly to **Clean Architecture** principles and the **BLoC (Business Logic Component)** pattern for deterministic state management:

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                      │
│   Screens (Home, Favorites, Settings, Splash, Chart)       │
│   Widgets (CurrencyInputCard, SwapButton, FavoritePairTile) │
│   Bottom Sheets (CurrencyPickerSheet)                       │
└──────────────────────────────┬──────────────────────────────┘
                               │ Dispatches Events / State Flow
┌──────────────────────────────▼──────────────────────────────┐
│                    Business Logic (BLoC)                    │
│   ConvertCubit    ───► ConvertState (Initial, Loaded, Error)│
│   FavoritesCubit  ───► FavoritesState (Status, Pair List)   │
└──────────────────────────────┬──────────────────────────────┘
                               │ Injects Repository Contract
┌──────────────────────────────▼──────────────────────────────┐
│                     Repository Layer                        │
│                  CurrencyRepository                         │
│   (Rate retrieval, cross-currency math, favorites CRUD)     │
└──────────────────────────────┬──────────────────────────────┘
                               │
               ┌───────────────┴───────────────┐
               │                               │
┌──────────────▼──────────────┐ ┌──────────────▼──────────────┐
│     Remote Data Source      │ │      Local Data Source      │
│  CurrencyRemoteDataSource   │ │  CurrencyCacheDataSource    │
│  (Dio HTTP client / API)    │ │  FavoritesLocalDataSource   │
│                             │ │  (SharedPreferences cache)  │
└─────────────────────────────┘ └─────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter & Dart** | Cross-platform UI toolkit and strongly-typed programming language |
| **`flutter_bloc` & `equatable`** | Predictable, reactive state management using Cubits and value equality |
| **`dio`** | Robust HTTP client with timeouts, headers, and interceptor logging |
| **`shared_preferences`** | Key-value persistent storage for offline rate snapshots and saved pairs |
| **`fl_chart`** | Smooth, customizable chart engine for 7-day rate trends |
| **`country_flags`** | Vector-sharp circular country and regional flag rendering |
| **`intl`** | Number and currency formatting utilities |
| **`home_widget`** | Native Android/iOS home screen widget capabilities |

---

## 🚀 6-Day Agile Development Roadmap

| Day | Milestone / Sprint Goal | Deliverables | Status |
|:---:|---|---|:---:|
| **Day 1** | **Core Architecture & Networking** | Directory structuring, `Dio` network configuration, `CurrencyRateModel`, Open Exchange Rates API integration. | ✅ Complete |
| **Day 2** | **Offline Persistence & Repository** | `CurrencyCacheDataSource`, `FavoritesLocalDataSource` via `SharedPreferences`, `CurrencyRepository` implementation. | ✅ Complete |
| **Day 3** | **BLoC State Management** | `ConvertCubit`, `ConvertState`, `FavoritesCubit`, `FavoritesState`, cross-rate math engine. | ✅ Complete |
| **Day 4** | **Converter UI & Google Stitch Redesign** | Stitch design tokens, `HomeScreen` dashboard, `CurrencyInputCard`, `SwapButton`, `CurrencyPickerSheet`. | ✅ Complete |
| **Day 5** | **Favorites, Flags & Analytics** | Dual overlapping flag avatars on `FavoritePairTile`, `FavoritesScreen`, `RateChartWidget`, `HistoricalRateChartScreen`. | ✅ Complete |
| **Day 6** | **Settings, QA & Production Polish** | Grouped `SettingScreen`, `SplashScreen` brand animations, widget tests, 0 analyzer errors. | ✅ Complete |

---

## 📁 Directory Structure

```
lib/
├── bloc/
│   ├── convert/          # ConvertCubit & ConvertState
│   └── favorites/        # FavoritesCubit & FavoritesState
├── core/
│   ├── constants/        # AppConstants & Currency mappings
│   └── theme/            # AppColors (Stitch palette) & AppTheme
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
- Flutter SDK `^3.12.0` or higher
- Dart SDK `^3.12.0` or higher
- Android Studio / VS Code with Flutter extension

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
   flutter run
   ```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

