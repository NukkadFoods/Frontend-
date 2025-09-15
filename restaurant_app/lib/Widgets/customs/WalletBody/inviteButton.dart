import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/colors.dart';
import '../../constants/texts.dart';
import 'dart:developer';

Widget inviteButton(String referralCode) {
   String amount = '';
    String link = '';
    String msg = '';
    try {
      FirebaseFirestore.instance
          .collection('constants')
          .doc('restaurantApp')
          .get()
          .then((data) {
        amount = data['referral_amount'].toString();
        link = data['referralLink'];
        msg = data['referralMsg'];
      });
    } catch (e) {
      log(e.toString());
    }
  return ElevatedButton(
    style: ButtonStyle(
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: BorderSide(
            color: primaryColor,
            width: 0.2.h,
          ),
        ),
      ),
    ),
    onPressed: ()async {
      
                    Share.share(
                        "$msg $amount,  $link$referralCode");
                  
    },
    child: Text(
      'Invite'.toUpperCase(),
      style: body3TextStyle.copyWith(
          fontWeight: FontWeight.w300, color: primaryColor),
    ),
  );
}
