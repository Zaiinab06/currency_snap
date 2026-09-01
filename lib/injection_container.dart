import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/services/widget_service.dart';
import 'features/converter/data/datasources/currency_cache_datasource.dart';
import 'features/converter/data/datasources/currency_remote_datasource.dart';
import 'features/converter/data/repositories/converter_repository_impl.dart';
import 'features/converter/domain/repositories/converter_repository.dart';
import 'features/converter/domain/usecases/convert_currency_usecase.dart';
import 'features/converter/domain/usecases/get_live_rates_usecase.dart';
import 'features/converter/presentation/cubit/convert_cubit.dart';
import 'features/favorites/data/datasources/favorites_local_datasource.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/historical_rates/data/datasources/historical_rates_remote_datasource.dart';
import 'features/historical_rates/data/repositories/historical_rates_repository_impl.dart';
import 'features/historical_rates/domain/repositories/historical_rates_repository.dart';
import 'features/historical_rates/domain/usecases/get_historical_rates_usecase.dart';
import 'features/historical_rates/presentation/cubit/rates_cubit.dart';
import 'features/history/data/datasources/history_local_datasource.dart';
import 'features/history/data/repositories/history_repository_impl.dart';
import 'features/history/domain/repositories/history_repository.dart';
import 'features/history/domain/usecases/add_history_usecase.dart';
import 'features/history/domain/usecases/clear_history_usecase.dart';
import 'features/history/domain/usecases/get_history_usecase.dart';
import 'features/history/presentation/cubit/history_cubit.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

final sl = GetIt.instance;

