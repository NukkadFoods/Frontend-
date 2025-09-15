import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';

Widget foodTypeToggle(Function(int) onTap, List<bool> isSelected,BuildContext context) {
   bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  List<String> types = [
    'Veg',
    'Non-Veg',
    'Vegan',
    'Gluten-Free',
    'Dairy Free',
  ];
  List<String> typeIcons = [
    'assets/icons/veg_icon.png',
    'assets/icons/non_veg_icon.png',
    'assets/icons/vegan_icon.png',
    'assets/icons/gluten_free_icon.png',
    'assets/icons/dairy_free_icon.png',
  ];
  return Padding(
    padding: EdgeInsets.only(left: 0.w),
    child: Container(
      height: 4.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: () {
              onTap(0);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: isSelected[0] ? isdarkmode ? textBlack : const Color.fromARGB(255, 225, 228, 225)  :isdarkmode ? textBlack : Colors.white ,
                border: Border.all(
                  color: Colors.green,
                  width: isSelected [0] ? 0.3.h : 0.2.h,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Center(
                child: Row(
                  children: [
                    Image.asset(typeIcons[0], height: 3.h),
                    SizedBox(width: 1.w),
                    Text(
                      types[0],
                      style: body5TextStyle.copyWith(fontSize: 12.sp,color: isdarkmode ? textGrey2 : textBlack),
                    ),
                     SizedBox(width: 2.w),
                    isSelected[0] ? Text('X',style: h6TextStyle.copyWith(color: isdarkmode ?textGrey2 : textBlack),): const Text(''),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              onTap(1);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: isSelected[1] ? isdarkmode ? textBlack : const Color.fromARGB(255, 225, 228, 225)  :isdarkmode ? textBlack : Colors.white ,
                border: Border.all(
                  color: primaryColor,
                  width:isSelected [1] ? 0.3.h : 0.2.h,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Center(
                child: Row(
                  children: [
                    Image.asset(typeIcons[1], height: 2.7.h),
                     SizedBox(width: 1.w),
                    Text(
                      types[1],
                      style: body4TextStyle.copyWith(color:isdarkmode ? textGrey2 : textBlack,fontSize: 12.sp),
                    ),
                     SizedBox(width: 2.w),
                    isSelected[1] ? Text('X',style: h6TextStyle.copyWith(color: isdarkmode ?textGrey2 : textBlack),): const Text(''),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              onTap(2);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: isSelected[2] ? isdarkmode ? textBlack : const Color.fromARGB(255, 225, 228, 225)  :isdarkmode ? textBlack : Colors.white ,
                border: Border.all(
                  color: Colors.green,
                  width:isSelected [2] ? 0.3.h : 0.2.h,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Center(
                child: Row(
                  children: [
                    Image.asset(typeIcons[2], height: 4.h),
                    Text(
                      types[2],
                      style: body4TextStyle.copyWith(color:isdarkmode ? textGrey2 : textBlack),
                    ),
                     SizedBox(width: 2.w),
                    isSelected[2] ? Text('X',style: h6TextStyle.copyWith(color: isdarkmode ?textGrey2 : textBlack),): const Text(''),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              onTap(3);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: isSelected[3] ? isdarkmode ? textBlack : const Color.fromARGB(255, 225, 228, 225)  :isdarkmode ? textBlack : Colors.white ,
                border: Border.all(
                  color: const Color(0xFFF39406),
                  width:  isSelected [3] ? 0.3.h : 0.2.h,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Center(
                child: Row(
                  children: [
                    Image.asset(typeIcons[3], height: 4.h),
                    Text(
                      types[3],
                      style: body4TextStyle.copyWith(color:isdarkmode ? textGrey2: textBlack),
                    ),
                     SizedBox(width: 2.w),
                    isSelected[3] ? Text('X',style: h6TextStyle.copyWith(color: isdarkmode ?textGrey2 : textBlack),): const Text(''),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              onTap(4);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: isSelected[4]? isdarkmode ? textBlack : const Color.fromARGB(255, 225, 228, 225)  :isdarkmode ? textBlack : Colors.white ,
                border: Border.all(
                  color: const Color.fromARGB(255, 76, 153, 175),
                  width: isSelected [4] ? 0.3.h : 0.2.h,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Center(
                child: Row(
                  children: [
                    Image.asset(typeIcons[4], height: 4.h),
                    Text(
                      types[4],
                      style: body4TextStyle.copyWith(color:isdarkmode ? textGrey2: textBlack),
                    ),
                     SizedBox(width: 2.w),
                    isSelected[4] ? Text('X',style: h6TextStyle.copyWith(color: isdarkmode ?textGrey2 : textBlack),): const Text(''),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
