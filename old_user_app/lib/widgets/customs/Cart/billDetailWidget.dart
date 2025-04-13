// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:sizer/sizer.dart';
// import 'package:user_app/Controller/order/order_cost_calc.dart';
// import 'package:user_app/Controller/order/orders_model.dart';
// import 'package:user_app/Widgets/constants/colors.dart';
// import 'package:user_app/Widgets/constants/texts.dart';
// import 'package:user_app/Widgets/customs/Cart/savingsWidget.dart';

// Widget detailedBill(BuildContext context, Orders orderCost) {
//    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
//   return GestureDetector(
//     child: GestureDetector(
//       onTap: () {
//         if (orderCost != null) {
//           _showDetailedBillBottomSheet(context, orderCost);
//         }
//       },
//       child: Material(
        
//         elevation: 3,
//         borderRadius: BorderRadius.circular(8),
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 5.w),
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: textGrey2,
//               width: 0.2.h,
//             ),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/icons/view_bill_icon.png',
//                 color: primaryColor,
//                 height: 3.5.h,
//               ),
//               SizedBox(width: 2.w),
//               Container(
//                 width: 55.w,
//                 padding: EdgeInsets.symmetric(vertical: 0.5.h),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'View Detailed Bill',
//                       style: body4TextStyle.copyWith(
//                         fontSize: 13.sp,
//                         color: primaryColor,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       textAlign: TextAlign.start,
//                     ),
//                     Text(
//                       'Inc. Taxes, fees, and charges',
//                       style: body6TextStyle.copyWith(color: isdarkmode ? textGrey2: textBlack),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       textAlign: TextAlign.start,
//                     ),
//                   ],
//                 ),
//               ),
//               const Spacer(),
//               GestureDetector(
//                 onTap: () {
//                   if (orderCost != null) {
//                     _showDetailedBillBottomSheet(context, orderCost);
//                   }
//                 },
//                 child: Icon(
//                   Icons.arrow_forward_ios_rounded,
//                   color: primaryColor,
//                   size: 16.sp,
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// void _showDetailedBillBottomSheet(
//     BuildContext context,  Orders orderCost) {
//   double taxes = orderCost.itemAmount! * .05;
//   double handlingCharges = orderCost.convinenceFee!.toDouble() ?? 0;
//   double deliveryFee = orderCost.deliveryCharge!.toDouble() ?? 0;
//   double foodtotal = orderCost.itemAmount!.toDouble();
//   double total = orderCost.totalCost!.toDouble() ?? 0;
//   showModalBottomSheet(
//     isScrollControlled: true,
//     context: context,
//     builder: (BuildContext context) {
//        bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
//       final color= isdarkmode ? textGrey2 : textBlack;
//       return SingleChildScrollView(
//         child: Container(
//           width: 100.w,
//           decoration: BoxDecoration(
//             image: const DecorationImage(
//                 image: AssetImage('assets/images/background.png')),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
//                 child: Row(
//                   children: [
//                     const Spacer(),
//                     Text(
//                       'Total Bill',
//                       style: h4TextStyle.copyWith(color: primaryColor),
//                     ),
//                     const Spacer(),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Icon(
//                         Icons.close,
//                         color: primaryColor,
//                         size: 20.sp,
//                         weight: 20,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 5.w),
//                 padding: EdgeInsets.symmetric(vertical: 2.h),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: textGrey2, width: 0.2.h),
//                   borderRadius: BorderRadius.circular(10),
                 
//                 ),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           // Left side: Icon and text
//                           Row(
//                             children: [
//                               SvgPicture.asset(
//                                 'assets/icons/food_home_icon.svg',
//                                 color: primaryColor,
//                                 height: 3.5.h,
//                               ),
//                               SizedBox(
//                                   width: 2.w), // Space between icon and text
//                               Text(
//                                 'Food Total',
//                                 style: body4TextStyle.copyWith(
//                                     fontWeight: FontWeight.bold,color: color),
//                               ),
//                             ],
//                           ),
//                           // Right side: Price
//                           Text(
//                             '₹ $foodtotal',
//                             style: body4TextStyle.copyWith(
//                                 fontWeight: FontWeight.bold,color: color),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           // Left side: Icon and text
//                           Row(
//                             children: [
//                               SvgPicture.asset(
//                                 'assets/icons/gst_taxes_icon.svg',
//                                 color: primaryColor,
//                                 height: 3.5.h,
//                               ),
//                               SizedBox(
//                                   width: 2.w), // Space between icon and text
//                               Text(
//                                 'GST & Taxes',
//                                 style: body4TextStyle.copyWith(
//                                     fontWeight: FontWeight.w300,color:  color),
//                               ),
//                             ],
//                           ),
//                           // Right side: Price
//                          Text(
//   '₹ ${taxes.toStringAsFixed(2)}',
//   style: body4TextStyle.copyWith(
//     fontWeight: FontWeight.bold,color: color
//   ),
// ),

