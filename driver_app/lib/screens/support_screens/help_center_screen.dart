import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/screens/other_screens/nukkad_manager_screen.dart';
import 'package:driver_app/screens/support_screens/chat_page.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:flutter/material.dart';

import '../../utils/font-styles.dart';

class HelpCentreScreen extends StatefulWidget {
  const HelpCentreScreen({super.key});

  @override
  State<HelpCentreScreen> createState() => _HelpCentreScreenState();
}

class _HelpCentreScreenState extends State<HelpCentreScreen> {
  bool isLoading = true;
  List data = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    data =
        (await FirebaseFirestore.instance.collection('public').doc('faq').get())
            .get('driverApp');
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
  // List<Map<String, String>> data = [
  //   {
  //     'q': 'What are Promos?',
  //     'a':
  //         'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
  //   },
  //   {
  //     'q': 'Do I need to pay to add Promo?',
  //     'a':
  //         'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
  //   },
  //   {
  //     'q': 'Where will the Promo shown?',
  //     'a':
  //         'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
  //   },
  //   {
  //     'q': 'Can I see orders any location?',
  //     'a':
  //         'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
  //   },
  //   {
  //     'q': 'Charge me for creating a page on its platform?',
  //     'a':
  //         'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
  //   },
  //   {
  //     'q': 'Can I change the address?',
  //     'a':
  //         'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
  //   },
  //   {
  //     'q': 'Did not receive referral coupon?',
  //     'a':
  //         'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
  //   },
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_new)),
        title: Text(
          'Help Centre',
          style: TextStyle(
              color: Colors.black,
              fontSize: medium,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/otpbbg.png'),
                opacity: .5,
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      for (int i = 0; i < data.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7.0),
                          child: HelpCard(
                            question: data[i]['q']!,
                            answer: data[i]['a']!,
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Center(
                          child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Still need help?',
                                style: TextStyle(
                                  color: colorBrightGreen,
                                  fontSize: small,
                                  fontWeight: w600,
                                ),
                              )),
                        ),
                      ),
                      FullWidthGreenButton(
                          label: 'CHAT WITH US',
                          onPressed: () {
                            Navigator.of(context)
                                .push(transitionToNextScreen(const ChatPage()));
                          }),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Center(
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                    transitionToNextScreen(
                                        const NukkadManagerScreen()));
                              },
                              child: Text(
                                'Contact your Manager',
                                style: TextStyle(
                                  color: colorBrightGreen,
                                  fontSize: small,
                                  fontWeight: w600,
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class HelpCard extends StatefulWidget {
  const HelpCard({super.key, required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  State<HelpCard> createState() => _HelpCardState();
}

class _HelpCardState extends State<HelpCard> {
  bool show = false;
  double? height;
  GlobalKey key = GlobalKey();
  GlobalKey keyQuestion = GlobalKey();
  @override
  void initState() {
    super.initState();
    height = widget.question.length > 32 ? 70 : 55;
  }

  void animate() {
    if (show) {
      height = key.currentContext!.size!.height + 24;
    } else {
      height = keyQuestion.currentContext!.size!.height + 24;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: height,
      duration: const Duration(milliseconds: 100),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xfff7f7f7),
          border: Border.all(color: colorGray),
          borderRadius: BorderRadius.all(Radius.circular(7))),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          key: key,
          children: [
            Row(
              key: keyQuestion,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .7),
                  child: Text(
                    widget.question,
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
                InkWell(
                    onTap: () {
                      show = !show;
                      animate();
                    },
                    child: Icon(
                      show
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 30,
                    ))
              ],
            ),
            // if (show)
            const SizedBox(
              height: 5,
            ),
            // if (show)
            Text(
              widget.answer,
              style: TextStyle(fontSize: verySmall, height: 1.5),
            )
          ],
        ),
      ),
    );
  }
}
