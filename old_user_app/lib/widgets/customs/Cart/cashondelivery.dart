import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/screens/payment/payment_option.dart';

import '../../../Controller/food/model/cart_model.dart';

class CashOnDelivery extends StatefulWidget {
  final List<CartModel> cartList;

  const CashOnDelivery({
    super.key,
    required this.cartList,
    required this.restaurantname,
    required this.drivertip,
    required this.totalprice,
  });
  final String restaurantname;
  final double? drivertip;
  final double? totalprice;
  @override
  _CashOnDeliveryState createState() => _CashOnDeliveryState();
}

class _CashOnDeliveryState extends State<CashOnDelivery> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: false, // Allows for full screen height
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            builder: (BuildContext context) {
              return PaymentOptionsScreen(
                  restuarantname: widget.restaurantname,
                  totalprice: widget.totalprice!);
            },
          );
        },
        child: Material(
      
          elevation: 3,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: textGrey2,
                width: 0.2.h,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/cod.png',
                  height: 2.h,
                ),
                SizedBox(width: 1.w),
                Container(
                  width: 30.w,
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash On Delivery',
                        style: body4TextStyle.copyWith(
                          fontSize: 10.sp,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        'View other payment options',
                        style: body6TextStyle.copyWith(color:textGrey2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
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
}
