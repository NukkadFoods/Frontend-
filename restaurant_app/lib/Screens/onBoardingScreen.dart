import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:restaurant_app/Screens/User/login_screen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:sizer/sizer.dart';

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
      padding: EdgeInsets.only(top: 9.h),
      child: Image.asset(
        'assets/images/introduction/$assetName',
        height: 100.h,width: 90.w,
      ),
    );
  }

  routeLogin() {
    Navigator.pushReplacement(
      context,
    transitionToNextScreen( Login_Screen(),
      ),
    );
  }
@override
Widget build(BuildContext context) {
  final pageDecoration = PageDecoration(
    titleTextStyle: h3TextStyle.copyWith(color: primaryColor),
    titlePadding: EdgeInsets.fromLTRB(0, 0, 0, 15),
    bodyTextStyle: body4TextStyle.copyWith(fontSize: 14.sp),
    bodyPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
    pageColor: Colors.white,
    contentMargin: EdgeInsets.zero,
    imagePadding: EdgeInsets.zero,
    imageFlex: 1,
    pageMargin: EdgeInsets.zero,
  );

  return Stack(
    children: [
      IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Colors.white,
        allowImplicitScrolling: true,
        autoScrollDuration: 3000,

        globalFooter: currentPageIndex == 2
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
                child: Container(
                   child: mainButton('Next', textWhite, routeLogin)),
              )
            : SizedBox(
                height: 10.h,
              ),

        pages: [
          PageViewModel(
            titleWidget: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/introduction/page1semicircle.png',),
                Text(
                  "List Your Stall",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10.h),
              ],
            ),
            body: "List your stall / food truck /\n restaurant on Nukkad Foods.",
            image: _buildImage('page1_new.png'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Column(
              children: [
                SizedBox(height: 22.h),
                Text(
                  "Accept Orders",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            body: "Fix your menu, and accept orders from customers.",
            image: _buildImage('page2_new.png'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/introduction/page3shape.png', height: 21.h),
                  ],
                ),
                Stack(
                  children: [
                    Lottie.asset(
                      'assets/animations/page3.json',
                      repeat: true,
                      height: 30.h,
                    ),
                    Image.asset('assets/images/introduction/page3circle.png', height: 32.h),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         SizedBox(height: 19.h,),
                        Text(
                          "Relax!",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            body: "Prepare order and hand over\n to the delivery partner to\n deliver deliciousness.",
            decoration: pageDecoration,
          ),
        ],
        onDone: () {},
        onSkip: routeLogin,

        showSkipButton: true,
        overrideSkip: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              child: Text(
                'Skip',
                style: TextStyle(color: textBlack, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: routeLogin,
            ),
          ],
        ),
        skipOrBackFlex: 1,
        nextFlex: 1,
        showBackButton: false,
        showDoneButton: false,
        showNextButton: true,
        overrideNext: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.navigate_next_sharp, color: primaryColor, size: 30),
          ],
        ),
        curve: Curves.fastLinearToSlowEaseIn,

        controlsPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 3.w),
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

      // Conditionally position the image when currentPageIndex is 1
      if (currentPageIndex == 1)
        Positioned(
          bottom: 0,
          left: 0,
          child: Image.asset(
            'assets/images/introduction/page2circle.png',
            width:27.w,
            height: 17.h, // Width of the image
          ),
        ),
    ],
  );
}

}
