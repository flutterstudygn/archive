import 'dart:async';

import 'package:flutter/foundation.dart';

Stream globalPeriodic =
    Stream.periodic(Duration(milliseconds: 500), (i) => i).asBroadcastStream();

class PeriodicProvider extends ChangeNotifier {
  Stream periodic = Stream.periodic(Duration(milliseconds: 500), (i) => i);

  StreamSubscription periodicSubscription;

  int _num = 0;

  int get num => _num;

  PeriodicProvider() {
    periodicSubscription = periodic.listen((i) {
      _num = i;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    periodicSubscription.cancel();
    super.dispose();
  }
}
