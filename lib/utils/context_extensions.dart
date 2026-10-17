import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  double get screenWidth => MediaQuery.widthOf(this);
  double get screenHeight => MediaQuery.heightOf(this);

  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  EdgeInsets get padding => MediaQuery.paddingOf(this);
}
