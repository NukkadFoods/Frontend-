import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';

Widget offersSlider(String headerText, List offerData,BuildContext context) {
   bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  return Container(
    height: 13.h,
    margin: EdgeInsets.symmetric(vertical: 1.h),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 1.h),
          child: Text(headerText.toUpperCase(), style:isdarkmode ?titleTextStyle.copyWith(fontSize: 12.sp,color: textWhite): titleTextStyle.copyWith(fontSize: 13.sp)),
        ),
        SizedBox(
          height: 7.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 50.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF5dcbfd),
                        Color(0xFF5e64e5),
                        Color(0xFF6200d0)
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/discount_icon.svg',
                          color: Colors.white, height: 4.h, width: 4.h),
                      SizedBox(width: 2.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upto 60% off',
                              style: h5TextStyle.copyWith(color: textWhite)),
                          Text('On select restaurants',
                              style: body5TextStyle.copyWith(color: textWhite)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 50.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFf9e84c),
                        Color(0xFFf59c2b),
                        Color(0xFFf06217)
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/suprise_box_icon.svg',
                          height: 4.h, width: 4.h),
                      SizedBox(width: 2.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upto 60% off',
                              style: h5TextStyle.copyWith(color: textWhite)),
                          Text('On select restaurants',
                              style: body5TextStyle.copyWith(color: textWhite)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}
