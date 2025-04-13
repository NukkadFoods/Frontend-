import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/order/orders_model.dart';
import 'package:user_app/widgets/constants/colors.dart';

class EffectiveBillWidget extends StatelessWidget {
  const EffectiveBillWidget({super.key,required this.orderCost, required this.order});
  final Map? orderCost;
  final Orders order;

  @override
  Widget build(BuildContext context) {
     bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return orderCost == null ? CircularProgressIndicator(color: primaryColor,) :
          orderCost!['customer_wallet_cash_earned'] ==0  ? SizedBox.shrink() :
     Padding(
      padding:  EdgeInsets.symmetric(horizontal: 5.w,vertical: 1.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w,vertical: 1.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: const LinearGradient(
            colors: [Colors.orangeAccent, Color.fromARGB(255, 255, 200, 0)],
            begin: Alignment.bottomCenter,
            end:Alignment.topCenter ,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orangeAccent.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EFFECTIVE BILL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:isdarkmode ? textBlack: Colors.white,
                  ),
                ),
                Text(
                  '₹${order.totalCost! - orderCost!['customer_wallet_cash_earned']}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:isdarkmode ? textBlack: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              'After receiving reward in wallet',
              style: TextStyle(
                fontSize: 14,
                color:isdarkmode ? textBlack.withOpacity(0.8) : Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
