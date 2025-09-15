// import 'dart:ui';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
// import 'package:restaurant_app/Screens/Subscription/activeSub_card.dart';
// import 'package:restaurant_app/Screens/Subscription/subscribe_card.dart';
// import 'package:restaurant_app/Screens/Subscription/validSubscription_card.dart';
// import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
// import 'package:restaurant_app/Widgets/constants/colors.dart';
// import 'package:restaurant_app/Widgets/constants/texts.dart';
// import 'package:restaurant_app/homeScreen.dart';
// import 'package:sizer/sizer.dart';

// class ActiveSubscription extends StatefulWidget {
//   const ActiveSubscription({super.key});

//   @override
//   State<ActiveSubscription> createState() => _ActiveSubscriptionState();
// }

// class _ActiveSubscriptionState extends State<ActiveSubscription> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const ActiveSubscriptionScreen(),
//               Padding(
//                 padding: EdgeInsets.fromLTRB(5.w, 6.h, 5.w, 2.h),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 100.w,
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
//                       decoration: BoxDecoration(
//                         border: Border.all(width: 0.2.h, color: primaryColor),
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(7),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(
//                             child: Image.asset(
//                                 'assets/images/valid_subscription.png'),
//                           ),
//                           SizedBox(height: 2.h),
//                           Text(
//                             'Subscription Active',
//                             style: body3TextStyle.copyWith(
//                                 color: primaryColor,
//                                 fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: 4.h,
//                     ),
//                     ValidSubscribeCard(),
//                     Align(
//                       alignment: Alignment.center,
//                       child: Padding(
//                         padding: EdgeInsets.only(top: 3.h, bottom: 2.h),
//                         child: Text(
//                           'You can use wallet cash to renew your subscription after it expirres to continue recieving orders.',
//                           style: body5TextStyle.copyWith(
//                               fontWeight: FontWeight.w600),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   routeHome() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const HomeScreen(),
//       ),
//     );
//   }
// }
