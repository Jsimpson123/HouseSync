import 'package:flutter/material.dart';

class AppColours {
  static Color colour1(Brightness brightness) =>
      brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade50;

  static Color colour2(Brightness brightness) =>
      brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200;

  static Color colour3(Brightness brightness) =>
      brightness == Brightness.dark ? Colors.grey.shade200 : Colors.grey.shade800;

  static Color colour4(Brightness brightness) =>
      brightness == Brightness.dark ? Colors.grey.shade100 : Colors.grey.shade900;
}