import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';

extension SnackBarExtension on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = colorFailure,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message),
      ),
    );
  }

  void showSuccessSnackBar({
    required String message,
    Color backgroundColor = colorSuccess,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message),
      ),
    );
  }
}