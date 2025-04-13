import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_app/Controller/subscription_resquest.dart';
import 'package:user_app/widgets/constants/colors.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // late Timer _timer;
  // int _remainingSeconds =
  //     7400; // Set the countdown time in seconds (e.g., 2 hours, 3 minutes, 44 seconds)

  @override
  void initState() {
    super.initState();
    // _startTimer();
  }

  // void _startTimer() {
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (_remainingSeconds > 0) {
  //       setState(() {
  //         _remainingSeconds--;
  //       });
  //     } else {
  //       _timer.cancel();
  //     }
  //   });
  // }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // int hours = (_remainingSeconds ~/ 3600);
    // int minutes = (_remainingSeconds % 3600) ~/ 60;
    // int seconds = _remainingSeconds % 60;
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          // decoration: BoxDecoration(

          //   // image: DecorationImage(
          //   //   image: AssetImage('assets/background.png'), // Add your background image here
          //   //   fit: BoxFit.cover,
          //   // ),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
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
                                child: Image.asset(
                                  'assets/icons/arrow_back.png',
                                  color: isdarkmode ? Colors.black : textWhite,
                                  height: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Your Subscription',
                          style: TextStyle(
                            color: isdarkmode ? textBlack : Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      textAlign: TextAlign.center,
                      'Subscribe to nukkad foods to start receiving orders',
                      style: TextStyle(
                        color: isdarkmode ? textBlack : Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image.asset(
                            'assets/images/subs_box.png',
                            height: 180,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
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
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Nukkad Foods! ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isdarkmode ? textBlack : textWhite,
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/images/star.png',
                                      height: 30,
                                    )
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'This offer Valid Till:',
                                  style: TextStyle(
                                      color:
                                          isdarkmode ? textBlack : Colors.white,
                                      fontSize: 10),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Text(DateFormat('d MMM yyyy').format(
                                        DateTime.parse(SubscribeController
                                                .subscription!.startDate)
                                            .add(Duration(
                                                days: SubscribeController
                                                            .subscription!
                                                            .subscriptionPlanId ==
                                                        "WEEKLY"
                                                    ? 7
                                                    : SubscribeController
                                                                .subscription!
                                                                .subscriptionPlanId ==
                                                            "MONTHLY"
                                                        ? 30
                                                        : 90))))
                                    // child: Row(
                                    //   crossAxisAlignment:
                                    //       CrossAxisAlignment.start,
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   children: [
                                    //     TimeBox(
                                    //         time:
                                    //             hours.toString().padLeft(2, '0'),
                                    //         label: 'hours'),
                                    //     SizedBox(
                                    //       width: 5,
                                    //     ),
                                    //     Text(':',
                                    //         style: h2TextStyle.copyWith(
                                    //             color: isdarkmode
                                    //                 ? textBlack
                                    //                 : textWhite)),
                                    //     SizedBox(
                                    //       width: 5,
                                    //     ),
                                    //     TimeBox(
                                    //         time: minutes
                                    //             .toString()
                                    //             .padLeft(2, '0'),
                                    //         label: 'minutes'),
                                    //     SizedBox(
                                    //       width: 5,
                                    //     ),
                                    //     Text(':',
                                    //         style: h2TextStyle.copyWith(
                                    //             color: isdarkmode
                                    //                 ? textBlack
                                    //                 : textWhite)),
                                    //     SizedBox(width: 5),
                                    //     TimeBox(
                                    //         time: seconds
                                    //             .toString()
                                    //             .padLeft(2, '0'),
                                    //         label: 'seconds'),
                                    //   ],
                                    // ),
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'You can use wallet cash to renew your subscription after it expires to continue receiving orders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: isdarkmode ? textGrey2 : textBlack),
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
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color:
                isdarkmode ? const Color.fromARGB(48, 0, 0, 0) : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                time,
                style: TextStyle(
                  color: isdarkmode ? textWhite : textBlack,
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
          style: TextStyle(
              color: isdarkmode ? textBlack : textWhite, fontSize: 10),
        ),
      ],
    );
  }
}
