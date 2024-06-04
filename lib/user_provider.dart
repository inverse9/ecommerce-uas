import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int _userId = 0;

  int get userId => _userId;

  void setUserId(int userId) {
    _userId = userId;
    notifyListeners();
  }
}
