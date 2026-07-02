import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> get onStatusChanged =>
      _connectivity.onConnectivityChanged;

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return _hasInternet(result);
  }

  Future<List<ConnectivityResult>> currentStatus() async {
    return await _connectivity.checkConnectivity();
  }

  bool _hasInternet(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);
  }
}