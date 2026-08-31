import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Contract for checking network connectivity state across the app.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementation of [NetworkInfo] using connectivity_plus with Web safety.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    if (kIsWeb) {
      // On Web browsers, raw socket and DNS lookups fail.
      // Connectivity_plus on web inspects window.navigator.onLine.
      try {
        final results = await _connectivity.checkConnectivity();
        if (results.contains(ConnectivityResult.none)) {
          return false;
        }
        return true;
      } catch (_) {
        return true;
      }
    }

    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }
}
