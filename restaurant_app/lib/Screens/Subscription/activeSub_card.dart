import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/subscription/subscription_resquest.dart';
import 'dart:async';

import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';

class ActiveSubscriptionScreen extends StatefulWidget {
  const ActiveSubscriptionScreen({super.key, GetSubscriptionModel? subscription});

  @override
  _ActiveSubscriptionScreenState createState() => _ActiveSubscriptionScreenState();
}

class _ActiveSubscriptionScreenState extends State<ActiveSubscriptionScreen> {
  late Timer _timer;
  int _remainingSeconds =
      7400; // Set the countdown time in seconds (e.g., 2 hours, 3 minutes, 44 seconds)

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int hours = (_remainingSeconds ~/ 3600);
    int minutes = (_remainingSeconds % 3600) ~/ 60;
    int seconds = _remainingSeconds % 60;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            // image: DecorationImage(
            //   image: AssetImage('assets/background.png'), // Add your background image here
            //   fit: BoxFit.cover,
            // ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child:Icon(Icons.arrow_back_ios)
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Your Subscription',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      textAlign: TextAlign.center,
                      'Subscribe to nukkad foods to start receiving orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                              child: Image.asset(
                            'assets/images/subs_box.png',
                            height: 180,
                          )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Subscription Active',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        // SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Nukkad Foods!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textWhite,
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/images/star.png',
                                      height: 30,
                                    )
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'This offer Valid Till:',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TimeBox(
                                          time:
                                              hours.toString().padLeft(2, '0'),
                                          label: 'hours'),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(':',
                                          style: h2TextStyle.copyWith(
                                              color: textWhite)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      TimeBox(
                                          time: minutes
                                              .toString()
                                              .padLeft(2, '0'),
                                          label: 'minutes'),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(':',
                                          style: h2TextStyle.copyWith(
                                              color: textWhite)),
                                      SizedBox(width: 5),
                                      TimeBox(
                                          time: seconds
                                              .toString()
                                              .padLeft(2, '0'),
                                          label: 'seconds'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'You can use wallet cash to renew your subscription after it expires to continue receiving orders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeBox extends StatelessWidget {
  final String time;
  final String label;

  const TimeBox({super.key, required this.time, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: textBlack,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          label,
          style: const TextStyle(color: textWhite, fontSize: 10),
        ),
      ],
    );
  }
}
