import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/Cart/Couponpage.dart';

Widget couponapply(
    BuildContext context,
    Function(String? selectedCoupon, num discountApplied) onCouponApplied,
    double price,
    String resid,
    String? couponApplied,
    bool isdarkmode) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CouponpageScreen(
                price: price, resid: resid, couponCode: couponApplied),
          ),
        ).then((result) {
          if (result != null) {
            String? selectedCoupon = result['selectedCoupon'];
            num discountApplied = result['discountApplied'];
            couponApplied = selectedCoupon;
            // Call the callback function with the selected coupon and discount
            onCouponApplied(selectedCoupon, discountApplied);
          }
        });
      },
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/applycoupon.svg',
                    height: 2.h,
                    colorFilter: ColorFilter.mode(
                        isdarkmode ? textGrey2 : textBlack, BlendMode.srcIn),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                      couponApplied != null
                          ? "Coupon Applied   "
                          : 'Apply Coupon',
                      style: h5TextStyle.copyWith(
                          fontSize: 12.sp,
                          color: isdarkmode ? textGrey2 : textBlack)),
                  if (couponApplied != null)
                    const Icon(Icons.check_circle, color: Colors.green)
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
              )
            ],
          ),
        ),
      ),
    ),
  );
}
