import 'dart:io';
import 'package:currency_snap/features/history/data/datasources/history_local_datasource.dart';
import 'package:currency_snap/features/history/data/models/conversion_history_model.dart';
import 'package:currency_snap/features/history/data/repositories/history_repository_impl.dart';
import 'package:currency_snap/features/history/domain/entities/conversion_history_entity.dart';
import 'package:currency_snap/features/history/presentation/cubit/history_cubit.dart';
import 'package:currency_snap/features/history/presentation/cubit/history_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<Map> historyBox;
  late SharedPreferences prefs;
  late HistoryLocalDataSourceImpl localDataSource;
  late HistoryRepositoryImpl repository;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_hist_test_');
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
    historyBox = await Hive.openBox<Map>(
        'history_test_${DateTime.now().microsecondsSinceEpoch}');
    localDataSource = HistoryLocalDataSourceImpl(historyBox, prefs);
    repository = HistoryRepositoryImpl(localDataSource);
  });

  tearDown(() async {
    if (historyBox.isOpen) {
      await historyBox.deleteFromDisk();
    }
  });

  group('Conversion History Flow & Persistence Verification', () {
    test('Records all required conversion fields accurately in structured Hive box', () async {
      final now = DateTime(2026, 9, 1, 12, 0, 0);
      final item = ConversionHistoryEntity.create(
        fromCurrency: 'USD',
        toCurrency: 'PKR',
        fromAmount: 100.0,
        toAmount: 27825.0,
        rate: 278.25,
        timestamp: now,
      );

      await repository.addHistory(item);

      // Verify stored Map in Hive box
      expect(historyBox.containsKey(item.id), isTrue);
      final entry = historyBox.get(item.id)!;
      expect(entry['fromCurrency'], 'USD');
      expect(entry['toCurrency'], 'PKR');
      expect(entry['fromAmount'], 100.0);
      expect(entry['toAmount'], 27825.0);
      expect(entry['rate'], 278.25);
      expect(entry['timestamp'], now.toIso8601String());

      final history = await repository.getHistory();
      expect(history.length, 1);
      expect(history.first.fromCurrency, 'USD');
      expect(history.first.toCurrency, 'PKR');
      expect(history.first.fromAmount, 100.0);
      expect(history.first.toAmount, 27825.0);
      expect(history.first.rate, 278.25);
    });

    test('Throttles rapid duplicate conversions within 3 seconds', () async {
      final item1 = ConversionHistoryModel.create(
        fromCurrency: 'EUR',
        toCurrency: 'USD',
        fromAmount: 50.0,
        toAmount: 54.0,
        rate: 1.08,
      );

      await repository.addHistory(item1);

      // Attempt immediate duplicate
      final item2 = ConversionHistoryModel.create(
        fromCurrency: 'EUR',
        toCurrency: 'USD',
        fromAmount: 50.0,
        toAmount: 54.0,
        rate: 1.08,
      );
      await repository.addHistory(item2);

      final history = await repository.getHistory();
      expect(history.length, 1);
    });

    test('Caps history storage at maximum 50 records', () async {
      for (int i = 0; i < 60; i++) {
        final item = ConversionHistoryModel.create(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          fromAmount: (i + 1).toDouble(),
          toAmount: ((i + 1) * 0.92),
          rate: 0.92,
          timestamp: DateTime.now().add(Duration(seconds: i * 4)),
        );
        await repository.addHistory(item);
      }

      final history = await repository.getHistory();
      expect(history.length, 50);
    });

    test('Deletes individual history records and clears all logs', () async {
      final item1 = ConversionHistoryModel.create(
        fromCurrency: 'USD',
        toCurrency: 'JPY',
        fromAmount: 10.0,
        toAmount: 1500.0,
        rate: 150.0,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      final item2 = ConversionHistoryModel.create(
        fromCurrency: 'GBP',
        toCurrency: 'CAD',
        fromAmount: 20.0,
        toAmount: 35.0,
        rate: 1.75,
        timestamp: DateTime.now(),
      );

      await repository.addHistory(item1);
      await repository.addHistory(item2);

      var history = await repository.getHistory();
      expect(history.length, 2);

      // Delete item 1
      await repository.deleteHistoryItem(item1.id);
      history = await repository.getHistory();
      expect(history.length, 1);
      expect(history.first.id, item2.id);

      // Clear all
      await repository.clearHistory();
      history = await repository.getHistory();
      expect(history.isEmpty, isTrue);
    });

    test('HistoryCubit automatically updates state via historyStream without manual reload', () async {
      final cubit = HistoryCubit(repository);
      await pumpEventQueue();

      expect(cubit.state.status, HistoryStatus.success);
      expect(cubit.state.history.isEmpty, isTrue);

      // Simulate a conversion recorded from Converter screen
      final conversion = ConversionHistoryModel.create(
        fromCurrency: 'USD',
        toCurrency: 'PKR',
        fromAmount: 100.0,
        toAmount: 27825.0,
        rate: 278.25,
      );
      await repository.addHistory(conversion);
      await pumpEventQueue();

      // Verify Cubit state reacted immediately via stream
      expect(cubit.state.history.length, 1);
      expect(cubit.state.history.first.id, conversion.id);
      expect(cubit.state.history.first.fromCurrency, 'USD');
      expect(cubit.state.history.first.toCurrency, 'PKR');

      await cubit.close();
    });
  });
}