import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart';
import 'package:restaurant_app/Controller/earnings_controller.dart';
import 'package:restaurant_app/Controller/notification.dart';
import 'package:restaurant_app/Controller/order/orders_model.dart';
import 'package:restaurant_app/Controller/wallet_controller.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/toast.dart';
import 'package:sizer/sizer.dart';

class TakeawayScreen extends StatefulWidget {
  const TakeawayScreen({super.key, required this.orderData});
  final OrderData orderData;

  @override
  State<TakeawayScreen> createState() => _TakeawayScreenState();
}

class _TakeawayScreenState extends State<TakeawayScreen> {
  String enteredOtp = '';
  String otp = '';
  bool verifyingOtp = false;
  Map billingData = {};

  @override
  void initState() {
    super.initState();
    getOtp();
  }

  void getOtp() async {
    final data = (await FirebaseFirestore.instance
            .collection('tracking')
            .doc(widget.orderData.orderId!)
            .get())
        .data()!;
    otp = (widget.orderData.ordertype == "Delivery"
            ? data['pickupOtp']
            : data['otp']) ??
        '';
    billingData = widget.orderData.billingDetail!;
  }

  Future<void> verifyOtp() async {
    if (enteredOtp == otp) {
      setState(() {
        verifyingOtp = true;
      });
      try {
        // String baseurl = dotenv.env['BASE_URL']!;
        String baseurl = AppStrings.baseURL;
        final response = await put(
            Uri.parse(
                '$baseurl/order/orders/${widget.orderData.orderByid!}/${widget.orderData.orderId!}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "updateData": {
                "status": widget.orderData.ordertype == "Delivery"
                    ? "On the way"
                    : "Delivered"
              }
            }));
        if (response.statusCode == 200) {
          if (widget.orderData.ordertype != "Delivery") {
            final earningCreated = await EarningsController.addEarning(
                uid: widget.orderData.restaurantuid!,
                orderId: widget.orderData.orderId!,
                userId: widget.orderData.orderByid!,
                amount: billingData["nukkad_earning"].toDouble());
            WalletController.credit(
                billingData['nukkad_wallet_cash'].toDouble(),
                "For orderId: ${widget.orderData.orderId}");
            if (earningCreated) {
              Navigator.of(context).pop(true);
            }
          } else {
            await FirebaseFirestore.instance.runTransaction((t) async {
              t.update(
                  FirebaseFirestore.instance
                      .collection('tracking')
                      .doc(widget.orderData.orderId),
                  {'status': "On the way", 'pickedup': true});
            });
            final restaurantName = jsonDecode(SharedPrefsUtil()
                .getString(AppStrings.restaurantModel)!)['user']['nukkadName'];
            NotificationService.sendNotification(
                toUid: widget.orderData.orderByid!,
                toApp: "user",
                title: "Order on the way",
                body:
                    "Your order from ${restaurantName ?? ''} is heading to you!");
            Navigator.of(context).pop(true);
          }
        }
      } catch (e) {
        print(e);
      }
    } else {
      Toast.showToast(message: "Invalid Otp", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          height: double.maxFinite,
          decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  opacity: 0.7,
                  image: AssetImage('assets/images/otpbg.png'),
                  fit: BoxFit.cover)),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                icon: Icon(Icons.arrow_back_ios_new)),
            title: Text(
              'Food Delivery',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order ID',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '#${widget.orderData.orderId}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8))),
                          child: Center(
                            child: Text(
                              'Delivering ${widget.orderData.totalItems!} Items',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        for (var item in widget.orderData.items!)
                          ListTile(
                            minTileHeight: 70,
                            minLeadingWidth: 60,
                            leading: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorSuccess,
                              ),
                              child: Text(
                                '${item.itemQuantity!} x',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                            title: Text(
                              item.itemName!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            'Fill the OTP',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        OtpTextField(
                          fieldHeight: 8.h,
                          fieldWidth: 15.w,
                          numberOfFields: 4,
                          borderColor: Color(0xFFE5DDDD),
                          focusedBorderColor: Colors.black,
                          cursorColor: Colors.black,
                          borderRadius: BorderRadius.circular(7),
                          showFieldAsBox: true,
                          clearText: true,
                          textStyle: TextStyle(
                            color: Color(0xFFFE724C),
                            fontSize: 23,
                          ),
                          onSubmit: (String verificationCode) {
                            enteredOtp = verificationCode;
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(
                          height: 25,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: !verifyingOtp
                          ? () {
                              verifyOtp();
                            }
                          : () {},
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              enteredOtp.length == 4
                                  ? primaryColor
                                  : Colors.grey),
                          minimumSize:
                              WidgetStatePropertyAll(Size(double.infinity, 50)),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))))),
                      child: verifyingOtp
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(2),
                                  child: CircularProgressIndicator(),
                                ),
                                Text(
                                  widget.orderData.ordertype == "Delivery"
                                      ? "  Verifying..."
                                      : '  Completing Takeaway...',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ],
                            )
                          : Text(
                              widget.orderData.ordertype == "Delivery"
                                  ? "Handover"
                                  : 'Complete Takeaway',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