/// Initializes all service locator dependencies across Core and Feature slices.
Future<void> initServiceLocator({
  SharedPreferences? prefs,
  Box<Map>? favoritesBox,
  Box<Map>? historyBox,
}) async {
  // 1. External & Core
  final sharedPreferences = prefs ?? await SharedPreferences.getInstance();
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerSingleton<SharedPreferences>(sharedPreferences);
  }

  Box<Map>? favBox = favoritesBox;
  Box<Map>? histBox = historyBox;
  try {
    if (favBox == null && histBox == null) {
      await Hive.initFlutter();
      favBox = await Hive.openBox<Map>('favorites_box');
      histBox = await Hive.openBox<Map>('history_box');
    }
  } catch (_) {
    // Non-blocking in pure unit test environments without paths
  }

  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => DioClient.instance);
  }

  if (!sl.isRegistered<Connectivity>()) {
    sl.registerLazySingleton<Connectivity>(() => Connectivity());
  }

  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<Connectivity>()),
    );
  }

  if (!sl.isRegistered<IWidgetSyncService>()) {
    sl.registerLazySingleton<IWidgetSyncService>(
      () => WidgetServiceImpl(),
    );
  }

  // 2. Feature: Converter
  if (!sl.isRegistered<CurrencyRemoteDataSource>()) {
    sl.registerLazySingleton<CurrencyRemoteDataSource>(
      () => CurrencyRemoteDataSourceImpl(dio: sl<Dio>()),
    );
  }

  if (!sl.isRegistered<CurrencyCacheDataSource>()) {
    sl.registerLazySingleton<CurrencyCacheDataSource>(
      () => CurrencyCacheDataSourceImpl(sl<SharedPreferences>()),
    );
  }

  if (!sl.isRegistered<ConverterRepository>()) {
    sl.registerLazySingleton<ConverterRepository>(
      () => ConverterRepositoryImpl(
        sl<CurrencyRemoteDataSource>(),
        sl<CurrencyCacheDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<GetLiveRatesUseCase>()) {
    sl.registerLazySingleton<GetLiveRatesUseCase>(
      () => GetLiveRatesUseCase(sl<ConverterRepository>()),
    );
  }

  if (!sl.isRegistered<ConvertCurrencyUseCase>()) {
    sl.registerLazySingleton<ConvertCurrencyUseCase>(
      () => const ConvertCurrencyUseCase(),
    );
  }

  // 3. Feature: Historical Rates
  if (!sl.isRegistered<HistoricalRatesRemoteDataSource>()) {
    sl.registerLazySingleton<HistoricalRatesRemoteDataSource>(
      () => HistoricalRatesRemoteDataSourceImpl(dio: sl<Dio>()),
    );
  }

  if (!sl.isRegistered<HistoricalRatesRepository>()) {
    sl.registerLazySingleton<HistoricalRatesRepository>(
      () => HistoricalRatesRepositoryImpl(
        sl<HistoricalRatesRemoteDataSource>(),
        sl<CurrencyCacheDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<GetHistoricalRatesUseCase>()) {
    sl.registerLazySingleton<GetHistoricalRatesUseCase>(
      () => GetHistoricalRatesUseCase(sl<HistoricalRatesRepository>()),
    );
  }

  // 4. Feature: Favorites
  if (!sl.isRegistered<FavoritesLocalDataSource>()) {
    sl.registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSourceImpl(favBox, sl<SharedPreferences>()),
    );
  }

  if (!sl.isRegistered<FavoritesRepository>()) {
    sl.registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(
        sl<FavoritesLocalDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<GetFavoritesUseCase>()) {
    sl.registerLazySingleton<GetFavoritesUseCase>(
      () => GetFavoritesUseCase(sl<FavoritesRepository>()),
    );
  }

  if (!sl.isRegistered<ToggleFavoriteUseCase>()) {
    sl.registerLazySingleton<ToggleFavoriteUseCase>(
      () => ToggleFavoriteUseCase(sl<FavoritesRepository>()),
    );
  }

  // 5. Feature: History
  if (!sl.isRegistered<HistoryLocalDataSource>()) {
    sl.registerLazySingleton<HistoryLocalDataSource>(
      () => HistoryLocalDataSourceImpl(histBox, sl<SharedPreferences>()),
    );
  }

  if (!sl.isRegistered<HistoryRepository>()) {
    sl.registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(
        sl<HistoryLocalDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<GetHistoryUseCase>()) {
    sl.registerLazySingleton<GetHistoryUseCase>(
      () => GetHistoryUseCase(sl<HistoryRepository>()),
    );
  }

  if (!sl.isRegistered<AddHistoryUseCase>()) {
    sl.registerLazySingleton<AddHistoryUseCase>(
      () => AddHistoryUseCase(sl<HistoryRepository>()),
    );
  }

  if (!sl.isRegistered<ClearHistoryUseCase>()) {
    sl.registerLazySingleton<ClearHistoryUseCase>(
      () => ClearHistoryUseCase(sl<HistoryRepository>()),
    );
  }

  // 6. Feature: Settings
  if (!sl.isRegistered<SettingsLocalDataSource>()) {
    sl.registerLazySingleton<SettingsLocalDataSource>(
      () => SettingsLocalDataSourceImpl(sl<SharedPreferences>()),
    );
  }

  if (!sl.isRegistered<SettingsRepository>()) {
    sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        sl<SettingsLocalDataSource>(),
      ),
    );
  }

  // 7. Presentation Cubits (Factory for dynamic lifecycles)
  sl.registerFactory<ConvertCubit>(
    () => ConvertCubit(
      sl<GetLiveRatesUseCase>(),
      sl<ConvertCurrencyUseCase>(),
      sl<FavoritesRepository>(),
      sl<HistoryRepository>(),
      widgetSyncService: sl<IWidgetSyncService>(),
    ),
  );

  sl.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(
      sl<GetFavoritesUseCase>(),
      sl<ToggleFavoriteUseCase>(),
    ),
  );

  sl.registerFactory<HistoryCubit>(
    () => HistoryCubit(sl<HistoryRepository>()),
  );

  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(sl<SettingsRepository>()),
  );

  sl.registerFactory<RatesCubit>(
    () => RatesCubit(
      sl<GetHistoricalRatesUseCase>(),
      connectivity: sl<Connectivity>(),
    ),
  );
}
