import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

/// Abstract contract for home widget synchronization and deep-link communication.
abstract class IWidgetSyncService {
  Stream<bool> get autoFocusStream;
  void initialize();
  Future<bool> checkAutoFocusIntent();
  Future<void> syncHomeWidget({
    required String baseCurrency,
    required String targetCurrency,
    required double rate,
    required String updatedTime,
    double? amount,
  });
}

/// Concrete implementation of [IWidgetSyncService] using platform channels and HomeWidget.
class WidgetServiceImpl implements IWidgetSyncService {
  static const String androidWidgetName = 'CurrencyWidgetProvider';
  final MethodChannel _channel;
  final StreamController<bool> _autoFocusController;

  WidgetServiceImpl({
    MethodChannel? channel,
    StreamController<bool>? autoFocusController,
  })  : _channel =
            channel ?? const MethodChannel('com.example.currency_snap/widget'),
        _autoFocusController =
            autoFocusController ?? StreamController<bool>.broadcast();

  @override
  Stream<bool> get autoFocusStream => _autoFocusController.stream;

  @override
  void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onAutoFocusAmount') {
        _autoFocusController.add(true);
      }
    });

    try {
      HomeWidget.widgetClicked.listen((uri) {
        if (uri != null &&
            (uri.host == 'autofocus' ||
                uri.path.contains('autofocus') ||
                uri.toString().contains('autofocus'))) {
          _autoFocusController.add(true);
        }
      });
    } catch (_) {}
  }

  @override
  Future<bool> checkAutoFocusIntent() async {
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('getAutoFocusAmount');
      if (result == true) {
        return true;
      }
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null &&
          (uri.host == 'autofocus' ||
              uri.path.contains('autofocus') ||
              uri.toString().contains('autofocus'))) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  @override
  Future<void> syncHomeWidget({
    required String baseCurrency,
    required String targetCurrency,
    required double rate,
    required String updatedTime,
    double? amount,
  }) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isOnline = connectivityResult.any(
        (result) => result != ConnectivityResult.none,
      );

      // Save amount if provided
      if (amount != null) {
        await HomeWidget.saveWidgetData<String>(
          'widget_current_amount',
          amount.toString(),
        );
      }

      // Keys used by Kotlin for pair display & calculations
      await HomeWidget.saveWidgetData<String>('widget_base', baseCurrency);
      await HomeWidget.saveWidgetData<String>('widget_target', targetCurrency);
      await HomeWidget.saveWidgetData<String>(
          'widget_raw_rate', rate.toString());
      await HomeWidget.saveWidgetData<String>(
        'widget_pair',
        '$baseCurrency → $targetCurrency',
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_rate',
        '1 $baseCurrency = ${rate.toStringAsFixed(2)} $targetCurrency',
      );
      await HomeWidget.saveWidgetData<String>('widget_updated', updatedTime);
      await HomeWidget.saveWidgetData<bool>('widget_is_online', isOnline);

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
      );
    } catch (_) {
      // Keep widget sync non-blocking and fail-safe
    }
  }
}

/// Static helper bridge for backward compatibility.
class WidgetService {
  static final IWidgetSyncService _instance = WidgetServiceImpl();

  static Stream<bool> get autoFocusStream => _instance.autoFocusStream;
  static void initialize() => _instance.initialize();
  static Future<bool> checkAutoFocusIntent() =>
      _instance.checkAutoFocusIntent();
  static Future<void> syncHomeWidget({
    required String baseCurrency,
    required String targetCurrency,
    required double rate,
    required String updatedTime,
    double? amount,
  }) =>
      _instance.syncHomeWidget(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
        rate: rate,
        updatedTime: updatedTime,
        amount: amount,
      );
}
