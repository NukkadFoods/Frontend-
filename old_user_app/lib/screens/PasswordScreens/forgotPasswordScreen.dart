// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:user_app/Widgets/buttons/mainButton.dart';
// import 'package:user_app/Widgets/constants/colors.dart';
// import 'package:user_app/Widgets/constants/texts.dart';
// import 'package:user_app/screens/otpScreen.dart';
// import 'package:user_app/widgets/input_fields/phoneField.dart';

// import '../loginScreen.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   final String userNumber;
//   const ForgotPasswordScreen({super.key, required this.userNumber});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   String enteredNumber = '';
//   final TextEditingController phoneController = TextEditingController();

//   void routeNext(String userNumber) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OTPScreen(
//           userNumber: userNumber,
//           option: 1,
//           otp: '1234',
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     String userNumber = widget.userNumber;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const LoginScreen(),
//               ),
//             );
//           },
//           icon: Icon(
//             Icons.arrow_back_ios,
//             size: 19.sp,
//             color: Colors.black,
//           ),
//         ),
//         title: Text('Forgot Password', style: h4TextStyle),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 5.w),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 'Verify your phone number ${'${userNumber.substring(userNumber.length - 3)}XXXXXXX'} linked to your account and enter otp to recover your account.',
//                 style: body4TextStyle,
//                 textAlign: TextAlign.center,
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               Padding(
//                 padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
//                 child: phoneField(
                  
//                   (String number) {
//                     setState(() {
//                       enteredNumber = number;
//                     });
//                   },
                  
//                   controller: phoneController,
//                 ),
//               ),
//               mainButton(
//                 'Send OTP',
//                 textWhite,
//                 () => routeNext(enteredNumber),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
