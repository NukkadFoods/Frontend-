import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/Controller/walletcontroller.dart';

Widget WalletCash(bool? useWalletMoney, Map orderCost,
    void Function(bool?) onChanged, num totalPrice, bool isdarkmode) {
  return CheckboxListTile(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 45.w,
          child: Text(
            'Use Wallet Cash',
            style: h5TextStyle.copyWith(
                color: isdarkmode ? textGrey2 : textBlack,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(
          width: 18.w,
          child: Text(
            '₹${WalletController.wallet!.amount! > (orderCost['usable_wallet_cash']).toDouble().clamp(0, totalPrice) ? (orderCost['usable_wallet_cash']).toDouble().clamp(0, totalPrice).ceil() : WalletController.wallet!.amount!}',
            style: h5TextStyle.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
    value: useWalletMoney ?? false,
    onChanged: onChanged,
    activeColor: primaryColor,
    controlAffinity: ListTileControlAffinity.leading,
  );
}
