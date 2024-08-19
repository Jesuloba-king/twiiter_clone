//theme provider

//THis helps change from dark to light

import 'package:flutter/material.dart';
import 'package:twitter_clone/themes/dark_mode.dart';
import 'package:twitter_clone/themes/light_mode.dart';

class ThemeProvider with ChangeNotifier {
  //initially set default as light mode
  ThemeData _themeData = lightMode;

//get the current theme
  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  //set theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;

    //update ui
    notifyListeners();
  }

  //toggle between dark & light mode
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
