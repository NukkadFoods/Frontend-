import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Screens/homeScreen.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:another_stepper/another_stepper.dart';
import 'package:user_app/map/liveordertracking.dart';
import 'package:intl/intl.dart';
import 'package:user_app/screens/Orders/delivery_completed_screen.dart';
import 'package:user_app/screens/Support/chatSupportScreen.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/orderprogress.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:user_app/widgets/customs/toasts.dart'; // For formatting time

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen(
      {super.key,
      required this.nukkad,
      required this.Amount,
      required this.orderid,
      // required this.Status,
      required this.time,
      required this.deliveryTime,
      required this.orderedAt,
      required this.isDelivery});
  final Restaurants nukkad;
  final String Amount;
  final String orderid;
  // final String Status;
  final String time;
  final DateTime deliveryTime;
  final DateTime orderedAt;
  final bool isDelivery;
  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  String? resname = '';
  String status = "";
  double? price;
  String? uorderid = '';
  String placedAtTime = '';
  int activein = 1;
  int estimatetime = 0;
  String deliverytime = '';
  String? otp;
  GlobalKey key = GlobalKey();
  double spacing = 0;
  String dboyId = 'unassigned';
  late Stream<DocumentSnapshot<Map<String, dynamic>>> db;
  List<StepperData> stepperData = []; // Declare it here
  Map? dboyData;
  bool newMessage = false;

  @override
  void initState() {
    super.initState();
    // Load previously saved payment method
    calculateOrderTimes(); // Calculate times for "Placed at" and "Delivery by"
    removePaymentMethod();
    initializeStepperData();
    getotp(); // Initialize stepperData based on activein
  }

  Future<void> removePaymentMethod() async {
    final prefs = await SharedPreferences.getInstance();
    resname = prefs.getString('restaurant_name') ?? 'unable to load';
    price = prefs.getDouble('order_price');
    uorderid = prefs.getString('orderid') ?? '944671326686';
    setState(() {});
    await prefs.remove('payment_name');
    print('Payment type removed from SharedPreferences');
  }

  void calculateOrderTimes() {
    db = FirebaseFirestore.instance
        .collection('tracking')
        .doc(widget.orderid)
        .snapshots();
    db.listen((data) {
      if (data.data()!['status'] != status ||
          dboyId != data.data()!['dBoyId']) {
        dboyId = data.data()!['dBoyId'];
        status = data.data()!['status'];
        switch (status) {
          case 'Pending':
            activein = 1;
            break;
          case 'Accepted':
            activein = 2;
            break;
          case 'Preparing':
            activein = 3;
            break;
          case 'Ready':
            activein = widget.isDelivery ? 3 : 5;
            break;
          case 'On the way':
            activein = 4;
            break;
          case 'Delivered':
            activein = 5;
            navigateToOrderComplete();
            break;
        }
        newMessage = (data.data()!['unreadByUser'] ?? 0) > 0;
        state();
      }
    });
  }

  void state() async {
    await getDboyData();
    if (mounted) {
      initializeStepperData();
      setState(() {});
    }
  }

  Future<void> getDboyData() async {
    if (dboyData != null || dboyId == 'unassigned') {
      return;
    }
    try {
      final baseurl = AppStrings.baseURL;
      final response =
          await http.get(Uri.parse('$baseurl/auth/getDeliveryBoyById/$dboyId'));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        dboyData = responseData['deliveryBoy'];
      }
    } on http.ClientException {
      Toast.showToast(message: "Connection Problem...", isError: true);
    }
  }

  String addSecondsToTime() {
    // Parse the input time string
    DateFormat inputFormat = DateFormat("h:mm");
    // h:mm a for 12-hour format with AM/PM
    print(widget.time);
    DateTime dateTime = inputFormat.parse(widget.time);

    // Add the specified number of seconds
    dateTime = dateTime.add(Duration(seconds: estimatetime));

    // Format the DateTime back to string
    DateFormat outputFormat = DateFormat("h:mm a"); // Same format as input
    deliverytime = outputFormat.format(dateTime);

    return deliverytime;
  }

  void initializeStepperData() {
    stepperData = [
      StepperData(
        title: StepperText(
          "Yay! Order Placed!",
          textStyle: h5TextStyle.copyWith(color: textGrey1, fontSize: 13.sp),
        ),
        iconWidget: Container(
          padding: EdgeInsets.all(0.5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: primaryColor,
              width: 0.2.h,
            ),
          ),
          child: SvgPicture.asset(
            'assets/icons/order_placed_icon.svg',
            height: 2.h,
            // Change color based on activein value
          ),
        ),
      ),
      StepperData(
        title: StepperText("Order Accepted by Stall",
            textStyle: h5TextStyle.copyWith(color: textGrey1, fontSize: 13.sp)),
        iconWidget: Container(
          padding: EdgeInsets.all(0.5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: activein >= 2 ? primaryColor : textGrey2,
              width: 0.2.h,
            ),
          ),
          child: SvgPicture.asset(
            'assets/icons/stall_icon.svg',
            height: 2.h,
            color: activein >= 2
                ? primaryColor
                : textGrey2, // Change color based on activein value
          ),
        ),
      ),
      StepperData(
        title: StepperText(
          "Food Preparing",
          textStyle: h5TextStyle.copyWith(color: textGrey1, fontSize: 13.sp),
        ),
        iconWidget: Container(
          padding: EdgeInsets.all(0.5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: activein >= 3 ? primaryColor : textGrey2,
              width: 0.2.h,
            ),
          ),
          child: SvgPicture.asset(
            'assets/icons/food_preparing_icon.svg',
            height: 2.h,
            color: activein >= 3
                ? primaryColor
                : textGrey2, // Update active step's icon color
          ),
        ),
      ),
      if (widget.isDelivery)
        StepperData(
          title: StepperText(
            "Picked up by delivery partner",
            textStyle: h5TextStyle.copyWith(color: textGrey1, fontSize: 13.sp),
          ),
          iconWidget: Container(
            padding: EdgeInsets.all(0.5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: activein >= 4 ? primaryColor : textGrey2,
                width: 0.2.h,
              ),
            ),
            child: SvgPicture.asset(
              'assets/icons/delivering_icon.svg',
              height: 2.h,
              color: activein >= 4
                  ? primaryColor
                  : textGrey2, // Active color check
            ),
          ),
        ),
      StepperData(
        title: StepperText(
          widget.isDelivery
              ? "Deliciousness delivered to you!"
              : "Order Ready for Takeaway",
          textStyle: h5TextStyle.copyWith(color: textGrey1, fontSize: 13.sp),
        ),
        iconWidget: Container(
          padding: EdgeInsets.all(0.5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: activein >= 5 ? primaryColor : textGrey2,
              width: 0.2.h,
            ),
          ),
          child: SvgPicture.asset(
            'assets/icons/delivered_icon.svg',
            height: 2.h,
            colorFilter: ColorFilter.mode(
                activein >= 5 ? primaryColor : textGrey2, BlendMode.srcATop),
            // Change color if activein is 5
          ),
        ),
      ),
    ];
  }

  void getotp() async {
    final data = await FirebaseFirestore.instance
        .collection('tracking')
        .doc(widget.orderid)
        .get();

    // Fetch and store the dboyId from the Firestore document
    otp = data.data()?['otp'];

    // Debug print to verify the fetched dboyId
    print('Delivery Boy ID: $otp');
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
          icon: Icon(Icons.arrow_back_ios,
              color: isdarkmode ? textGrey2 : textBlack),
        ),
        title: Container(
          width: 70.w,
          margin: EdgeInsets.symmetric(vertical: 2.h),
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          child: Column(
            children: [
              Text(
                widget.orderid,
                style: h5TextStyle.copyWith(
                    color: isdarkmode ? textGrey2 : textBlack),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                width: 2.w,
              ),
              Text(
                'Placed at ${widget.time}| Delivery by $deliverytime',
                style: body5TextStyle.copyWith(color: textGrey2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: widget.isDelivery
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: OrderPreparingCard(
                key: key,
                estimatedTime: widget.deliveryTime,
                status: status,
                orderid: widget.orderid,
                orderedAt: widget.orderedAt,
              ),
            )
          : null,
      body: Column(
        children: [
          SizedBox(
              height: 30.h,
              width: 100.w,
              child: Liveordertracking(
                db: db,
                orderid: widget.orderid,
                nukkad: widget.nukkad,
                isDelivery: widget.isDelivery,
                onEstimatedTimeCalculated: (estimatedtime) {
                  setState(() {
                    estimatetime =
                        estimatedtime + 900; // + 15 mins of preaparation time
                    print('estimated time: $estimatetime');
                    addSecondsToTime();
                  });
                },
              )),
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              children: [
                Material(
                  elevation: 10.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 6.h,
                          child: Material(
                            elevation: 2,
                            color: isdarkmode ? textGrey1 : textWhite,
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: 6.h,
                              width: double.maxFinite,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${widget.nukkad.nukkadName}',
                                        style: h5TextStyle.copyWith(
                                            color: isdarkmode
                                                ? textGrey2
                                                : textBlack,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    VerticalDivider(
                                      color: isdarkmode ? textGrey2 : textBlack,
                                      indent: 20,
                                      endIndent: 20,
                                      thickness: 0.3.h,
                                    ),
                                    Text(
                                      '₹ ${double.parse(widget.Amount).toStringAsFixed(2)}',
                                      style: h5TextStyle.copyWith(
                                          color: isdarkmode
                                              ? textGrey2
                                              : textBlack),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          status.toLowerCase().trim() == 'on the way' ||
                                  !widget.isDelivery
                              ? "Your Order Otp is $otp "
                              : 'Your otp for this Order will be shown here in some Time',
                          style: h6TextStyle.copyWith(color: primaryColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isdarkmode
                                    ? Colors.grey[800]
                                    : Colors.grey[200]!,
                                border: Border.all(color: Colors.amberAccent)),
                            child: const Text(
                              "⚠ Please do not share otp with Delivery Person before recieving order",
                              textAlign: TextAlign.center,
                            )),
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            AnotherStepper(
                              verticalGap: 15,
                              activeIndex: activein,
                              stepperList: stepperData,
                              stepperDirection: Axis.vertical,
                              iconHeight: 5.h,
                              iconWidth: 5.h,
                              activeBarColor: primaryColor,
                              inActiveBarColor: textGrey2,
                            ),
                            if (widget.isDelivery)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (dboyId == 'unassigned' ||
                                            dboyData == null) {
                                          Toast.showToast(
                                              message:
                                                  "Delivery Person is not assigned yet.");
                                          getDboyData();
                                        } else {
                                          showDboyDetails();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          elevation: 2,
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        width: 17.w,
                                        height: 17.w,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: primaryColor)),
                                        child: const CircleAvatar(
                                          foregroundImage: AssetImage(
                                              "assets/images/dboy.png"),
                                        ),
                                      ),
                                    ),
                                    if (newMessage)
                                      const DecoratedBox(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: primaryColor),
                                        child: SizedBox(
                                          height: 15,
                                          width: 15,
                                        ),
                                      )
                                  ],
                                ),
                              )
                          ],
                        ),
                        SizedBox(height: 5.h)
                      ],
                    ),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  void showDboyDetails() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Colors.grey)),
              insetPadding: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Delivery Person Info",
                      style: h4TextStyle.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : null),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      dboyData!['name'],
                      style: body3TextStyle.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : null),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dboyData!['contact'],
                      style: body3TextStyle.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : null),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            launchUrl(Uri.parse("tel:${dboyData!['contact']}"));
                          },
                          child: SvgPicture.asset('assets/icons/dial.svg'),
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: () => Navigator.of(context)
                              .push(transitionToNextScreen(ChatSupportScreen(
                            orderId: widget.orderid,
                            dboyId: dboyId,
                          ))),
                          child: SvgPicture.asset('assets/icons/msg.svg'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  void navigateToOrderComplete() {
    Navigator.of(context).pushReplacement(
        transitionToNextScreen(const DeliveryCompletedScreen()));
  }
}
