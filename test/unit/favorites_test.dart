import 'dart:io';
import 'package:currency_snap/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:currency_snap/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:currency_snap/features/favorites/domain/entities/favorite_pair_entity.dart';
import 'package:currency_snap/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:currency_snap/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:currency_snap/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:currency_snap/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<Map> favoritesBox;
  late SharedPreferences prefs;
  late FavoritesLocalDataSource localDataSource;
  late FavoritesRepositoryImpl repository;
  late GetFavoritesUseCase getFavoritesUseCase;
  late ToggleFavoriteUseCase toggleFavoriteUseCase;
  late FavoritesCubit favoritesCubit;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_fav_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    favoritesBox = await Hive.openBox<Map>(
        'favorites_test_${DateTime.now().microsecondsSinceEpoch}');
    localDataSource = FavoritesLocalDataSourceImpl(favoritesBox, prefs);
    repository = FavoritesRepositoryImpl(localDataSource);
    getFavoritesUseCase = GetFavoritesUseCase(repository);
    toggleFavoriteUseCase = ToggleFavoriteUseCase(repository);
    favoritesCubit = FavoritesCubit(getFavoritesUseCase, toggleFavoriteUseCase);
  });

  tearDown(() async {
    await favoritesCubit.close();
    if (favoritesBox.isOpen) {
      await favoritesBox.deleteFromDisk();
    }
  });

  group('Favorites Persistence & Storage Engine Verification', () {
    test('Stores and retrieves favorites directly from structured Hive box', () async {
      final pair = FavoritePairEntity.create(
        fromCurrency: 'USD',
        toCurrency: 'PKR',
        rate: 278.25,
      );

      await repository.addFavorite(pair);

      // Verify stored Map in Hive box
      expect(favoritesBox.containsKey('USD_PKR'), isTrue);
      final storedMap = favoritesBox.get('USD_PKR');
      expect(storedMap, isNotNull);
      expect(storedMap!['fromCurrency'], 'USD');
      expect(storedMap['toCurrency'], 'PKR');
      expect(storedMap['rate'], 278.25);

      // Verify retrieval through repository
      final result = await repository.getFavorites();
      expect(result.length, 1);
      expect(result.first.id, 'USD_PKR');
      expect(result.first.rate, 278.25);
    });

    test('Persists state across simulated app restarts', () async {
      // 1. Initial app session: Save 2 favorite pairs
      final pair1 = FavoritePairEntity.create(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        rate: 0.92,
      );
      final pair2 = FavoritePairEntity.create(
        fromCurrency: 'GBP',
        toCurrency: 'JPY',
        rate: 195.40,
      );

      await repository.addFavorite(pair1);
      await repository.addFavorite(pair2);

      // 2. Simulate app kill & relaunch with fresh data sources and Cubit
      final freshLocalSource = FavoritesLocalDataSourceImpl(favoritesBox, prefs);
      final freshRepo = FavoritesRepositoryImpl(freshLocalSource);
      final freshGetUseCase = GetFavoritesUseCase(freshRepo);
      final freshToggleUseCase = ToggleFavoriteUseCase(freshRepo);
      final freshCubit = FavoritesCubit(freshGetUseCase, freshToggleUseCase);

      // Initial load from storage
      await freshCubit.loadFavorites();

      expect(freshCubit.state.status, FavoritesStatus.success);
      expect(freshCubit.state.favorites.length, 2);
      expect(freshCubit.state.favorites.map((p) => p.id).toSet(), {'USD_EUR', 'GBP_JPY'});
      expect(freshCubit.isFavorite('USD', 'EUR'), isTrue);
      expect(freshCubit.isFavorite('GBP', 'JPY'), isTrue);
      expect(freshCubit.isFavorite('EUR', 'USD'), isFalse);

      await freshCubit.close();
    });

    test('Prevents duplicate entries when re-adding existing pair with updated rate or different casing', () async {
      final pairInitial = FavoritePairEntity.create(
        fromCurrency: 'USD',
        toCurrency: 'PKR',
        rate: 275.0,
      );
      await repository.addFavorite(pairInitial);

      // Add same pair with lowercase codes and updated rate
      final pairUpdated = FavoritePairEntity.create(
        fromCurrency: 'usd',
        toCurrency: 'pkr',
        rate: 278.5,
      );
      await repository.addFavorite(pairUpdated);

      final favorites = await repository.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.id, 'USD_PKR');
      expect(favorites.first.rate, 278.5);
    });

    test('Operates 100% offline without remote network dependencies', () async {
      final pair = FavoritePairEntity.create(
        fromCurrency: 'EUR',
        toCurrency: 'USD',
        rate: 1.08,
      );

      // Add and remove in offline mode
      await favoritesCubit.addFavorite(pair);
      expect(favoritesCubit.state.favorites.length, 1);
      expect(favoritesCubit.isFavorite('EUR', 'USD'), isTrue);

      final isFav = await repository.isFavorite('EUR_USD');
      expect(isFav, isTrue);

      await favoritesCubit.removeFavorite(pair);
      expect(favoritesCubit.state.favorites.isEmpty, isTrue);
      expect(favoritesCubit.isFavorite('EUR', 'USD'), isFalse);
    });

    test('toggleFavorite adds un-favorited pair and removes already-favorited pair', () async {
      // 1. Toggle ON
      final added = await favoritesCubit.toggleFavorite('USD', 'CAD', rate: 1.35);
      expect(added, isTrue);
      expect(favoritesCubit.state.favorites.length, 1);
      expect(favoritesCubit.state.favorites.first.id, 'USD_CAD');

      // 2. Toggle OFF
      final removed = await favoritesCubit.toggleFavorite('USD', 'CAD');
      expect(removed, isFalse);
      expect(favoritesCubit.state.favorites.isEmpty, isTrue);
    });
  });
}