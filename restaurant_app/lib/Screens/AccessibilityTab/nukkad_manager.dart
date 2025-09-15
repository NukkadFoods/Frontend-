import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

class NukkadManagerWidget extends StatelessWidget {
  const NukkadManagerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nukkad Manager', style: h4TextStyle),
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
      body: Stack(
        children: [
          Image.asset(
            'assets/images/otpbg.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Please find contact details of your nukkad manager below. Feel free to contact in any case of doubt, Training and help needed.',
                      style: body3TextStyle.copyWith(
                        fontSize: 12,
                        color: Color(0xFFB8B8B8),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      width: 100.w,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.2.h, color: textGrey3),
                        color: textWhite,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: textGrey3.withOpacity(0.5), // Shadow color
                            spreadRadius: 2, // Spread radius
                            blurRadius: 5, // Blur radius
                            offset: Offset(
                                0, 3), // Offset in the x and y directions
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.blue)),
                                padding: EdgeInsets.all(2),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      // _image != null
                                      //     ? FileImage(_image!) as ImageProvider<Object>?
                                      //     :
                                      AssetImage('assets/images/ajay.jpeg'),
                                ),
                              ),
                              SizedBox(
                                width: 2.w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    maxLines: 1,
                                    'Ajay Tiwari',
                                    style: body4TextStyle.copyWith(
                                        color: primaryColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(
                                    maxLines: 2,
                                    'Speaks Hindi and English',
                                    style: body6TextStyle.copyWith(
                                        color: textGrey3,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone),
                                SizedBox(
                                  width: 2.w,
                                ),
                                Text(
                                  '9399250600',
                                  style: body6TextStyle.copyWith(
                                    letterSpacing: 0.7,
                                    fontSize: 12,
                                    color: textBlack,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mail_outline_outlined),
                                SizedBox(
                                  width: 2.w,
                                ),
                                Text(
                                  'Ajay@nukkadfoods.com',
                                  style: body6TextStyle.copyWith(
                                    letterSpacing: 0.7,
                                    fontSize: 12,
                                    color: textBlack,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
