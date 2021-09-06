import 'package:flutter/material.dart';

class Dimensions {
  final BuildContext context;
  Dimensions(this.context);
  double get height => MediaQuery.of(context).size.height;
  double get width => MediaQuery.of(context).size.width;
  double get statusBarHeight => MediaQuery.of(context).padding.top;
  double get navigationBarHeight =>MediaQuery.of(context).padding.bottom;
  double get textScaleFactor => MediaQuery.of(context).textScaleFactor;
}
