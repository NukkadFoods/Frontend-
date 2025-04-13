import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/utils/extensions.dart';

Widget SavingsWidget(bool isdarkmode, Map billingDetail) {
  double amount = 0;
  String reason = '';
  if (billingDetail['latePrep'] == true) {
    amount += billingDetail['nukkad_wallet_cash'] ?? 0;
    reason = 'Prepared';
  }
  if (billingDetail['lateDelivery'] == true) {
    amount += billingDetail['delivery_boy_wallet_cash'] ?? 0;
    reason = 'Delivered';
  }
  if (billingDetail['lateDelivery'] == true &&
      billingDetail['latePrep'] == true) {
    reason = 'Prepared and Delivered';
  }

  return Container(
    // height: 8.h,
    margin: EdgeInsets.only(left: 3.w, right: 3.w, top: 1.h, bottom: 2.h),
    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF76d6fd),
          Color(0xFF8399e9),
          Color(0xFF925bd4),
        ],
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/popper_icon.png',
          height: 4.h,
          alignment: Alignment.center,
        ),
        const SizedBox(width: 10),
        Expanded(
          // width: 68.w,
          // margin: EdgeInsets.symmetric(vertical: 0.5.h),
          child: Text(
            'Yay! You got a reward of ₹${amount.roundOff()} on this order since the order has been $reason late',
            style: body4TextStyle.copyWith(
              color: isdarkmode ? textBlack : textWhite,
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.start,
          ),
        )
      ],
    ),
  );
}
