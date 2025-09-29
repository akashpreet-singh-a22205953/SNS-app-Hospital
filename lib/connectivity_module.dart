 import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityModule {
  Future<bool> checkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity == ConnectivityResult.mobile || connectivity == ConnectivityResult.wifi;

  }
}