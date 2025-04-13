import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/Controller/walletcontroller.dart';
Widget walletHeader(BuildContext context) {
   bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  // Check if wallet is null (data hasn't been loaded yet)
  if (WalletController.wallet == null) {
    return const Center(
      child: CircularProgressIndicator(), // Show loading indicator
    );
  }

  // Once wallet is not null, display the content
  return Container(
    height: 35.h,
    width: double.maxFinite,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFcb120e), Color(0xFFae0e0a), Color(0xFF910a07)],
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(38),
        bottomRight: Radius.circular(38),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 7.h),
        Text('Wallet', style: h3TextStyle.copyWith(color:isdarkmode ? textBlack : textWhite)),
        SizedBox(height: 4.h),
        Container(
          height: 5.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: isdarkmode ? textBlack :textWhite,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
          ),
          child: Center(
            child: Text(
              'Available Balance'.toUpperCase(),
              style: body3TextStyle.copyWith(
                  color: primaryColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 10.h,width: 15.w,
              child: Image.asset('assets/images/wallet.png')),
            Text(
              ' ${WalletController.wallet!.amount!.toStringAsFixed(2)} '?? '21324',
              style: h3TextStyle.copyWith(color: isdarkmode ? textBlack: textWhite),
            ),
          ],
        )
      ],
    ),
  );
}
