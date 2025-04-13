import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/Screens/AccessibilityTab/chat_screen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

class HelpCenterWidget extends StatefulWidget {
  const HelpCenterWidget({super.key});

  @override
  State<HelpCenterWidget> createState() => _HelpCenterWidgetState();
}

class _HelpCenterWidgetState extends State<HelpCenterWidget> {
  bool isLoading = true;
  // bool _isExpanded = false;
  List<bool> _isExpandedList = [];
  List<Map<String, dynamic>> dataList = [
    // {
    //   'id': 1,
    //   'title': 'What are Promos?',
    //   'subtitle':
    //       'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
    // },
    // {
    //   'id': 2,
    //   'title': 'Do I need to pay to add Promo?',
    //   'subtitle':
    //       'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
    // },
    // {
    //   'id': 3,
    //   'title': 'Where will the Promo shown?',
    //   'subtitle':
    //       'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
    // },
    // {
    //   'id': 4,
    //   'title': 'Can I see orders any location?',
    //   'subtitle':
    //       'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
    // },
    // {
    //   'id': 5,
    //   'title': 'charge me for creating a page on its platform?',
    //   'subtitle':
    //       'Promos are a great way to promote your business to existing and potential customers on Zomato. Your Promo can be a Freebie, a Discount, or a Special.'
    // },
  ];
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    final temp =
        (await FirebaseFirestore.instance.collection('public').doc('faq').get())
            .get('restaurantApp');
    for (int i = 0; i < temp.length; i++) {
      dataList.add({'id': i, 'title': temp[i]['q'], 'subtitle': temp[i]['a']});
    }
    _isExpandedList = List<bool>.generate(dataList.length, (index) => false);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Help Cetnre', style: h4TextStyle),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 19.sp,
              color: Colors.black,
            ),
          ),
        ),
        body: Stack(children: [
          Image.asset(
            'assets/images/otpbg.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: dataList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: textGrey2),
                                  borderRadius: BorderRadius.circular(10.0),
                                  color:
                                      textGray4, // Change this color as per your requirement
                                ),
                                margin: EdgeInsets.symmetric(vertical: 2.w),
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 4, top: 5, left: 0, right: 10),
                                    child: Text(dataList[index]['title']),
                                  ),
                                  subtitle: _isExpandedList[index]
                                      ? Text(dataList[index]['subtitle'])
                                      : null,
                                  trailing: IconButton(
                                    icon: Icon(
                                      _isExpandedList[index]
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      size: 19.sp,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isExpandedList[index] =
                                            !_isExpandedList[index];
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Still need help?'.toUpperCase(),
                              style: body6TextStyle.copyWith(
                                letterSpacing: 0.7,
                                fontSize: 15,
                                color: primaryColor,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 2.h,
                            ),
                            child: mainButton('chat with us'.toUpperCase(),
                                textWhite, routerChat),
                          ),
                          // Align(
                          //   alignment: Alignment.center,
                          //   child: Text(
                          //     'Still need help?'.toUpperCase(),
                          //     style: body6TextStyle.copyWith(
                          //       letterSpacing: 0.7,
                          //       fontSize: 15,
                          //       color: primaryColor,
                          //       fontWeight: FontWeight.w400,
                          //     ),
                          //     textAlign: TextAlign.center,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
          ),
        ]));
  }

  void routerChat() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const ChatSupportScreen())
        // builder: (context) => const ChatListPage()),
        );
  }
}
