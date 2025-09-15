import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/order/orders_model.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

class ViewTotalBillWidget extends StatelessWidget {
  const ViewTotalBillWidget({super.key, required this.order});
  final Orders order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Bill',
            style: h4TextStyle.copyWith(color: primaryColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 19.sp,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100.w,
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2.h, color: textGrey3),
                    color: textGray4,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: textGrey3.withOpacity(0.5), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset:
                            Offset(0, 3), // Offset in the x and y directions
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maxLines: 1,
                        'Your order',
                        style: body4TextStyle.copyWith(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      for (var item in order.orderData!.items!)
                        Wrap(children: [
                          Text(
                            maxLines: 1,
                            '${item.itemQuantity} x ${item.itemName}',
                            style: body4TextStyle.copyWith(
                                color: textBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                maxLines: 1,
                                '${item.itemQuantity} x ₹ ${item.unitCost}',
                                style: body4TextStyle.copyWith(
                                    color: textGrey2,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.start,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Text(
                                  maxLines: 1,
                                  '₹ ${item.itemQuantity! * item.unitCost!}',
                                  style: body6TextStyle.copyWith(
                                      color: textGrey2,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                        ]),
                    ],
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  width: 100.w,
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2.h, color: textGrey3),
                    color: textGray4,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: textGrey3.withOpacity(0.5), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset:
                            Offset(0, 3), // Offset in the x and y directions
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.fastfood_outlined,
                                color: primaryColor,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Text(
                                'Order Value',
                                style: body6TextStyle.copyWith(
                                  letterSpacing: 0.7,
                                  fontSize: 14,
                                  color: textBlack,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Text(
                            maxLines: 1,
                            '₹ ${order.orderData!.billingDetail!['order_value'].toStringAsFixed(2)}',
                            style: body6TextStyle.copyWith(
                                color: textBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.comments_disabled_outlined,
                                color: primaryColor,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Text(
                                'Nukkad Food Commission',
                                style: body6TextStyle.copyWith(
                                  // letterSpacing: 0.7,
                                  fontSize: 14,
                                  color: textBlack,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Text(
                            maxLines: 1,
                            '- ₹ ${order.orderData!.billingDetail!['nukkadfoods_comission']}',
                            style: body6TextStyle.copyWith(
                                color: textBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.money,
                                color: primaryColor,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Text(
                                'Current Earning',
                                style: body6TextStyle.copyWith(
                                  // letterSpacing: 0.7,
                                  fontSize: 14,
                                  color: textBlack,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Text(
                            maxLines: 1,
                            '₹ ${order.orderData!.billingDetail!['nukkad_earning']}',
                            style: body6TextStyle.copyWith(
                                color: textBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      if (order.orderData!.billingDetail!['discount'] != null &&
                          order.orderData!.billingDetail!['discount'] > 0)
                        SizedBox(
                          height: 2.h,
                        ),
                      if (order.orderData!.billingDetail!['discount'] != null &&
                          order.orderData!.billingDetail!['discount'] > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.discount_outlined,
                                  color: primaryColor,
                                ),
                                SizedBox(
                                  width: 3.w,
                                ),
                                Text(
                                  'Discount',
                                  style: body6TextStyle.copyWith(
                                    // letterSpacing: 0.7,
                                    fontSize: 14,
                                    color: textBlack,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            Text(
                              maxLines: 1,
                              '- ₹ ${order.orderData!.billingDetail!['discount']}',
                              style: body6TextStyle.copyWith(
                                  color: textBlack,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on_outlined,
                                color: primaryColor,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Text(
                                order.orderData!.billingDetail!['latePrep'] !=
                                        null
                                    ? order.orderData!
                                            .billingDetail!['latePrep']
                                        ? "Earning for preparing late"
                                        : "Earning for preparing on time"
                                    : 'Earning if prepared on time',
                                style: body6TextStyle.copyWith(
                                  // letterSpacing: 0.7,
                                  fontSize: 14,
                                  color: textBlack,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Text(
                            maxLines: 1,
                            '₹ ${order.orderData!.billingDetail!['latePrep'] == true ? 0.00 : order.orderData!.billingDetail!['nukkad_wallet_cash']}',
                            style: body6TextStyle.copyWith(
                                color: textBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Divider(
                        color: textGrey2,
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.2.h, color: colorSuccess),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              // colorSuccess1,
                              colorSuccess2,
                              colorSuccess3
                            ],
                          ),
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  colorSuccess.withOpacity(0.5), // Shadow color
                              spreadRadius: 1, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset: Offset(
                                  0, 2), // Offset in the x and y directions
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              maxLines: 1,
                              'Grand Total'.toUpperCase(),
                              style: body6TextStyle.copyWith(
                                  color: textWhite,
                                  letterSpacing: 1.5,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              '₹ ${((order.orderData!.billingDetail!['latePrep'] == true ? 0.00 : order.orderData!.billingDetail!['nukkad_wallet_cash']).toDouble() + order.orderData!.billingDetail!['nukkad_earning'].toDouble() - (order.orderData!.billingDetail!['discount'] ?? 0)).toStringAsFixed(2)}',
                              style: body6TextStyle.copyWith(
                                // letterSpacing: 0.7,
                                fontSize: 16,
                                color: textWhite,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(
                //       horizontal: 2.w, vertical: 2.h),
                //   decoration: BoxDecoration(
                //     border: Border.all(width: 0.2.h, color: colorBlue2),
                //     gradient: LinearGradient(
                //       begin: Alignment.centerLeft,
                //       end: Alignment.centerRight,
                //       colors: [colorBlue2, colorBlue3],
                //     ),
                //     borderRadius: BorderRadius.circular(7),
                //     boxShadow: [
                //       BoxShadow(
                //         color:
                //             colorBlue2.withOpacity(0.5), // Shadow color
                //         spreadRadius: 1, // Spread radius
                //         blurRadius: 5, // Blur radius
                //         offset: Offset(
                //             0, 2), // Offset in the x and y directions
                //       ),
                //     ],
                //   ),
                //   child: Row(
                //     children: [
                //       Image.asset(
                //         'assets/images/SVGRepo_congret.png',
                //       ),
                //       SizedBox(
                //         width: 3.w,
                //       ),
                //       Text(
                //         'Yay! You saved ₹20 on this order',
                //         style: h5TextStyle.copyWith(
                //           // letterSpacing: 0.7,
                //           fontSize: 15,
                //           color: textWhite,
                //           // fontWeight: FontWeight.w400,
                //         ),
                //         textAlign: TextAlign.center,
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(
                //   height: 2.h,
                // ),
                // if (order.orderData!.billingDetail!['latePrep'] == null)
                Container(
                  width: 100.w,
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2.h, color: colorPink2),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        colorPink1,
                        colorPink2,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: colorPink2.withOpacity(0.5), // Shadow color
                        spreadRadius: 1, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset:
                            Offset(0, 2), // Offset in the x and y directions
                      ),
                    ],
                  ),
                  child: order.orderData!.billingDetail!['latePrep'] != null
                      ? order.orderData!.billingDetail!['latePrep']
                          ? Text(
                              "Oops!, Lost ₹ ${order.orderData!.billingDetail!['nukkad_wallet_cash']} for preparing order late.\nPrepare Orders on time to avail this extra earning reward.",
                              style: h5TextStyle.copyWith(color: Colors.white))
                          : Text(
                              "Wohoo! 🎉🎉, Got ₹ ${order.orderData!.billingDetail!['nukkad_wallet_cash']} for preparing order on time.",
                              style: h5TextStyle.copyWith(color: Colors.white),
                            )
                      : Column(
                          children: [
                            // Icon(
                            //   Icons.money,
                            //   color: primaryColor,
                            // ),
                            // SizedBox(
                            //   width: 3.w,
                            // ),
                            Text(
                              'Prepare this order on time ',
                              style: h5TextStyle.copyWith(
                                // letterSpacing: 0.7,
                                fontSize: 15,
                                color: colorwarnig,
                                // fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Text(
                              'And',
                              style: h5TextStyle.copyWith(
                                // letterSpacing: 0.7,
                                // fontSize: 15,
                                color: textWhite,
                                // fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Row(
                              children: [
                                Image.asset('assets/images/wallet2.png'),
                                Text(
                                  'Get ${order.orderData!.billingDetail!['nukkad_wallet_cash']} cash in Nukkad wallet!',
                                  style: h5TextStyle.copyWith(
                                    // letterSpacing: 0.7,
                                    fontSize: 15,
                                    color: textWhite,
                                    // fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
