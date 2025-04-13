import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  List content = [];
  bool isLoading = true;
  List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      content = (await FirebaseFirestore.instance
              .collection('public')
              .doc('privacy_policy')
              .get())
          .get('userApp');
      for ( int i=0;i<content.length;i++) {
        widgets.addAll([
          buildSectionTitle("${i+1}. ${content[i]['title']}", context),
          buildSectionContent(content[i]['content'], context)
        ]);
      }
      widgets.add(SizedBox(height: 2.h));
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Privacy Policy',
            style: TextStyle(color: textWhite),
          ),
          backgroundColor: primaryColor // Customize the color
          ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: textGrey1),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(5.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            Text(
                              'Privacy Policy',
                              style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isdarkmode ? textGrey2 : textBlack),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'At Nukkaad Foods, we value your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our app. By using Nukkaad Foods, you agree to the practices outlined in this policy.\n',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isdarkmode ? textGrey2 : textBlack),
                            ),

                            // SizedBox(height: 2.h),
                          ] +
                          widgets,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildSectionTitle(String title, BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isdarkmode ? textGrey2 : textBlack),
      ),
    );
  }

  Widget buildSectionContent(String content, BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Text(
        content,
        style: TextStyle(
            fontSize: 12.sp, color: isdarkmode ? textGrey2 : textBlack),
      ),
    );
  }
}
