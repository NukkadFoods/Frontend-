
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class Paymentsucces extends StatelessWidget{
  const Paymentsucces({super.key});

  @override
  Widget build(BuildContext context) {
   return Scaffold(
    resizeToAvoidBottomInset:false,
    body: Container(
      child: Stack(
        children: [
          Image.asset('assets/images/background.png'),
         Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/payment.json'),
            const Text('Payment Completed!',style: TextStyle(color: Colors.green,fontSize: 25,fontWeight: FontWeight.bold),),
            const SizedBox(height: 30,),
            const Text('Yay! your payment was completed. your order will be processed soon.',textAlign: TextAlign.center,style:TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.w600))
          ],
        ),
        ]
      ),
    ),
   );
  }
}