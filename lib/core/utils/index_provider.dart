import 'package:flutter/material.dart';

class PageIndexProvider extends ChangeNotifier {
  int _pageIndex = 0;

  int get pageIndex => _pageIndex;

  /// Safe setter (idempotent)
  void setPage(int index) {
    if (_pageIndex == index) return;
    _pageIndex = index;
    notifyListeners();
  }

  /// Hard reset (used on logout / login)
  void reset() {
    _pageIndex = 0;
    notifyListeners();
  }
}
