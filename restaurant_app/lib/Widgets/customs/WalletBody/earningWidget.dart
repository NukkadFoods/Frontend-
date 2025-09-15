import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/texts.dart';

Widget earningsWidget(DateTime selectedDate, String? orderByName, String? time, String? status, double? totalCost) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
    child: Container(
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(color: textGrey2, width: 0.1.h),
      )),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  orderByName!,
                  style: body3TextStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 0.1.h, horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '${status}',
                    style: body4TextStyle.copyWith(
                      color: textWhite,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/timer_icon.svg'),
                    SizedBox(width: 2.w),
                    Text(
                      '${time}',
                      style: body4TextStyle.copyWith(color: textGrey2),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5.w),
              Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/route_icon.svg'),
                    SizedBox(width: 2.w),
                    Text(
                      '4.5 KM',
                      style: body4TextStyle.copyWith(color: textGrey2),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '₹ ${totalCost!.toStringAsFixed(2)}',
                style: h5TextStyle,
              ),
            ],
          ),
          SizedBox(height: 1.h),
        ],
      ),
    ),
  );
}
