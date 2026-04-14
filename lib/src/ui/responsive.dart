import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;

  Responsive._({required this.context});

  factory Responsive.of(BuildContext context) => Responsive._(context: context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  double textScale(double fontSize) =>
      MediaQuery.of(context).textScaler.scale(fontSize);

  double get halfWidth => width / 2;
  double get thirdWidth => width / 3;
  double get quarterWidth => width / 4;

  double get halfHeight => height / 2;
  double get thirdHeight => height / 3;
  double get quarterHeight => height / 4;

  double get small => 320;
  double get medium => 600;
  double get large => 900;

  bool get isSmall => width < small;
  bool get isMedium => width >= small && width < medium;
  bool get isLarge => width >= medium && width < large;
  bool get isExtraLarge => width >= large;

  double scale(double value) => width * value / 414;
}
