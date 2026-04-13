import 'package:flutter/material.dart';

extension GapExtension on num {
  SizedBox get h => SizedBox(width: toDouble());
  SizedBox get v => SizedBox(height: toDouble());
}
