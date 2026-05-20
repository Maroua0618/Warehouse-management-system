import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for checking network connectivity.
/// This abstraction allows for easy testing and mocking.
abstract class NetworkInfo {
  /// Returns true if the device has an active internet connection
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo using connectivity_plus package.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    // Check if connection type is available (mobile, wifi, ethernet)
    // connectivity_plus may return single ConnectivityResult or List based on version
    if (result is List) {
      final resultList = result as List<ConnectivityResult>;
      return resultList.any(
        (r) =>
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.ethernet,
      );
    } else {
      // Single result
      return result != ConnectivityResult.none;
    }
  }
}
