import 'dart:async';

import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../utils/colors.dart';
import '../../utils/font-styles.dart';
import '../../widgets/common/transition_to_next_screen.dart';
import '../authentication_screens/signin_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _autoSlide = true; // Flag to control auto sliding
  Timer? _timer; // Timer object for auto sliding
  List<Map<String, dynamic>> slides = [
    {
      'bgImage': 'assets/images/introbg1.png',
      'svg': 'assets/svgs/blob.svg',
      'image': 'assets/images/intro1.gif',
      'text': 'Register yourself',
      'subText': 'Complete your documentation and register on our app!'
    },
    {
      'bgImage': 'assets/images/introbg2.png',
      'svg': 'assets/svgs/blob.svg',
      'svg2': 'assets/svgs/onboarding2.svg',
      'image': null,
      'text': 'Accept Orders',
      'subText': 'Accept delivery orders near you.'
    },
    {
      'bgImage': null,
      'image': null,
      'animation': 'assets/animations/onboarding3.json',
      'text': 'Deliver happiness',
      'subText':
          'Track home and delivery delicious food from stalls to costomer!'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Start auto sliding when the widget is initialized
    startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  void startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_autoSlide) {
        // Check if not on the last slide, then slide to the next one
        if (_currentPage < slides.length - 1) {
          _currentPage++;
        } else {
          // Stop auto sliding when reaching the last slide
          _autoSlide = false;
          _timer?.cancel();
        }
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) => Slide(
                  slides: slides,
                  index: index,
                )),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_currentPage != 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                            transitionToNextScreen(SignInScreen()));
                      },
                      child: Text(
                        'Skip',
                        style:
                            TextStyle(fontSize: 16, color: Color(0xff4B5563)),
                      )),
                  Wrap(
                    children: [
                      for (int i = 0; i < slides.length; i++)
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == i
                                  ? colorBrightGreen
                                  : colorGray,
                            ),
                          ),
                        )
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          _currentPage + 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Color(0xff32B768),
                      ))
                ],
              )
            else
              Wrap(
                children: [
                  for (int i = 0; i < slides.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == i ? colorBrightGreen : colorGray,
                        ),
                      ),
                    )
                ],
              ),
            if (_currentPage == 2)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: FullWidthGreenButton(
                    label: 'Next',
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                          transitionToNextScreen(SignInScreen()));
                    }),
              ),
            const SizedBox(
              height: 50,
            )
          ],
        )
      ],
    ));
  }
}

class Slide extends StatelessWidget {
  const Slide({
    super.key,
    required this.slides,
    required this.index,
  });

  final List<Map<String, dynamic>> slides;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (slides[index]['bgImage'] != null)
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(slides[index]['bgImage']),
                    fit: BoxFit.cover)),
          ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // const SizedBox(
              //   height: 80,
              // ),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (slides[index]['svg'] != null)
                    SvgPicture.asset(slides[index]['svg']),
                  if (slides[index]['svg2'] != null)
                    SvgPicture.asset(slides[index]['svg2']),
                  if (slides[index]['image'] != null)
                    Image.asset(
                      slides[index]['image'],
                    ),
                  if (slides[index]['animation'] != null)
                    LottieBuilder.asset(
                      slides[index]['animation'],
                    )
                ],
              ),
              Wrap(
                // crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    slides.isNotEmpty ? slides[index]['text'] : '',
                    style: TextStyle(
                      fontSize: large,
                      color: colorBrightGreen,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.0),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      slides.isNotEmpty ? slides[index]['subText'] : '',
                      style: TextStyle(fontSize: medium),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              )
            ],
          ),
        ),
        if (index == 2)
          Align(
            alignment: Alignment.topLeft,
            child: SvgPicture.asset('assets/svgs/blob2.svg'),
          ),
      ],
    );
  }
}
