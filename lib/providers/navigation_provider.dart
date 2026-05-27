import 'package:flutter/material.dart';
//navigation provider
//owns bottom-nav tab index
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  void switchTab(int index){
    if (_currentIndex ==index)return;
    _currentIndex =index;
    notifyListeners();


    }
  }

