import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:flutter/material.dart';

class RightImageContainer extends StatelessWidget {
  const RightImageContainer(
      {super.key,
      required this.imagePath,
      required this.count,
      required this.message});

  final String imagePath;
  final String count;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: colorGray)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  color: colorGreen,
                  fontSize: large,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                message,
                style: TextStyle(
                  fontSize: small,
                ),
              )
            ],
          ),
          Image.asset(imagePath),
        ],
      ),
    );
  }
}
