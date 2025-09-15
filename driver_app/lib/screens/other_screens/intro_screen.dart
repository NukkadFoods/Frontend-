import 'dart:async';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/font-styles.dart';
import '../../widgets/common/full_width_green_button.dart';
import '../../widgets/common/transition_to_next_screen.dart';
import '../authentication_screens/signin_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  bool _autoSlide = true; // Flag to control auto sliding
  Timer? _timer; // Timer object for auto sliding

  List<Map<String, dynamic>> _slides = [
    {
      'bgImage': 'assets/images/introbg1.png',
      'image': 'assets/images/intro1.png',
      'text': 'Register yourself',
      'subText': 'Complete your documentation and register on our app!'
    },
    {
      'bgImage': 'assets/images/introbg2.png',
      'image': 'assets/images/intro2.png',
      'text': 'Accept Orders',
      'subText': 'Accept delivery orders near you.'
    },
    {
      'bgImage': 'assets/images/introbg3.png',
      'image': 'assets/images/intro3.png',
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
        if (_currentPage < _slides.length - 1) {
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
        children:[ Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                _slides.isNotEmpty ? _slides[_currentPage]['bgImage'] : '',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return buildSlide(index);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => buildDot(index),
                ),
              ),
              SizedBox(height: 20.0), // Adjust spacing between dots and button
              if (_currentPage == _slides.length - 1)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  height: 50,
                  child: FullWidthGreenButton(
                    label: 'Next',
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacement(transitionToNextScreen(SignInScreen()));
                    },
                  ),
                ),
              SizedBox(height: 10), // Fixed space below button area
            ],
          ),
        ),
 Align(
  alignment: Alignment.topRight,
   child: Padding(
              padding: EdgeInsets.only(right: 10,top: 30),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: colorGreen,foregroundColor: colorWhite),
                  onPressed: (){
                     Navigator.of(context)
                              .pushReplacement(transitionToNextScreen(SignInScreen()));
                  },
                  child: Text('SKIP'),
                ),
              ),
            ),
 )
     ] ),
    );
  }

  Widget buildSlide(int index) {
    return Container(
      height: MediaQuery.of(context).size.height - 100,
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 70),
          Image.asset(
            _slides.isNotEmpty ? _slides[index]['image'] : '',
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: 20.0),
          Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Text(
                _slides.isNotEmpty ? _slides[index]['text'] : '',
                style: TextStyle(
                  fontSize: large,
                  color: colorBrightGreen,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.0),
              Text(
                _slides.isNotEmpty ? _slides[index]['subText'] : '',
                style: TextStyle(fontSize: medium),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 70.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? colorBrightGreen : colorGray,
      ),
    );
  }
}
