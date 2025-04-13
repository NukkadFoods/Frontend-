// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/orders/orders_model.dart';
// import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/utils/font-styles.dart';
// import 'package:driver_app/widgets/common/loading_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
import '../../providers/pickup_provider.dart';
import '../../utils/colors.dart';

class PickupScreen extends StatelessWidget {
  const PickupScreen(
      {super.key,
      required this.restaurant,
      required this.orderData,
      required this.remainingTime});
  final Restaurant restaurant;
  final OrderData orderData;
  final CountDown remainingTime;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PickupProvider(orderData.orderId!),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios_new)),
          title: Text(
            'Pickup food',
            style: TextStyle(
                color: Colors.black,
                fontSize: medium,
                fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          decoration: BoxDecoration(
              image: DecorationImage(
                  opacity: 0.7,
                  image: AssetImage('assets/images/otpbbg.png'),
                  fit: BoxFit.cover)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                StreamBuilder<int>(
                    stream: remainingTime.stream,
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return SizedBox.shrink();
                      }
                      return Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.flip(
                                flipX: true,
                                child: CircularProgressIndicator(
                                  value: snapshot.data! /
                                      remainingTime.totalSeconds,
                                  valueColor:
                                      AlwaysStoppedAnimation(colorGreen),
                                ),
                              ),
                              Text(
                                '${(snapshot.data!.isNegative ? snapshot.data! * -1 : snapshot.data!) ~/ 60}',
                                style: TextStyle(
                                    color: colorGreen,
                                    fontWeight: w600,
                                    fontSize: medium),
                              )
                            ],
                          ),
                          Text(
                              '    ${(snapshot.data!.isNegative ? snapshot.data! * -1 : snapshot.data!) ~/ 60} ${snapshot.data!.isNegative ? "Mins Late" : 'Mins left'}',
                              style: TextStyle(
                                  color: colorGreen,
                                  fontWeight: w600,
                                  fontSize: medium))
                        ],
                      );
                    }),
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
                              orderData.orderId!,
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
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width -
                                      85 -
                                      70,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(restaurant.nukkadName!,
                                        style: TextStyle(
                                            color: colorGreen,
                                            fontSize: mediumSmall,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(restaurant.nukkadAddress!,
                                        style: TextStyle(
                                            fontSize: small,
                                            color: Colors.black87))
                                  ],
                                ),
                              ),
                              Image.asset(
                                'assets/dummy/areaimg.png',
                                height: 85,
                                width: 85,
                              )
                            ]),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
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
                            'Pickup ${orderData.totalItems!} Items',
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
                              '${item.itemQuantity} x',
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
                      Consumer<PickupProvider>(
                        builder: (context, value, child) => ElevatedButton(
                            onPressed: () {
                              if (!value.showButton) value.toggleShowButton();
                            },
                            style: ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8)))),
                                minimumSize: WidgetStatePropertyAll(Size(
                                    MediaQuery.of(context).size.width, 50)),
                                backgroundColor: WidgetStatePropertyAll(
                                    value.showButton
                                        ? colorGray
                                        : colorBrightGreen)),
                            child: value.showButton
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        ' Items Confirmed',
                                        style: TextStyle(
                                            fontSize: medium,
                                            color: Colors.white,
                                            fontWeight: w600),
                                      )
                                    ],
                                  )
                                : Text(
                                    'Confirm Items',
                                    style: TextStyle(
                                        fontSize: medium,
                                        color: Colors.white,
                                        fontWeight: w600),
                                  )),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                Consumer<PickupProvider>(
                  builder: (context, value, child) =>
                      value.otp.isNotEmpty && value.showButton
                          ? Text(
                              "Please Share this otp with Nukkad to complete pick up\n${value.otp}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: colorGreen,
                                  fontSize: medium,
                                  fontWeight: FontWeight.w600),
                            )
                          : const SizedBox.shrink(),
                ),

                // Card(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       Padding(
                //         padding: const EdgeInsets.all(15.0),
                //         child: Text(
                //           'Fill the OTP',
                //           style: TextStyle(fontSize: small),
                //         ),
                //       ),
                //       Consumer<PickupProvider>(
                //           builder: (context, value, child) => Column(
                //                 children: [
                //                   OtpField(
                //                       controller1: value.controller1,
                //                       controller2: value.controller2,
                //                       controller3: value.controller3,
                //                       controller4: value.controller4),
                //                   // value.showOtp
                //                   //     ?
                //                   SizedBox(
                //                     height: 30,
                //                   ),
                //                   // : SizedBox.shrink(),
                //                 ],
                //               )),
                //     ],
                //   ),
                // ),
                const SizedBox(
                  height: 20,
                ),
                Consumer<PickupProvider>(
                  builder: (context, value, child) => ElevatedButton(
                      onPressed: value.showButton && value.pickedUp
                          ? () async {
                              value.toggleShowButton();
                              // showLoadingPopup(
                              //     context, "Updating Order Status");
                              // final response = await http.put(
                              //     Uri.parse(
                              //         '${value.baseurl}/order/orders/${orderData.orderByid!}/${orderData.orderId!}'),
                              //     headers: {'Content-Type': 'application/json'},
                              //     body: jsonEncode({
                              //       "updateData": {"status": "On the way"}
                              //     }));
                              // if (response.statusCode == 200 ||
                              //     response.statusCode == 200) {
                              //   FirebaseFirestore.instance
                              //       .runTransaction((transaction) async {
                              //     transaction.update(
                              //         FirebaseFirestore.instance
                              //             .collection("tracking")
                              //             .doc(orderData.orderId!),
                              //         {
                              //           "pickedup": true,
                              //           "status": "On the way"
                              //         });
                              //   });
                              //   Navigator.of(context).pop();
                              Navigator.of(context).pop(true);
                              // } else {
                              //   Toast.showToast(
                              //       message:
                              //           'Error while updating the status of order',
                              //       isError: true);
                              // }
                              value.toggleShowButton();
                            }
                          : () {},
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              value.showButton && value.pickedUp
                                  ? colorBrightGreen
                                  : colorGray),
                          minimumSize:
                              WidgetStatePropertyAll(Size(double.infinity, 50)),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))))),
                      child: Text(
                        'Complete Pickup',
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
    );
  }
}
