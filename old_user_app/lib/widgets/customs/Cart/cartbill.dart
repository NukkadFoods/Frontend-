import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/cart_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/providers/global_provider.dart';

Widget CartBill(BuildContext context, Map? orderCost, discount, double distance,
    {required List<CartModel> cartModelList,
    double? walletCashUsed,
    required bool isDelivery}) {
  return GestureDetector(
    child: GestureDetector(
      onTap: () {
        if (orderCost != null) {
          _showDetailedBillBottomSheet(context, orderCost, discount,
              cartModelList, walletCashUsed, distance, isDelivery);
        }
      },
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
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
                'assets/icons/view_bill_icon.png',
                color: primaryColor,
                height: 2.h,
              ),
              SizedBox(width: 2.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View Detailed Bill',
                    style: body4TextStyle.copyWith(
                      fontSize: 12.sp, // make 10.sp
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    'Inc. Taxes, fees, and charges',
                    style: body6TextStyle.copyWith(color: textGrey2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: primaryColor,
              )
            ],
          ),
        ),
      ),
    ),
  );
}

void _showDetailedBillBottomSheet(
    BuildContext context,
    Map orderCost,
    discount,
    List<CartModel> cartModelList,
    double? walletCashUsed,
    double distance,
    bool isDelivery) {
  bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  double taxes = orderCost["gst"];
  double handlingCharges = orderCost['handling_charges'] ?? 0;
  double deliveryFee = orderCost['delivery_fee'].toDouble();
  double total = orderCost["total"].roundToDouble();
  if (!isDelivery) {
    total = total - deliveryFee - handlingCharges;
    deliveryFee = 0;
    handlingCharges = 0;
  }
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          width: 100.w,
          decoration: BoxDecoration(
            image: const DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      'Total Bill',
                      style: h4TextStyle.copyWith(color: primaryColor),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        color: primaryColor,
                        size: 20.sp,
                        weight: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: textGrey2, width: 0.2.h),
                    borderRadius: BorderRadius.circular(10),
                    color: isdarkmode ? textGrey1 : const Color(0xfff7f7f7),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Order',
                          style: h5TextStyle.copyWith(color: primaryColor),
                        ),
                        cartModelList.isNotEmpty
                            ? ListView.separated(
                                shrinkWrap: true,
                                itemCount: cartModelList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) => Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildCustomTextWidget(
                                              text:
                                                  '${cartModelList[index].itemQuantity} x ${cartModelList[index].itemName}',
                                              isdarkmode: isdarkmode,
                                            ),
                                            _buildCustomTextWidget(
                                                text:
                                                    '1 x ₹${cartModelList[index].unitCost}',
                                                style: body4TextStyle.copyWith(
                                                    color: textGrey2),
                                                isdarkmode: isdarkmode),
                                          ]),
                                    ),
                                    _buildCustomTextWidget(
                                        flex: 0,
                                        text:
                                            '₹ ${(cartModelList[index].itemQuantity * cartModelList[index].unitCost)}',
                                        isdarkmode: isdarkmode),
                                  ],
                                ),
                                separatorBuilder: (context, index) => SizedBox(
                                  height: 2.h,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  )),
              SizedBox(
                height: 3.h,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  border: Border.all(color: textGrey2, width: 0.2.h),
                  borderRadius: BorderRadius.circular(10),
                  color: isdarkmode ? textGrey1 : const Color(0xfff7f7f7),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left side: Icon and text
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/food_home_icon.svg',
                                color: primaryColor,
                                height: 4.h,
                              ),
                              SizedBox(
                                  width: 2.w), // Space between icon and text
                              Text(
                                'Item Total',
                                style: body4TextStyle.copyWith(
                                    fontWeight: FontWeight.w300,
                                    color: isdarkmode ? textGrey2 : textBlack),
                              ),
                            ],
                          ),
                          // Right side: Price
                          Text(
                            '₹ ${orderCost['order_value']}',
                            style: body4TextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isdarkmode ? textGrey2 : textBlack),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left side: Icon and text
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/gst_taxes_icon.svg',
                                color: primaryColor,
                                height: 4.h,
                              ),
                              SizedBox(
                                  width: 2.w), // Space between icon and text
                              Text(
                                'GST & Taxes',
                                style: body4TextStyle.copyWith(
                                    fontWeight: FontWeight.w300,
                                    color: isdarkmode ? textGrey2 : textBlack),
                              ),
                            ],
                          ),
                          // Right side: Price
                          Text(
                            '₹ ${taxes.toStringAsFixed(2)}',
                            style: body4TextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isdarkmode ? textGrey2 : textBlack),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/distance.svg',
                                colorFilter: const ColorFilter.mode(
                                    primaryColor, BlendMode.srcIn),
                                height: 4.h,
                              ),
                              SizedBox(
                                  width: 2.w), // Space between icon and text
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      showDeliveryDetails(
                                          context, orderCost, distance);
                                    },
                                    child: Text(
                                      'Delivery Fee',
                                      style: body4TextStyle.copyWith(
                                          fontWeight: FontWeight.w300,
                                          color: isdarkmode
                                              ? textGrey2
                                              : textBlack,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                  Text(
                                    'For ${distance < 1 ? "0.5-0.9" : distance.toStringAsFixed(2)}km',
                                    style: body5TextStyle.copyWith(
                                        color: textGrey2),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '₹ ${(deliveryFee + orderCost['shortValueOrder'] + orderCost['longDistanceCharge']).toStringAsFixed(2)}',
                            style: body4TextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isdarkmode ? textGrey2 : textBlack),
                          ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding:
                    //       EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       // Left side: Icon and text
                    //       Row(
                    //         children: [
                    //           SvgPicture.asset(
                    //             'assets/icons/handling_icon.svg',
                    //             color: primaryColor,
                    //             height: 4.h,
                    //           ),
                    //           SizedBox(
                    //               width: 2.w), // Space between icon and text
                    //           Tooltip(
                    //             verticalOffset: 10,
                    //             showDuration: const Duration(seconds: 5),
                    //             preferBelow: false,
                    //             margin: EdgeInsets.symmetric(
                    //                 horizontal:
                    //                     MediaQuery.sizeOf(context).width * .2),
                    //             triggerMode: TooltipTriggerMode.tap,
                    //             message:
                    //                 "It depends upon the delivery distance and number of items",
                    //             child: Text(
                    //               'Handling Charges',
                    //               style: body4TextStyle.copyWith(
                    //                   fontWeight: FontWeight.w300,
                    //                   color: isdarkmode ? textGrey2 : textBlack,
                    //                   decoration: TextDecoration.underline),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       // Right side: Price
                    //       Text(
                    //         '₹ ${handlingCharges.toStringAsFixed(2)}',
                    //         style: body4TextStyle.copyWith(
                    //             fontWeight: FontWeight.w600,
                    //             color: isdarkmode ? textGrey2 : textBlack),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    if (orderCost['shortValueOrder'] +
                            orderCost['longDistanceCharge'] +
                            orderCost['packing_charges'] +
                            orderCost['surge'] >
                        0)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.h, horizontal: 5.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left side: Icon and text
                            Row(
                              children: [
                                Icon(
                                  Icons.miscellaneous_services_outlined,
                                  color: primaryColor,
                                  size: 4.h,
                                ),
                                SizedBox(
                                    width: 2.w), // Space between icon and text
                                InkWell(
                                  onTap: () {
                                    showMiscDetails(
                                        context, orderCost, distance);
                                  },
                                  child: Text(
                                    'Misc Charges',
                                    style: body4TextStyle.copyWith(
                                        fontWeight: FontWeight.w300,
                                        color:
                                            isdarkmode ? textGrey2 : textBlack,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                            // Right side: Price
                            Text(
                              '₹ ${(orderCost['surge'] + handlingCharges + orderCost['packing_charges']).toDouble().toStringAsFixed(2)}',
                              style: body4TextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isdarkmode ? textGrey2 : textBlack),
                            ),
                          ],
                        ),
                      ),
                    // Padding(
                    //   padding:
                    //       EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       // Left side: Icon and text
                    //       Row(
                    //         children: [
                    //           SvgPicture.asset(
                    //             'assets/icons/orders_icon.svg',
                    //             color: primaryColor,
                    //             height: 4.h,
                    //           ),
                    //           SizedBox(
                    //               width: 2.w), // Space between icon and text
                    //           Tooltip(
                    //             verticalOffset: 10,
                    //             showDuration: const Duration(seconds: 5),
                    //             preferBelow: false,
                    //             margin: EdgeInsets.symmetric(
                    //                 horizontal:
                    //                     MediaQuery.sizeOf(context).width * .2),
                    //             triggerMode: TooltipTriggerMode.tap,
                    //             message:
                    //                 "Packaging charges may vary for each item.",
                    //             child: Text(
                    //               'Packaging Charges',
                    //               style: body4TextStyle.copyWith(
                    //                   fontWeight: FontWeight.w300,
                    //                   color: isdarkmode ? textGrey2 : textBlack,
                    //                   decoration: TextDecoration.underline),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       // Right side: Price
                    //       Text(
                    //         '₹ ${orderCost['packing_charges'].toDouble().toStringAsFixed(2)}',
                    //         style: body4TextStyle.copyWith(
                    //             fontWeight: FontWeight.w600,
                    //             color: isdarkmode ? textGrey2 : textBlack),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Padding(
                    //   padding:
                    //       EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       Row(
                    //         children: [
                    //           SvgPicture.asset(
                    //             'assets/icons/distance_fee_icon.svg',
                    //             color: primaryColor,
                    //             height: 4.h,
                    //           ),
                    //           SizedBox(
                    //               width: 2.w), // Space between icon and text
                    //           Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text(
                    //                 'Delivery Fee',
                    //                 style: body4TextStyle.copyWith(
                    //                     fontWeight: FontWeight.w300,
                    //                     color:
                    //                         isdarkmode ? textGrey2 : textBlack),
                    //               ),
                    //               Text(
                    //                 'For ₹220',
                    //                 style: body5TextStyle.copyWith(
                    //                     color: textGrey2),
                    //               ),
                    //             ],
                    //           ),
                    //         ],
                    //       ),
                    //       Text(
                    //         '₹ $deliveryFee',
                    //         style: body4TextStyle.copyWith(
                    //             fontWeight: FontWeight.w600,
                    //             color: isdarkmode ? textGrey2 : textBlack),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    Divider(
                      color: textGrey2,
                      thickness: 0.2.h,
                      indent: 5.w,
                      endIndent: 5.w,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/coupon_icon.svg',
                                color: primaryColor,
                                height: 4.h,
                              ),
                              SizedBox(
                                  width: 2.w), // Space between icon and text
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Coupon Discount',
                                    style: body4TextStyle.copyWith(
                                        fontWeight: FontWeight.w300,
                                        color:
                                            isdarkmode ? textGrey2 : textBlack),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '- ₹ ${discount}',
                            style: body4TextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.h, horizontal: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/wallet_icon.svg',
                                color: primaryColor,
                                height: 3.h,
                              ),
                              SizedBox(
                                  width: 2.w), // Space between icon and text
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wallet cash used',
                                    style: body4TextStyle.copyWith(
                                        fontWeight: FontWeight.w300,
                                        color:
                                            isdarkmode ? textGrey2 : textBlack),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            ' - ₹ ${walletCashUsed ?? 0}',
                            style: body4TextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: textGrey2,
                      thickness: 0.2.h,
                      indent: 5.w,
                      endIndent: 5.w,
                    ),
                    Container(
                      height: 6.h,
                      margin:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFe7ffe5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colorSuccess),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: h4TextStyle.copyWith(color: colorSuccess),
                          ),
                          Text(
                            '₹ ${(total - discount - (walletCashUsed ?? 0)).toStringAsFixed(2)}',
                            style: h4TextStyle.copyWith(color: colorSuccess),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 1.h,
              )
              // SavingsWidget(isdarkmode)
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildCustomTextWidget({
  required String text,
  TextStyle? style,
  int? flex,
  bool? isdarkmode = false,
}) =>
    Row(
      children: [
        Expanded(
          flex: flex ?? 1,
          child: Text(
            text,
            style: style ??
                h6TextStyle.copyWith(
                    color: isdarkmode! ? textGrey2 : textBlack),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

void showDeliveryDetails(BuildContext context, Map orderCost, double distance) {
  showDialog(
      context: context,
      builder: (context) => Dialog(
            insetPadding: const EdgeInsets.all(15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    dense: true,
                    minTileHeight: 0,
                    title: Text(
                      "Delivery Fee for ${distance < 1 ? "0.5-0.9" : distance.toStringAsFixed(2)} Km",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    trailing: Text(
                      "₹${orderCost['dDist'].toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    minTileHeight: 0,
                    title: Text(
                      "Delivery Fee on order of ₹${orderCost['order_value'].toInt()}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    trailing: Text(
                      "₹${orderCost['dov'].toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  if (orderCost['longDistanceCharge'] > 0)
                    ListTile(
                      minTileHeight: 0,
                      dense: true,
                      title: const Text(
                        "Long Distance Fee ",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      subtitle: const Text(
                        'Charged from 8 Km onwards',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        "₹${orderCost['longDistanceCharge'].toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                    ),
                  if (orderCost['shortValueOrder'] > 0)
                    ListTile(
                      minTileHeight: 0,
                      dense: true,
                      title: const Text(
                        "Small Order Fee ",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      subtitle: Text(
                        context
                            .read<GlobalProvider>()
                            .constants['smallOrderText'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        "₹${orderCost['shortValueOrder'].toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                    )
                ],
              ),
            ),
          ));
}

void showMiscDetails(BuildContext context, Map orderCost, double distance) {
  showDialog(
      context: context,
      builder: (context) => Dialog(
            insetPadding: const EdgeInsets.all(15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    dense: true,
                    minTileHeight: 0,
                    title: const Text(
                      "Packing Charges",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    trailing: Text(
                      "₹${orderCost['packing_charges'].toDouble().toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  ListTile(
                    minTileHeight: 0,
                    dense: true,
                    title: const Text(
                      "Handling Charges",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    trailing: Text(
                      "₹${orderCost['handling_charges'].toDouble().toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  if (orderCost['surge'] > 0)
                    ListTile(
                      minTileHeight: 0,
                      dense: true,
                      title: const Text(
                        "Surge",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      subtitle: Text(
                        context.read<GlobalProvider>().constants['surgeInfo']
                                [orderCost['surgeType'] ?? "none"] ??
                            'Applied as order placed at Midnight',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        "₹${orderCost['surge'].toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                    )
                ],
              ),
            ),
          ));
}
