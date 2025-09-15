// import 'dart:js_util';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:restaurant_app/Screens/Payments/payments_screen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/User/cropwidget.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/input_fields/textInputField.dart';
import 'package:restaurant_app/Widgets/toast.dart';
import 'package:sizer/sizer.dart';

class AdsPage extends StatefulWidget {
  const AdsPage({super.key});

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  // final String baseUrl = dotenv.env['BASE_URL']!;
  final String baseUrl = AppStrings.baseURL;
  final String restaurantId = SharedPrefsUtil().getString(AppStrings.userId) ??
      ""; // Replace with actual restaurant ID

  DateTime? startDate;
  DateTime? endDate;
  // String amountValue = '';
  double amount = 0;
  late num baseAmount;
  String description = '';
  String title = '';

  @override
  void initState() {
    super.initState();
    getBaseAmount();
  }

  getBaseAmount() async {
    baseAmount = (await FirebaseFirestore.instance
        .collection('constants')
        .doc('restaurantApp')
        .get())['adsRate'];
  }

  Future<void> _selectDate(
      BuildContext context, bool isStartDate, DateTime? start) async {
    if (!isStartDate && startDate == null) {
      Toast.showToast(message: "Please select start date first", isError: true);
      return;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          start != null ? start.add(const Duration(days: 7)) : DateTime.now(),
      firstDate:
          start != null ? start.add(const Duration(days: 7)) : DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          endDate = null;
        } else {
          endDate = picked;
          amount =
              (baseAmount * endDate!.difference(startDate!).inDays).toDouble();
          amountValueController.text = amount.toString();
        }
      });
    }
  }

  final amountValueController = TextEditingController();
  final descriptionController = TextEditingController();

  final titleController = TextEditingController();
  String? _downloadUrl;

  void _deleteImage() {
    setState(() {
      _downloadUrl = null;
    });
  }

  String _formatDateStart(DateTime? date) {
    if (date == null) return 'Start Date';
    return '${date.day} ${_monthToString(date.month)}';
  }

  String _formatDateEnd(DateTime? date) {
    if (date == null) return 'End Date';
    return '${date.day} ${_monthToString(date.month)}';
  }

  String _monthToString(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Future<bool> createAdvertisement() async {
    final url = Uri.parse('$baseUrl/adds/addAdds');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'restaurantId': restaurantId,
        "title": title,
        "description": description,
        'amountPaid': amount,
        'startDate': startDate!.toIso8601String(),
        'endDate': endDate!.toIso8601String(),
        "bannerLink": _downloadUrl,
        "type": "User"
      }),
    );

    if (response.statusCode == 201) {
      // Success
      print('Advertisement created successfully');
      Toast.showToast(message: 'Advertisment Created Successfully');
      // Navigator.of(context).pop();
      return true;
    } else {
      // Error
      Toast.showToast(message: 'Something went wrong', isError: true);
      print('Failed to create advertisement: ${response.body}');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Ads', style: h4TextStyle),
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'assets/images/otpbg.png',
                  fit: BoxFit.cover,
                )),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Effective ads for your nukkad to increase nukkad visibility and growth',
                      style: body3TextStyle.copyWith(
                        fontSize: 12,
                        color: textGrey2,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Create a Ad'.toUpperCase(),
                        style: body3TextStyle.copyWith(
                          letterSpacing: 0.7,
                          fontSize: 15,
                          color: textBlack,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      maxLines: 1,
                      'Select duration ',
                      style: body4TextStyle.copyWith(
                          fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      'Select the starting and ending dates for your ads',
                      style: body3TextStyle.copyWith(
                        fontSize: 12,
                        color: textGrey2,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.5.h),
                          width: 43.w,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: primaryColor, width: 0.2.h),
                            borderRadius: BorderRadius.circular(10),
                            color: textWhite,
                          ),
                          child: InkWell(
                            onTap: () => _selectDate(context, true, null),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDateStart(startDate),
                                  style: h5TextStyle.copyWith(
                                    color: primaryColor,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down_outlined,
                                  size: 30,
                                  color: primaryColor,
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.5.h),
                          width: 43.w,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: primaryColor, width: 0.2.h),
                            borderRadius: BorderRadius.circular(10),
                            color: primaryColor,
                          ),
                          child: GestureDetector(
                            onTap: () => _selectDate(context, false, startDate),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDateEnd(endDate),
                                  style: h5TextStyle.copyWith(
                                    color: textWhite,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down_outlined,
                                  size: 30,
                                  color: textWhite,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Divider(
                      color: textGrey2,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    textInputField('Enter Title for Ad', titleController,
                        (String input) {
                      setState(() {
                        title = input;
                      });
                    }),
                    SizedBox(
                      height: 2.h,
                    ),
                    textInputField('Enter Description', descriptionController,
                        (String input) {
                      setState(() {
                        description = input;
                      });
                    }),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      maxLines: 1,
                      'Upload a Banner Image',
                      style: body4TextStyle.copyWith(
                          fontSize: 13.sp, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),

                    Center(
                      child: CropImageWidget(
                        context: context,
                        type: 'Advertisment banner',
                        imageUrl: _downloadUrl,
                        onFilePicked: (String? imageUrl) {
                          setState(() {
                            _downloadUrl = imageUrl;
                          });
                        },
                        onDelete: _deleteImage,
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    //   _image == null
                    //     ? Center(
                    //       child:mainButton('Upload Image', textWhite, _pickImage)
                    //     )
                    //     : Center(
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: [
                    //             SizedBox(height: 2.h,),
                    //             if (_isUploading) CircularProgressIndicator(),
                    //             if (!_isUploading)
                    //               Image.file(
                    //                 _image!,
                    //                 width: 150,
                    //                 height: 150,
                    //                 fit: BoxFit.cover,
                    //               ),
                    //             IconButton(
                    //               icon: Icon(Icons.delete,color: Colors.red,),
                    //               onPressed: _deleteImage,
                    //             ),
                    //           ],
                    //         ),
                    //     ),
                    // if (_downloadUrl != null)
                    //   Center(child: Text('Image Uploaded',style: TextStyle(color: colorSuccess),)),
                    //             SizedBox(
                    //           height: 2.h,
                    //         ),
                    Text(
                      'Set Budget amount ',
                      style: body4TextStyle.copyWith(
                          fontSize: 13.sp, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      'Select the starting and ending dates for your ads',
                      style: body3TextStyle.copyWith(
                        fontSize: 12,
                        color: textGrey2,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      // child: numberInputField(
                      //     'enter amount'.toUpperCase(), amountValueController,
                      //     (String input) {
                      //   // setState(() {
                      //   //   amountValue = input;
                      //   // });
                      // }),
                      child: TextField(
                        readOnly: true,
                        controller: amountValueController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide:
                                BorderSide(color: textGrey2, width: 0.1.h),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide:
                                BorderSide(color: textGrey2, width: 0.1.h),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.h),
                          labelText: "Total Amount",
                          labelStyle: body4TextStyle.copyWith(color: textGrey2),
                        ),
                      ),
                    ),
                    Text(
                      'your estimated benefits'.toUpperCase(),
                      style: body3TextStyle.copyWith(
                        letterSpacing: 0.7,
                        fontSize: 15,
                        color: textBlack,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      width: 100.w,
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.2.h, color: primaryColor),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/adsmenu.svg',
                            height: 4.h,
                          ),
                          Container(
                            height: 4.h,
                            width: 0.5.h,
                            color: primaryColor,
                          ),
                          Text(
                            '300',
                            style: body4TextStyle.copyWith(
                                fontSize: 18.sp,
                                color: primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Menu Visits',
                            style: body4TextStyle.copyWith(
                                fontSize: 18,
                                color: textBlack,
                                fontWeight: FontWeight.w600),
                          ),

                          // Expanded(
                          //   flex: 1,
                          //   child: Container(
                          //     width: 50.w,
                          //     child: Image.asset(
                          //       'assets/images/offer_img.png',
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      width: 100.w,
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.2.h, color: primaryColor),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            maxLines: 1,
                            '35',
                            style: body4TextStyle.copyWith(
                                fontSize: 18.sp,
                                color: primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'More Orders',
                            style: body4TextStyle.copyWith(
                                fontSize: 14.sp,
                                color: textBlack,
                                fontWeight: FontWeight.w600),
                          ),
                          Container(
                            height: 4.h,
                            width: 0.5.h,
                            color: primaryColor,
                          ),
                          SvgPicture.asset(
                            'assets/icons/adsbell.svg',
                            height: 4.h,
                          ),
                          // Expanded(
                          //   flex: 1,
                          //   child: Container(
                          //     width: 50.w,
                          //     child: Image.asset(
                          //       'assets/images/offer_img.png',
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      width: 100.w,
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.2.h, color: primaryColor),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/adsmenu2.svg',
                            height: 4.h,
                          ),
                          Container(
                            height: 4.h,
                            width: 0.5.h,
                            color: primaryColor,
                          ),
                          Text(
                            '300',
                            style: body4TextStyle.copyWith(
                                fontSize: 18.sp,
                                color: primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Menu Visits',
                            style: body4TextStyle.copyWith(
                                fontSize: 14.sp,
                                color: textBlack,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 2.h,
                      ),
                      child: mainButton(
                        'proceed to pay'.toUpperCase(),
                        textWhite,
                        () {
                          // createAdvertisement(
                          //     context); // Call the function here
                          if (startDate == null ||
                              endDate == null ||
                              // amountValue.isEmpty ||
                              _downloadUrl == null) {
                            // Handle validation error
                            Toast.showToast(
                                message: 'Please fill in all the fields',
                                isError: true);
                            return;
                          }
                          Navigator.of(context).push(transitionToNextScreen(
                              CheckoutScreen(
                                  amount: amount,
                                  itemToBePurchased: "Advertisment",
                                  onPaymentSuccess: createAdvertisement)));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]));
  }
}
