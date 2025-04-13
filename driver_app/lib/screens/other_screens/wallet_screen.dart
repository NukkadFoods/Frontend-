import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/providers/wallet_provider.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:driver_app/widgets/wallet/earning_screen.dart';
import 'package:driver_app/widgets/wallet/left_image_container.dart';
import 'package:driver_app/widgets/wallet/right_image_container.dart';
import 'package:driver_app/widgets/wallet/wallet_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    String amount = '';
    String link = '';
    String msg = '';
    try {
      FirebaseFirestore.instance
          .collection('constants')
          .doc('driverApp')
          .get()
          .then((data) {
        amount = data['referral_amount'].toString();
        link = data['referralLink'];
        msg = data['referralMsg'];
      });
    } catch (e) {
      log(e.toString());
    }

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedIndex == 0 ? colorBrightGreen : Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1,
                              color: selectedIndex == 0
                                  ? colorBrightGreen
                                  : colorGreen),
                          borderRadius: BorderRadius.circular(15))),
                  child: Row(
                    children: [
                      Icon(Icons.payment_outlined,
                          color:
                              selectedIndex == 0 ? Colors.white : colorGreen),
                      const SizedBox(width: 10),
                      Text("Earnings",
                          style: TextStyle(
                              fontSize: 20,
                              color: selectedIndex == 0
                                  ? Colors.white
                                  : colorBrightGreen)),
                    ],
                  )),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedIndex == 1 ? colorBrightGreen : Colors.white,
                      side: BorderSide(
                          width: 1,
                          color: selectedIndex == 1
                              ? colorBrightGreen
                              : colorGreen),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/wallet.svg',
                        colorFilter: ColorFilter.mode(
                            selectedIndex == 1 ? Colors.white : colorGreen,
                            BlendMode.srcATop),
                      ),
                      const SizedBox(width: 10),
                      Text("Wallet",
                          style: TextStyle(
                              fontSize: 20,
                              color: selectedIndex == 1
                                  ? Colors.white
                                  : colorGreen)),
                    ],
                  ))
            ],
          ),
          if (selectedIndex == 0)
            Flexible(child: EarningScreen())
          else
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ChangeNotifierProvider(
                    create: (context) => WalletProvider(),
                    builder: (context, child) => Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(
                        //   height: 30,
                        // ),
                        // const Center(
                        //   child: Text(
                        //     'Wallet',
                        //     style: TextStyle(
                        //       fontSize: large,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              border: Border.all(
                                width: 2,
                                color: borderColor,
                              )),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                'AVAILABLE BALANCE',
                                style: TextStyle(
                                  color: colorGreen,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF47D3FF),
                                        Color(0xFF5A00CF),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8))),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/wallet.png'),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Consumer<WalletProvider>(
                                      builder: (context, value, child) => Text(
                                        value.balance.toStringAsFixed(2),
                                        style: TextStyle(
                                          fontSize: 39,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Wallet cash can be used for boosting promotions',
                            style: TextStyle(
                              color: colorGray,
                              fontSize: small,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(transitionToNextScreen(
                                  const WalletHistoryScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: colorGreen,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Wallet History',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Center(
                          child: Text(
                            'Refer and earn program',
                            style: TextStyle(
                              fontSize: large,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Banner(),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 250,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: colorGreen,
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Consumer<WalletProvider>(
                                builder: (context, value, child) => RichText(
                                  text: TextSpan(
                                    text: 'Copy your code',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: mediumSmall,
                                      fontWeight: FontWeight.bold,
                                    ), // Example style
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: ' ${value.referralCode}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black, // Example style
                                          fontSize: mediumSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                          text: context
                                              .read<WalletProvider>()
                                              .referralCode))
                                      .then((_) {
                                    Toast.showToast(message: 'Code Copied!');
                                  });
                                },
                                child: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              Share.share(
                                  "$msg $amount, $link${context.read<WalletProvider>().referralCode}");
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.white),
                                side: WidgetStatePropertyAll(
                                    BorderSide(color: colorGreen)),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)))),
                            child: Text(' INVITE ',
                                style: TextStyle(
                                  color: colorGreen,
                                  fontSize: medium,
                                ))),
                        // Center(
                        //   child: Container(
                        //     padding:
                        //         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        //     decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(12),
                        //         border: Border.all(
                        //           width: 1.5,
                        //           color: colorGreen,
                        //         )),
                        //     child: const Text(
                        //       ' INVITE ',
                        //       style: TextStyle(
                        //         color: colorGreen,
                        //         fontSize: medium,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Center(
                          child: Text(
                            'HOW DOES REFER AND EARN WORK?',
                            style: TextStyle(
                              fontSize: mediumSmall,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const LeftImageContainer(
                            imagePath: 'assets/images/women.png',
                            count: '1.',
                            message:
                                'Share referral link using\nWhatsapp, SMS, and\nmore.'),
                        const SizedBox(
                          height: 20,
                        ),
                        const RightImageContainer(
                            imagePath: 'assets/images/phone.png',
                            count: '2.',
                            message:
                                'Your friend Registers on\nthe link to download the\nnukkad app or uses your\nreferral code!'),
                        const SizedBox(
                          height: 20,
                        ),
                        const LeftImageContainer(
                            imagePath: 'assets/images/package.png',
                            count: '3.',
                            message: 'Friend completes their\nfirst order.'),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              top: 16, left: 16, right: 16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(width: 1, color: colorGray)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '4.',
                                    style: TextStyle(
                                      color: colorGreen,
                                      fontSize: large,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width -
                                                100),
                                    child: Text(
                                      'You both earn 50 nukkad coins each, that can be converted to wallet cash and can be used for promotions orders. ',
                                      style: TextStyle(
                                        fontSize: small,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Image.asset('assets/images/money.png'),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Banner extends StatelessWidget {
  const Banner({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          height: 150,
          width: double.infinity,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xff375CFF), Color(0xffDCEEFA)])),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 2 - 60),
                  child: RichText(
                      text: TextSpan(children: const [
                    TextSpan(
                        text: 'Refer And Earn!',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1.5)),
                    TextSpan(
                        text:
                            '\nRefer a friend to Nukkad foods and you both earn ₹50 when they place their first order!',
                        style:
                            TextStyle(fontSize: 8, fontWeight: FontWeight.w500))
                  ])),
                ),
                ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                        maximumSize: WidgetStatePropertyAll(Size(55, 24)),
                        minimumSize: WidgetStatePropertyAll(Size(54, 23)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5))))),
                    child: Text(
                      'Refer now',
                      style: TextStyle(
                          color: Color(
                            0xff375CFF,
                          ),
                          fontSize: 8,
                          fontWeight: w600),
                    ))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Image.asset(
            'assets/images/banner.png',
            width: 138,
          ),
        ),
        // SvgPicture(SvgAssetLoader('assets/svgs/banner.svg')),
        LottieBuilder.asset(
          'assets/animations/banner.json',
          height: 60,
          width: 60,
        )
      ],
    );
  }
}
