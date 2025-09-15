import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

class OfferTextField extends StatefulWidget {
  const OfferTextField({super.key});

  @override
  State<OfferTextField> createState() => _OfferTextFieldState();
}

class _OfferTextFieldState extends State<OfferTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100.w,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xff5dcafc),
                Color(0xff5e5be3),
                // Color(0xff5e5be3),
                Color(0xff6200cd),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(10),
          //   border: Border.all(color: const Color(0xFF5dcafc), width: 0.2.h),
          // ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              children: [
                Text(
                  'Subscribe!',
                  style: body1TextStyle.copyWith(
                      color: textWhite, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Subscribe to nukkad foods to start recieving orders',
                  style: body5TextStyle.copyWith(
                      color: textWhite, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                // Container(
                //   width: 100.w,
                //   decoration: const BoxDecoration(
                //     color: textWhite,
                //     borderRadius: BorderRadius.only(
                //       topLeft: Radius.circular(9),
                //       topRight: Radius.circular(9),
                //     ),
                //   ),
                //   padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 5.w),
                //   // child: Text(
                //   //   'AVAILABLE BALANCE',
                //   //   style: body2TextStyle.copyWith(
                //   //       color: primaryColor, fontWeight: FontWeight.bold),
                //   //   textAlign: TextAlign.center,
                //   // ),
                // ),

                // Container(
                //   width: 100.w,
                //   decoration: const BoxDecoration(
                //     gradient: LinearGradient(
                //       begin: Alignment.centerLeft,
                //       end: Alignment.centerRight,
                //       colors: [
                //         Color(0xff5dcafc),
                //         Color(0xff5e5be3),
                //         Color(0xff6200cd),
                //       ],
                //     ),
                //     borderRadius: BorderRadius.only(
                //       bottomLeft: Radius.circular(9),
                //       bottomRight: Radius.circular(9),
                //     ),
                //   ),
                //   padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 5.w),
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       Text(
                //         '47.61',
                //         style: h4TextStyle.copyWith(color: textWhite),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
        // SizedBox(
        //   height: 0.5.h,
        // ),
        // Text(
        //   '** Wallet cash can be used for boosting promotions ',
        //   style: body5TextStyle.copyWith(color: textGrey2),
        //   textAlign: TextAlign.start,
        // ),
      ],
    );
  }
}
