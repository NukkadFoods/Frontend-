import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/providers/delivery_provider.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:driver_app/widgets/sigin_signup/otp_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({
    super.key,
    required this.orderData,
    required this.restaurant,
    required this.billingData, this.deliveryInstruction,
  });
  final OrderData orderData;
  final Restaurant restaurant;
  final Map billingData;
  final String? deliveryInstruction;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeliveryProvider(orderData,restaurant),
      builder: (context, child) => Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            height: double.maxFinite,
            decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    opacity: 0.7,
                    image: AssetImage('assets/images/otpbbg.png'),
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
                    fontSize: medium,
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
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: colorGray),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Column(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Order ID',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: medium,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '#${orderData.orderId}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: medium,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: RichText(
                              // textAlign: TextAlign.center,?
                              text: TextSpan(children: [
                            TextSpan(
                                text: orderData.orderByName!,
                                style: TextStyle(
                                    fontSize: mediumSmall,
                                    color: colorBrightGreen,
                                    fontWeight: w600,
                                    height: 2)),
                            TextSpan(
                                text: '\n${orderData.deliveryAddress}',
                                style: TextStyle(
                                    fontSize: small,
                                    height: 1.5,
                                    color: Colors.black))
                          ])),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                border: Border.all(color: colorBrightGreen)),
                            child: RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: 'Delivery Instructions:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorBrightGreen,
                                        fontWeight: w600,
                                      )),
                                  TextSpan(
                                      text:
                                          ' ${deliveryInstruction??"No Instructions"}.',
                                      style: TextStyle(
                                          fontSize: small, color: Colors.black))
                                ])),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: colorGray),
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
                                'Delivering ${orderData.totalItems!} Items',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: mediumSmall,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          for (var item in orderData.items!)
                            ListTile(
                              minTileHeight: 70,
                              minLeadingWidth: 60,
                              leading: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorGreen,
                                ),
                                child: Text(
                                  '${item.itemQuantity!} x',
                                  style: TextStyle(
                                      fontSize: medium,
                                      fontWeight: w600,
                                      color: Colors.white),
                                ),
                              ),
                              title: Text(
                                item.itemName!,
                                style: TextStyle(
                                  fontSize: mediumSmall,
                                  fontWeight: w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Consumer<DeliveryProvider>(
                      builder: (context, value, child) => value.otpSent
                          ? Card(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      'Fill the OTP',
                                      style: TextStyle(fontSize: small),
                                    ),
                                  ),
                                  OtpField(
                                      controller1: value.controller1,
                                      controller2: value.controller2,
                                      controller3: value.controller3,
                                      controller4: value.controller4),
                                  const SizedBox(
                                    height: 25,
                                  )
                                ],
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                value.sendOtp();
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(colorBrightGreen),
                                  minimumSize: WidgetStatePropertyAll(
                                      Size(double.infinity, 50)),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))))),
                              child: value.sendingOtp
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                        Text(
                                          '   Sending Otp',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: w600,
                                              color: Colors.white),
                                        )
                                      ],
                                    )
                                  : Text(
                                      'Send Otp',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: w600,
                                          color: Colors.white),
                                    )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Consumer<DeliveryProvider>(
                      builder: (context, value, child) => ElevatedButton(
                          onPressed: value.showButton() && !value.verifyingOtp
                              ? () {
                                  value.verifyOtp(
                                      context, orderData, billingData);
                                }
                              : () {},
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  value.showButton()
                                      ? colorBrightGreen
                                      : colorGray),
                              minimumSize: WidgetStatePropertyAll(
                                  Size(double.infinity, 50)),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8))))),
                          child: value.verifyingOtp
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: CircularProgressIndicator(),
                                    ),
                                    Text(
                                      '  Completing Delivery...',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: w600,
                                          color: Colors.white),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Delivery Complete',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: w600,
                                      color: Colors.white),
                                )),
                    )
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
