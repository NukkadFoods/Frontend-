import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';

class FingerprintScreen extends StatelessWidget {
  const FingerprintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your FingerPrint ',style: h4TextStyle,),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
             
              const SizedBox(height: 40),
              // Fingerprint graphic
              Column(
                children: [
                  Text(
                    'Set your fingerprint',
                    style: h3TextStyle
                  ),
                  // Description
                 const  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  // Title
                ],
              ),
              const SizedBox(height: 10,),

              // Buttons
              Container(
                child: Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: Image.asset('assets/images/fingerPrint_null.png',height: 280,)
                    ),
                    const SizedBox(height: 50,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          decoration:
                          BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle continue action
                            },
                            style: ElevatedButton.styleFrom(
                              side: const BorderSide(color: textGrey1),
                              backgroundColor: textWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Border radius
                              ),

                              // padding:
                              // EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(color: primaryColor, fontSize: 17),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: 5.h,
                          decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(10)),
                          child: ElevatedButton(onPressed: (){},style:ElevatedButton.styleFrom(backgroundColor: primaryColor,foregroundColor: textWhite,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),child: Text('Continue',style: TextStyle(fontSize: 17),),)
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
    );
  }
}