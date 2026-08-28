import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String androidWidgetName = 'CurrencyWidgetProvider';
  static const MethodChannel _channel = MethodChannel('com.example.currency_snap/widget');
  static final StreamController<bool> _autoFocusController =
      StreamController<bool>.broadcast();

  static Stream<bool> get autoFocusStream => _autoFocusController.stream;

  /// Initializes widget communication channel and click listeners.
  static void initialize() {
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

  /// Checks if the app was launched from the widget with auto_focus_amount flag.
  static Future<bool> checkAutoFocusIntent() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('getAutoFocusAmount');
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

  static Future<void> syncHomeWidget({
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
      await HomeWidget.saveWidgetData<String>('widget_raw_rate', rate.toString());
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
