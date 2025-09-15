import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';

class NoInternetConnectionScreen extends StatelessWidget {
  const NoInternetConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(
              'assets/images/otpbg.png',
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/no_internet.png',height: 200,width: 200,),
            SizedBox(height: 30),
            Text('No internet Connection',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
             SizedBox(height: 10),
            Text('Your internet connection is currently not available please check or  try again.',style: TextStyle(color: textGrey1),textAlign: TextAlign.center,),
             SizedBox(height: 60),
            mainButton('Try Again', textWhite, (){})
                                                 
            ],
        ),
      ),
    );
  }
}
