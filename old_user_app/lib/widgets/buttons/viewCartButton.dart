import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/toasts.dart';

Widget viewCartButton(counter, Function() route, double price,bool isdarkmode) {
  return Container(
    height: 5.8.h,
    padding: EdgeInsets.symmetric(horizontal: 2.w),
    child: Material(
      borderRadius: BorderRadius.circular(8),
      elevation: 10,
      child: GestureDetector(
        onTap: () => price < 70 ? Toast.showToast(message:  "Minimum cart Total should be greater than ₹ 70 to place order",isError: true) : route(),
        child: Container(
          // width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: primaryColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        counter == 1 ? '$counter item' : '$counter items',
                        style: h5TextStyle.copyWith(color:isdarkmode ? textBlack: textWhite,fontSize: 13.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 1.5.h, horizontal: 2.w),
                      height: double.infinity,
                      width: 0.4.w,
                      color: isdarkmode? textBlack :textWhite,
                    ),
                    Expanded(
                      // flex: 2,
                      child: Text(
                        '₹ ${price.toStringAsFixed(1)}',
                        style: h5TextStyle.copyWith(color:isdarkmode ? textBlack: textWhite,fontSize: 13.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'View Cart',
                        style: h5TextStyle.copyWith(color:isdarkmode ? textBlack: textWhite,fontSize: 13.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.shopping_cart_rounded,
                      color:isdarkmode ? textBlack : Colors.white,
                      size: 17.sp,
                    ),
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color:isdarkmode? textBlack: Colors.white,
                      size: 22.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
