import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:restaurant_app/Controller/wallet_controller.dart';
import 'package:restaurant_app/Screens/Wallet/viewEarningsScreen.dart';
import 'package:restaurant_app/Screens/Wallet/wallet_history.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:sizer/sizer.dart';
import '../../Widgets/customs/WalletBody/couponButton.dart';
import '../../Widgets/customs/WalletBody/inviteButton.dart';
import '../../Widgets/customs/WalletBody/referalMap.dart';
import '../../Widgets/customs/WalletBody/referalNotification.dart';
import '../../Widgets/customs/WalletBody/walletWidget.dart';

class WalletBody extends StatefulWidget {
  const WalletBody({super.key});

  @override
  State<WalletBody> createState() => _WalletBodyState();
}

class _WalletBodyState extends State<WalletBody> {
  String referralCode = '';
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    getReferralCode();
  }

  void getReferralCode() async {
    if (!WalletController.loaded) {
      WalletController.getWallet();
    }
    final temp = SharedPrefsUtil().getString('referralCode');
    if (temp == null) {
      final referralMap = (await FirebaseFirestore.instance
              .collection('constants')
              .doc('referralCodes')
              .get())
          .data()!;
      referralCode = referralMap.entries.firstWhere(
        (element) {
          return element.value == WalletController.uid;
        },
        orElse: () => const MapEntry('error', 'error'),
      ).key;
      if (referralCode == 'error') {
        await completeReferral(WalletController.uid);
      }
      SharedPrefsUtil().setString('referralCode', referralCode);
    } else {
      referralCode = temp;
    }
    if (mounted) {
      setState(() {});
    }
  }

  String getRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<void> completeReferral(String uid) async {
    final dbRef =
        FirebaseFirestore.instance.collection('constants').doc('referralCodes');
    final referralCodes = (await dbRef.get()).data()!;
    String generatedCode = '';
    do {
      generatedCode = getRandomString(7);
    } while (referralCodes.containsKey(generatedCode));
    dbRef.update({generatedCode: uid});
    referralCode = generatedCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset('assets/images/otpbg.png', fit: BoxFit.cover),
          SafeArea(
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
                            backgroundColor: selectedIndex == 0
                                ? primaryColor
                                : Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1, color: primaryColor),
                                borderRadius: BorderRadius.circular(15))),
                        child: Row(
                          children: [
                            Icon(Icons.payment_outlined,
                                color: selectedIndex == 0
                                    ? Colors.white
                                    : primaryColor),
                            const SizedBox(width: 10),
                            Text("Earnings",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: selectedIndex == 0
                                        ? Colors.white
                                        : primaryColor)),
                          ],
                        )),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedIndex = 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: selectedIndex == 1
                                ? primaryColor
                                : Colors.white,
                            side: BorderSide(width: 1, color: primaryColor),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/navbar_wallet.svg',
                              colorFilter: ColorFilter.mode(
                                  selectedIndex == 1
                                      ? Colors.white
                                      : primaryColor,
                                  BlendMode.srcATop),
                            ),
                            const SizedBox(width: 10),
                            Text("Wallet",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: selectedIndex == 1
                                        ? Colors.white
                                        : primaryColor)),
                          ],
                        ))
                  ],
                ),
                if (selectedIndex == 0)
                  Flexible(child: const EarningScreen())
                else
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 2.h,
                              horizontal: 5.w,
                            ),
                            child: const WalletWidget(),
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  transitionToNextScreen(
                                      const WalletHistoryScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              child: Text(
                                "View Wallet History",
                                style:
                                    h5TextStyle.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                          Text('Refer and Earn program', style: h4TextStyle),
                          Padding(
                              padding: EdgeInsets.all(2.h), child: ReferCard()),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 2.h,
                              horizontal: 5.w,
                            ),
                            child: couponButton(context, referralCode),
                          ),
                          inviteButton(referralCode),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 2.h,
                              horizontal: 2.w,
                            ),
                            child: SizedBox(
                              width: 100.w,
                              child: Text(
                                'How do refer and earn work?'.toUpperCase(),
                                style: body3TextStyle.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w300,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          referalMap(),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
