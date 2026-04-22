import 'package:flutter/foundation.dart';

/// 供 GoRouter.refreshListenable 触发重算 redirect（建档后进入主 Tab）。
final routerRefreshNotifier = RouterRefreshNotifier();

class RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
