import 'package:flutter/material.dart';

/// Add vertical space
Widget addVerticalSpace({required double height}) {
  return SizedBox(height: height);
}

/// Add horizontal space
Widget addHorizontalSpace({required double width}) {
  return SizedBox(width: width);
}

/// Get formatted date
String getFormattedDate(DateTime dateTime) {
  return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
}
