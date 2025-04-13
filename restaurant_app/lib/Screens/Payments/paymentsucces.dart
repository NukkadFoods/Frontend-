import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class Paymentsucces extends StatelessWidget{
  Paymentsucces({required this.orderId});

  final String orderId;
  @override
  Widget build(BuildContext context) {
   return Scaffold(
    resizeToAvoidBottomInset:false,
    body: Stack(
      children: [
        Image.asset('assets/images/otpbg.png'),
       Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/animation.json'),
          Text('Payment Completed!',style: TextStyle(color: Colors.green,fontSize: 25,fontWeight: FontWeight.bold),),
          SizedBox(height: 30,),
          Text('Yay! your payment for orderId: $orderId was completed. your order will be processed soon.',textAlign: TextAlign.center,style:TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.w600))
        ],
      ),
      ]
    ),
   );
  }
}