import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/coupons/coupon_controller.dart';
import 'package:user_app/Controller/coupons/couponmodel.dart';
import 'package:user_app/Controller/coupons/validate_coupon.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';

import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/customs/toasts.dart';

class CouponpageScreen extends StatefulWidget {
  const CouponpageScreen(
      {super.key, required this.price, required this.resid, this.couponCode});
  final double price;
  final String resid;
  final String? couponCode;

  @override
  State<CouponpageScreen> createState() => _CouponpageScreenState();
}

class _CouponpageScreenState extends State<CouponpageScreen> {
  final TextEditingController _couponController = TextEditingController();
  String selectedCoupon = '';
  List<Coupon> couponList = [];
  List<Coupon> filteredCoupons = [];
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    if (widget.couponCode != null) {
      selectedCoupon = widget.couponCode!;
    }
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    var coupons = await CouponController.getAllCoupons();
    // Filter the coupons where createdById matches the received resid
    couponList = coupons
        .where((coupon) =>
            coupon.createdById == widget.resid &&
            coupon.status.trim() == 'active')
        .toList();
    
    filteredCoupons =
        couponList; // Initially, filteredCoupons is the same as couponList
    if (mounted) {
      setState(() {});
    }
  }

  void applyCoupon() async {
    setState(() {
      isloading = true; // Start loading when the button is pressed
    });

    String enteredCoupon = _couponController.text.trim();
    if (enteredCoupon.isNotEmpty) {
      bool couponExists =
          couponList.any((coupon) => coupon.couponCode.trim() == enteredCoupon);

      if (couponExists) {
        var validationResponse =
            await CouponValidationController.validateCoupon(
                selectedCoupon, widget.price);
        if (validationResponse != null && validationResponse.isValid) {
          // selectedCoupon = enteredCoupon;
          Navigator.pop(context, {
            'selectedCoupon': selectedCoupon,
            'discountApplied': validationResponse.discountApplied,
          });
        } else {
          Toast.showToast(
              message: validationResponse?.message ??
                  'Couponcode is not applicable .. !',
              isError: true);
        }
      } else {
        Toast.showToast(message: 'Coupon Does not exist', isError: true);
      }
    }

    setState(() {
      isloading = false; // Stop loading regardless of success or failure
    });
  }

  void filterCoupons(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredCoupons = couponList
            .where((coupon) =>
                coupon.couponCode.toUpperCase().contains(query.toUpperCase()))
            .toList();
      } else {
        filteredCoupons = couponList;
      }
    });
  }

  void onCouponSelected(Coupon coupon) {
    setState(() {
      selectedCoupon = coupon.couponCode;
      _couponController.text = coupon.couponCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Coupons',
            style: TextStyle(color: isdarkmode ? textGrey2 : Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 5.h,
                      width: 50.w,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        ),
                        color: isdarkmode ? textBlack : textGrey3,
                      ),
                      child: TextField(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: isdarkmode ? textGrey2 : textBlack),
                        controller: _couponController,
                        onChanged: (value) => filterCoupons(value),
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          hintText: 'Enter Coupon Code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: applyCoupon,
                      child: isloading
                          ? const CircularProgressIndicator(
                              color: textWhite,
                            )
                          : const Text(
                              'Check',
                              style: TextStyle(color: textWhite),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                filteredCoupons.isEmpty
                    ? const Text(
                        'No coupons available for this restauarant .!!')
                    : Expanded(
                        child: ListView.builder(
                          itemCount: filteredCoupons.length,
                          itemBuilder: (context, index) {
                            var coupon = filteredCoupons[index];
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              child: Material(
                                color: isdarkmode ? textGrey1 : textWhite,
                                elevation: 2,
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2.h, horizontal: 2),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value:
                                            selectedCoupon == coupon.couponCode,
                                        onChanged: (bool? value) {
                                          if (value == true) {
                                            if (coupon.minOrderValue >
                                                widget.price) {
                                              Toast.showToast(
                                                  message:
                                                      "Coupon is valid for Item Total above ${coupon.minOrderValue}");
                                            } else {
                                              onCouponSelected(coupon);
                                            }
                                          } else {
                                            setState(() {
                                              selectedCoupon = '';
                                              _couponController.text = '';
                                            });
                                          }
                                        },
                                        activeColor: Colors.red,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              coupon.couponCode,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isdarkmode
                                                      ? textGrey2
                                                      : textBlack),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Save ${coupon.flatRsOff}',
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            Text(
                                              '${coupon.discountPercentage}% off on minimum purchase of Rs.${coupon.minOrderValue}',
                                              style: TextStyle(
                                                  color: isdarkmode
                                                      ? textGrey2
                                                      : textBlack),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                if (selectedCoupon.isEmpty)
                  mainButton("Proceed", Colors.white, () {
                    Navigator.of(context).pop({
                      'selectedCoupon': null,
                      'discountApplied': 0,
                    });
                  })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
