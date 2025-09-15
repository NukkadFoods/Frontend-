import 'package:flutter/material.dart';

class GreyContainer extends StatelessWidget {
  const GreyContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF7F7F7),
        border: Border.all(
          width: 2,
          color: Color(0xFFD6D6D6),
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: child,
    );
  }
}
