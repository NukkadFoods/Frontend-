import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/walletcontroller.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/Widgets/customs/Wallet/couponButton.dart';
import 'package:user_app/Widgets/customs/Wallet/header.dart';
import 'package:user_app/Widgets/customs/Wallet/referalMap.dart';
import 'package:user_app/screens/rewards/wallet_history.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/Wallet/referalNotification.dart';
import 'package:share_plus/share_plus.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:user_app/widgets/customs/request_login.dart';

class WalletBody extends StatefulWidget {
  const WalletBody({super.key});

  @override
  State<WalletBody> createState() => _WalletBodyState();
}

class _WalletBodyState extends State<WalletBody> {
  var amount;
  // bool amountCredited = false;
  String referralCode = '58vt3x1';
  String referralLink = '';
  String referralMsg = '';

  @override
  void initState() {
    super.initState();
    loadwallet();
  }

  Future<void> loadwallet() async {
    if (WalletController.wallet == null) {
      WalletController.getWallet().then((_) {
        setState(() {}); // Trigger a rebuild once the wallet data is fetched
      });
    }
    // Checkforfirstorder();
    final data = await FirebaseFirestore.instance
        .collection('constants')
        .doc('userApp')
        .get();
    amount = data.data()?['referral_amount'].toDouble();
    referralLink = data.data()?['referralLink'];
    referralMsg = data.data()?['referralMsg'];
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
  // void Checkforfirstorder() async {
  //   var result = await OrderController.getAllOrders(
  //     context: context,
  //     uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
  //   );
  //   result.fold((String message) {
  //     if (mounted) {}
  //   }, (OrdersModel getAllOrders) async {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     bool isReferAmountCredited = prefs.getBool('referamountCredited') ?? false;

  //     if (getAllOrders.orders!.length == 1 && !isReferAmountCredited) {
  //       WalletController.credit(amount?.toDouble() ?? 0.0);
  //       prefs.setBool('referamountCredited', true);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      onRefresh: loadwallet,
      child: SharedPrefsUtil().getString(AppStrings.userId) == null
          ? loginRequest(context)
          : SingleChildScrollView(
              child: Column(
                children: [
                  walletHeader(context),
                  SizedBox(height: 2.h),
                  Center(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(transitionToNextScreen(
                              const WalletHistoryScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        child: Text(
                          "View Wallet History",
                          style: h5TextStyle.copyWith(color: Colors.white),
                        )),
                  ),
                  Text('Refer and Earn program',
                      style: h5TextStyle.copyWith(
                          color: isDarkMode ? textGrey2 : textBlack)),
                  SizedBox(height: 1.h),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ReferCard(
                      referralCode: referralCode,
                      referralLink: referralLink,
                      referralMsg: referralMsg,
                      amount: amount ?? 0,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                    child: couponButton(context, referralCode),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: inviteButton(
                        referralCode, amount ?? 0, referralLink, referralMsg),
                  ),
                  Text(
                    'How do refer and earn work?'.toUpperCase(),
                    style: body4TextStyle.copyWith(
                        fontWeight: FontWeight.w300,
                        color: isDarkMode ? textGrey2 : textBlack),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(3.w, 2.w, 3.w, 0),
                    child: referalMap(context),
                  )
                ],
              ),
            ),
    );
  }
}

Widget inviteButton(String referralCode, double amount, String referralLink,
    String referralMsg) {
  return ElevatedButton(
    style: ButtonStyle(
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: BorderSide(
            color: primaryColor,
            width: 0.2.h,
          ),
        ),
      ),
    ),
    onPressed: () {
      Share.share("$referralMsg $amount, $referralLink$referralCode");
    },
    child: Text(
      'Invite'.toUpperCase(),
      style: body4TextStyle.copyWith(
          fontWeight: FontWeight.w300, color: primaryColor),
    ),
  );
}
