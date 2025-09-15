import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/screens/Profile/privacypolicy.dart';
import 'package:user_app/screens/Profile/termsofservice.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('About',
            style: h5TextStyle.copyWith(
                color: isdarkmode ? textGrey2 : textBlack)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background.png'))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
          child: Column(
            children: [
              policyButton('Terms of Service', context: context),
              policyButton('Privacy Policy', context: context)
            ],
          ),
        ),
      ),
    );
  }
}

Widget policyButton(String text, {required BuildContext context}) {
  bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  return Container(
    margin: EdgeInsets.only(bottom: 2.h),
    child: GestureDetector(
      onTap: () {
        text == 'Terms of Service'
            ? Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TermsOfServicePage()))
            : Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
      },
      child: Card.filled(
        color: textWhite,
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(text,
                  style: h5TextStyle.copyWith(
                      color: isdarkmode ? textGrey2 : textBlack)),
              Icon(
                Icons.arrow_forward_ios,
                color: isdarkmode ? textGrey2 : textBlack,
                size: 15.sp,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
