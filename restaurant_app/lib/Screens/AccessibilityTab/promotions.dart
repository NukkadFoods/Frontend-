import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/promotions/Coupon_controller.dart';
import 'package:restaurant_app/Controller/promotions/Coupon_model.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/allcouponlist.dart';
import 'package:restaurant_app/Widgets/input_fields/numberInputField.dart';
import 'package:restaurant_app/Widgets/input_fields/textInputField.dart';
import 'package:restaurant_app/Widgets/toast.dart';
// import 'package:restaurant_app/homeScreen.dart';
import 'package:sizer/sizer.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  String couponCode = '';
  String discount = '';
  String flatRsOff = '';
  String minOrderValue = '';
  String maxDiscount = '';

  final couponCodeController = TextEditingController();
  final discountController = TextEditingController();
  final flatRsOffController = TextEditingController();
  final orderValueController = TextEditingController();
  final maxDiscountController = TextEditingController();

  List<Coupon> couponsList = [];
  @override
  void initState() {
    super.initState();
    getAllCouponsById();
  }

  Future<void> getAllCouponsById() async {
    try {
      String userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";

      // Ensure the userId is not empty
      if (userId.isEmpty) {
        print('User ID is empty');
        return;
      }

      // Call the controller method
      final response =
          await CouponController.getAllCouponsByCreatedById(userId);

      if (response != null && response.coupons.isNotEmpty) {
        // Handle successful response, e.g., update the state with the coupons
        setState(() {
          couponsList = response.coupons;
        });
        print('Coupons retrieved: ${response.coupons}');
      } else {
        print('No coupons found for this user');
      }
    } catch (e) {
      print('Error occurred while fetching coupons: $e');
    }
  }

  refreshCoupons() {
    getAllCouponsById();
  }

  @override
  void dispose() {
    couponCodeController.dispose();
    discountController.dispose();
    flatRsOffController.dispose();
    orderValueController.dispose();
    maxDiscountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff35BA2A)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10.0), // Adjust the curve as needed
        ),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text('Promotions', style: h4TextStyle),
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create exciting offers on your restaurant to boost sales and more customer interaction',
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
                    Text(
                      'Trending offers'.toUpperCase(),
                      style: body3TextStyle.copyWith(
                        letterSpacing: 0.7,
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        child: Image.asset(
                          'assets/images/promotion_offer.png',
                          height: 200,
                          width: double.maxFinite,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      'Ongoing offers'.toUpperCase(),
                      style: body3TextStyle.copyWith(
                        letterSpacing: 1.5,
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),

                    CouponsList(
                      coupons: couponsList,
                      onRefresh: refreshCoupons,
                    ),

                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      'recommended offers'.toUpperCase(),
                      style: body3TextStyle.copyWith(
                        letterSpacing: 0.7,
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            // width: 100.w,
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 0.2.h, color: Color(0xffFAFF00)),
                              color: Color(0xffFEFFCF),
                              borderRadius: BorderRadius.circular(7),
                              boxShadow: [
                                BoxShadow(
                                  color: colorwarnig
                                      .withOpacity(0.3), // Shadow color
                                  spreadRadius: 2, // Spread radius
                                  blurRadius: 5, // Blur radius
                                  offset: Offset(
                                      2, 2), // Offset in the x and y directions
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 40.w,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        maxLines: 2,
                                        'Free Dish',
                                        style: body3TextStyle.copyWith(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.start,
                                      ),
                                      SizedBox(
                                        height: 1.5.h,
                                      ),
                                      Text(
                                        'On orders above ₹350',
                                        style: body5TextStyle.copyWith(
                                            color: Color(0XffFF4C00),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.start,
                                      ),
                                      SizedBox(
                                        height: 1.5.h,
                                      ),
                                      ElevatedButton(
                                          onPressed: () {},
                                          style: buttonStyle,
                                          child: Text(
                                            'Activate',
                                            style: body5TextStyle.copyWith(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                          ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 0.2.h, color: Color(0xffFAFF00)),
                              color: Color(0xffFEFFCF),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Container(
                              width: 40.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    maxLines: 2,
                                    '50% Off',
                                    style: body3TextStyle.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(
                                    height: 1.5.h,
                                  ),
                                  Text(
                                    'On orders above ₹350',
                                    style: body5TextStyle.copyWith(
                                        color: Color(0XffFF4C00),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(
                                    height: 1.5.h,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {},
                                      style: buttonStyle,
                                      child: Text(
                                        'Activate',
                                        style: body5TextStyle.copyWith(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      'Create your own offer'.toUpperCase(),
                      style: body3TextStyle.copyWith(
                        letterSpacing: 0.7,
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    // Column(
                    //   children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: textInputField('create  coupon code'.toUpperCase(),
                          couponCodeController, (String input) {
                        setState(() {
                          couponCode = input;
                        });
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: textInputField('discount percentage'.toUpperCase(),
                          discountController, (String input) {
                        setState(() {
                          discount = input;
                        });
                      }),
                    ),
                    Text(
                      'Or'.toUpperCase(),
                      style: body3TextStyle.copyWith(
                        letterSpacing: 0.7,
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: numberInputField(
                          'flat rs off'.toUpperCase(), flatRsOffController,
                          (String input) {
                        setState(() {
                          flatRsOff = input;
                        });
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: numberInputField('Min. order value'.toUpperCase(),
                          orderValueController, (String input) {
                        setState(() {
                          minOrderValue = input;
                        });
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: textInputField(
                          'Max. discount'.toUpperCase(), maxDiscountController,
                          (String input) {
                        setState(() {
                          maxDiscount = input;
                        });
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 2.h,
                      ),
                      child: mainButton('create +', textWhite, _createCoupon),
                    ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ]));
  }

  Future<void> _createCoupon() async {
    final coupon = Coupon(
      createdById: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
      couponCode: couponCode,
      discountPercentage: int.tryParse(discount) ?? 5,
      flatRsOff: int.tryParse(flatRsOff) ?? 0,
      minOrderValue: int.tryParse(minOrderValue) ?? 0,
      maxDiscount: int.tryParse(maxDiscount) ?? 0,
      status: 'active',
    );

    bool success = await CouponController.createCoupon(coupon);
    if (success) {
      Toast.showToast(message: 'Coupon Created Succesfully ..!!');
      Navigator.of(context).pop();
    } else {
      Toast.showToast(message: 'Coupon Creation Failed ..!!', isError: true);
      Navigator.of(context).pop();
    }

    Navigator.of(context).pop();
  }
}
