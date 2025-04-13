import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/wallet_controller.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:sizer/sizer.dart';

import '../../constants/texts.dart';

class WalletWidget extends StatefulWidget {
  const WalletWidget({super.key});

  @override
  State<WalletWidget> createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF5dcafc), width: 0.2.h),
          ),
          child: Column(
            children: [
              Container(
                width: 100.w,
                decoration: const BoxDecoration(
                  color: textWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 5.w),
                child: Text(
                  'AVAILABLE BALANCE',
                  style: body2TextStyle.copyWith(
                      color: primaryColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 100.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xff5dcafc),
                      Color(0xff5e5be3),
                      Color(0xff6200cd),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(9),
                    bottomRight: Radius.circular(9),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 5.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/bal_wallet.png',
                      height: 10.h,
                      width: 20.w,
                    ),
                    Text(
                      ' ${WalletController.wallet!.amount!.toStringAsFixed(2)}' ?? '0.00',
                      style: h1TextStyle.copyWith(color: textWhite),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 0.5.h,
        ),
        Text(
          '** Wallet cash can be used for boosting promotions ',
          style: body5TextStyle.copyWith(color: textGrey2),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
