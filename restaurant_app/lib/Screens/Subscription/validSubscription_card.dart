import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

// import '../../../constants/texts.dart';

class ValidSubscribeCard extends StatefulWidget {
  const ValidSubscribeCard({super.key});

  @override
  State<ValidSubscribeCard> createState() => _ValidSubscribeCardState();
}

class _ValidSubscribeCardState extends State<ValidSubscribeCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100.w,
          decoration: const BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/renew_subscribe.png',
                  height: 90,
                  width: 100,
                ),
                // SizedBox(
                //   width: 5.w,
                // ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valid Till',
                      style: body1TextStyle.copyWith(
                          color: textWhite, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 0.5.h,
                    ),
                    Text(
                      '04/03/2035',
                      style: body3TextStyle.copyWith(
                          color: textWhite, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