//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           // Left side: Icon and text
//                           Row(
//                             children: [
//                               SvgPicture.asset(
//                                 'assets/icons/handling_icon.svg',
//                                 color: primaryColor,
//                                 height: 3.5.h,
//                               ),
//                               SizedBox(
//                                   width: 2.w), // Space between icon and text
//                               Text(
//                                 'Handling Charges',
//                                 style: body4TextStyle.copyWith(
//                                     fontWeight: FontWeight.w300,color: color),
//                               ),
//                             ],
//                           ),
//                           // Right side: Price
//                           Text(
//                             '₹ ${handlingCharges.toStringAsFixed(2)}',
//                             style: body4TextStyle.copyWith(
//                                 fontWeight: FontWeight.bold,color: color),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Row(
//                             children: [
//                               SvgPicture.asset(
//                                 'assets/icons/distance_fee_icon.svg',
//                                 color: primaryColor,
//                                 height:  3.5.h,
//                               ),
//                               SizedBox(
//                                   width: 2.w), // Space between icon and text
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Delivery Fee',
//                                     style: body4TextStyle.copyWith(
//                                         fontWeight: FontWeight.w300,color: color),
//                                   ),
//                                   Text(
//                                     'For ₹ ${foodtotal}',
//                                     style: body5TextStyle.copyWith(
//                                         color: textGrey2),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Text(
//                             '₹ $deliveryFee',
//                             style: body4TextStyle.copyWith(
//                                 fontWeight: FontWeight.bold,color: color),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Divider(
//                       color: textGrey2,
//                       thickness: 0.2.h,
//                       indent: 5.w,
//                       endIndent: 5.w,
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Row(
//                             children: [
//                               SvgPicture.asset(
//                                 'assets/icons/distance_fee_icon.svg',
//                                 color: primaryColor,
//                                 height:  3.5.h,
//                               ),
//                               SizedBox(
//                                   width: 2.w), // Space between icon and text
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Delivery Fee',
//                                     style: body4TextStyle.copyWith(
//                                         fontWeight: FontWeight.w300,color: color),
//                                   ),
//                                   Text(
//                                        'For ₹ ${foodtotal}',
//                                     style: body5TextStyle.copyWith(
//                                         color: textGrey2),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Text(
//                             '₹ $deliveryFee',
//                             style: body4TextStyle.copyWith(
//                                 fontWeight: FontWeight.bold,color: color),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Row(
//                             children: [
//                               SvgPicture.asset(
//                                 'assets/icons/distance_fee_icon.svg',
//                                 color: primaryColor,
//                                 height:  3.5.h,
//                               ),
//                               SizedBox(
//                                   width: 2.w), // Space between icon and text
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Delivery Fee',
//                                     style: body4TextStyle.copyWith(
//                                         fontWeight: FontWeight.w300,color: color),
//                                   ),
//                                   Text(
//                                      'For ₹ ${foodtotal}',
//                                     style: body5TextStyle.copyWith(
//                                         color: textGrey2),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Text(
//                             '₹ $deliveryFee',
//                             style: body4TextStyle.copyWith(
//                                 fontWeight: FontWeight.bold,color: color),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Divider(
//                       color: textGrey2,
//                       thickness: 0.2.h,
//                       indent: 5.w,
//                       endIndent: 5.w,
//                     ),
//                     Container(
//                       height: 6.h,
//                       margin:
//                           EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
//                       padding: EdgeInsets.symmetric(horizontal: 3.w),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFe7ffe5),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: colorSuccess),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Grand Total',
//                             style: h4TextStyle.copyWith(color: colorSuccess),
//                           ),
//                           Text(
//                             '₹ ${total.toStringAsFixed(2)}',
//                             style: h4TextStyle.copyWith(color: colorSuccess),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               //SavingsWidget(isdarkmode)
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
