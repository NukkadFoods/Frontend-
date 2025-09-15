// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:user_app/Screens/PasswordScreens/forgotPasswordScreen.dart';
// import 'package:user_app/Widgets/constants/colors.dart';
// import 'package:user_app/widgets/constants/texts.dart';

// Widget forgotPassButton(String userNumber, BuildContext context) {
//   return Center(
//     child: TextButton(
//       onPressed: () {
//         if (userNumber != '') {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) =>
//                   ForgotPasswordScreen(userNumber: userNumber),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context)
//             ..hideCurrentSnackBar()
//             ..showSnackBar(
//               SnackBar(
//                 duration: const Duration(seconds: 4),
//                 content: SizedBox(
//                   height: 3.h,
//                   child: Text(
//                     'Enter Phone Number',
//                     style: body4TextStyle,
//                   ),
//                 ),
//                 backgroundColor: colorFailure,
//               ),
//             );
//         }
//       },
//       style: ButtonStyle(
//         overlayColor: WidgetStateProperty.all(Colors.transparent),
//       ),
//       child: Text(
//         'Forgot Password ?',
//         style: body4TextStyle.copyWith(color: primaryColor),
//       ),
//     ),
//   );
// }
