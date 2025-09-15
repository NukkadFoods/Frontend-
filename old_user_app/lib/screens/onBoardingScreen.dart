import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Screens/loginScreen.dart';
import 'package:user_app/Widgets/buttons/mainButton.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  final introKey = GlobalKey<OnBoardingScreenState>();
  int currentPageIndex = 0;

  void _onPageChange(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  Widget _buildImage(String assetName) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Image.asset(
        'assets/images/introduction/$assetName',
        
      ),
    );
  }

  routeLogin() {
     Navigator.of(context).pushReplacement(transitionToNextScreen(const LoginScreen()), );
  }

 @override
Widget build(BuildContext context) {
  final pageDecoration = PageDecoration(
    titleTextStyle: h4TextStyle.copyWith(color: primaryColor),
      titlePadding: const EdgeInsets.fromLTRB(0, 18, 0, 15),
      bodyTextStyle: body3TextStyle,
      bodyPadding: EdgeInsets.fromLTRB(4.w,0, 4.w, 2.h),
      pageColor: Colors.white,contentMargin: EdgeInsets.zero,
      imagePadding: EdgeInsets.zero,
      imageFlex: 2,
      pageMargin: EdgeInsets.zero
  );

  return Stack(
    children: [
      IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Colors.white,
        allowImplicitScrolling: true,
        autoScrollDuration: 3000,
        globalHeader: const Align(
          alignment: Alignment.topRight,
         
        ),
        globalFooter: currentPageIndex == 2
            ? Padding(
                padding: EdgeInsets.only(bottom: 1.h,right: 3.w,left: 3.w),
                child: mainButton('Next', textWhite, routeLogin),
              )
            : SizedBox(height: 5.h),
        pages: [
          PageViewModel(
            title: "Find Food Stalls",
            body:
                "Order from your nearby food \nvendors and restaurants,\n while relaxing at your home.",
            image: _buildImage('newintro1.png'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Browse Menu",
            body: "Find what you are craving for,\n and click order.",
            image: Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.h,2.h,4.h,2.h),
                child: _buildImage('newintro2.png'),
              ),
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Relax!",
            body:
                "Sit back and relax while our \ndelivery captain reaches you\n with your favorite food.",
            image: Lottie.asset('assets/images/introduction/newintro3.json'),
            decoration: pageDecoration,
          ),
        ],
        showSkipButton: true,
        overrideSkip: (context, onTap) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextButton(onPressed: routeLogin,child: Text('Skip',style: TextStyle(color: textGrey1,fontSize: 16,fontWeight: FontWeight.bold),),),
        ],
      ),
        skipOrBackFlex: 1,
        nextFlex: 1,
        showBackButton: false,
        showDoneButton: false,
        showNextButton: true,
        overrideNext: (context, onTap) => const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.arrow_forward,color: primaryColor,), 
        ],
      ),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(16),
        controlsPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 3.w),
        dotsDecorator: DotsDecorator(
          size: Size(1.5.h, 1.2.h),
          color: textGrey2,
          activeSize: Size(1.5.h, 1.5.h),
          activeColor: primaryColor,
        ),
        dotsContainerDecorator: const ShapeDecoration(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
        onChange: _onPageChange,
      ),

      // Conditionally add the image at the bottom-left or top-left based on the current page index
      if (currentPageIndex == 1)
        Positioned(
          bottom: 0,  // Adjust the bottom padding as needed
          left: 0,    // Adjust the left padding as needed
          child: Image.asset(
            'assets/images/introduction/bottom_left_image.png',
            width: 100,  // Adjust the size of the image
          ),
        ),
      if (currentPageIndex == 2)
        Positioned(
          top: 0,    // Adjust the top padding as needed
          left: 0,   // Adjust the left padding as needed
          child: Image.asset(
            'assets/images/introduction/top_right_image.png',
            width: 300,  // Adjust the size of the image
          ),
        ),
    ],
  );
}
}
