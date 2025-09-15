import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class InfoContainer extends StatelessWidget {
  const InfoContainer({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFFF9F4CD),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Color(0xFFFBE180),
          width: 2,
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Note:',
              style: TextStyle(
                color: colorGreen,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: ' ${message}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
