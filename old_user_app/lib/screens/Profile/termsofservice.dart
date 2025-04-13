import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/widgets/constants/colors.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
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
              .doc('terms')
              .get())
          .get('userApp');
      for (int i = 0; i < content.length; i++) {
        widgets
            .add(buildSectionTitle("${i + 1}. ${content[i]['title']}", context));
        if (content[i]['subContent'] == null) {
          widgets.add(buildSectionContent(content[i]['content'], context));
        } else {
          for (int j = 0; j < content[i]['subContent'].length; j++) {
            widgets.addAll([
              buildSectionSubtitle(
                  "${i + 1}.${j + 1}. ${content[i]['subContent'][j]['subtitle']}",
                  context),
              buildSectionContent(
                  content[i]['subContent'][j]['content'], context)
            ]);
          }
        }
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
          'Terms of Service',
          style: TextStyle(color: textWhite),
        ),
        backgroundColor: primaryColor, // Customize the color
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: textGrey1),
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      Text(
                        'Terms of Service',
                        style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: isdarkmode ? textGrey2 : textBlack),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Welcome to Nukkad Foods! These Terms of Service govern your use of our app and services, including ordering and delivery of food from our partnered restaurants. By accessing or using Nukkad Foods, you agree to comply with and be bound by these Terms. Please read them carefully.\n',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: isdarkmode ? textGrey2 : textBlack),
                      ),
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

  Widget buildSectionSubtitle(String subtitle, BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Text(
        subtitle,
        style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
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
