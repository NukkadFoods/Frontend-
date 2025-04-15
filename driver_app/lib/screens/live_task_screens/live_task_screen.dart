import 'dart:io';
import 'package:driver_app/controller/orders/order_controller.dart';
import 'package:driver_app/screens/support_screens/chat_page.dart';
import 'package:driver_app/screens/support_screens/help_center_screen.dart';
import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/providers/live_task_provider.dart';
import 'package:driver_app/screens/live_task_screens/delivery_screen.dart';
import 'package:driver_app/screens/live_task_screens/pickup_screen.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:driver_app/widgets/home/dotted_line.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/colors.dart';
import '../../utils/font-styles.dart';

class LiveTaskScreen extends StatelessWidget {
  const LiveTaskScreen({
    super.key,
    required this.orderData,
    required this.restaurant,
    required this.billingData,
    required this.userPosition,
  });
  final OrderData orderData;
  final Restaurant restaurant;
  final Map billingData;
  final LatLng userPosition;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // lazy:false,
      create: (context) => LiveTaskProvider(orderData,userPosition),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'LIVE TASKS',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
          ),
          actions: [
            // TextButton(
            //   onPressed: () {},
            //   child: SvgPicture.asset(
            //     'assets/svgs/bell.svg',
            //     height: 30,
            //   ),
            // ),
            // TextButton(
            //     onPressed: () {}, child: Image.asset('assets/images/sos.png')
            //     // height: 30,
            //     ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .push(transitionToNextScreen(const HelpCentreScreen()));
              },
              child: Text(
                'Help',
                style: TextStyle(
                  color: colorGreen,
                  fontSize: mediumLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          decoration: BoxDecoration(
              image: DecorationImage(
                  opacity: 0.7,
                  image: AssetImage('assets/images/otpbbg.png'),
                  fit: BoxFit.cover)),
          child: Consumer<LiveTaskProvider>(
            builder: (context, value, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const SizedBox(
                //   height: 15,
                // ),
                Consumer<LiveTaskProvider>(
                  builder: (context, value, child) => value.remainingTime ==
                              null ||
                          value.isLoading
                      ? const SizedBox.shrink()
                      : StreamBuilder<int>(
                          stream: context
                              .read<LiveTaskProvider>()
                              .remainingTime!
                              .stream,
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
                                            value.remainingTime!.totalSeconds,
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
                ),
                const SizedBox(
                  height: 20,
                ),
                if (!value.pickedUp && !value.isLoading)
                  Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                        bottom: value.acceptedByRestaurant == false ? 5 : 10),
                    decoration: BoxDecoration(
                        color: value.acceptedByRestaurant == true
                            ? colorGreen
                            : value.acceptedByRestaurant == false
                                ? Colors.red
                                : Colors.green,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text(value.acceptedByRestaurant == true
                            ? 'Order is accepted by Nukkad now you can move towards Nukkad'
                            : value.acceptedByRestaurant == false
                                ? 'Order has been declined by Nukkad, Press below button to search for new Orders'
                                : 'Order has not yet accepted by Nukkad'),
                        if (value.acceptedByRestaurant == false)
                          ElevatedButton(
                              onPressed: () async {
                                OrderController.orderDelivered(value.orderData);
                                DutyController.startDuty(context);
                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  backgroundColor: WidgetStatePropertyAll(
                                      context
                                              .read<LiveTaskProvider>()
                                              .showUploadImage
                                          ? colorGray
                                          : colorBrightGreen)),
                              child: Text(
                                'Search for new Orders',
                                style: TextStyle(
                                    fontSize: medium,
                                    color: Colors.white,
                                    fontWeight: w600),
                              ))
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Consumer<LiveTaskProvider>(
                  builder: (context, value, child) => value.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: colorGray),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(
                                            value.pickedUp ? 8 : 0),
                                        bottomRight: Radius.circular(
                                            value.pickedUp ? 8 : 0))),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                            'assets/svgs/pick.svg'),
                                        Text(
                                          ' Pickup Food',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: large,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                    if (value.pickedUp)
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: colorBrightGreen,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.white,
                                                size: 15,
                                              ),
                                              Text(
                                                '  Pickup Completed',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: w600,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                              if (!value.pickedUp)
                                PickupDetails(
                                  restaurant: restaurant,
                                )
                            ],
                          ),
                        ),
                ),
                if (!context.read<LiveTaskProvider>().showUploadImage &&
                    !value.isLoading)
                  Column(
                    children: [
                      CustomPaint(
                        size: Size(2, 100),
                        painter: DottedLinePainter(
                            dashHeight: 10, dashSpace: 8, color: Colors.black),
                      ),
                      Consumer<LiveTaskProvider>(
                        builder: (context, value, child) => value.isLoading
                            ? const SizedBox.shrink()
                            : Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: colorGray),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(
                                                  value.pickedUp ? 0 : 8),
                                              bottomRight: Radius.circular(
                                                  value.pickedUp ? 0 : 8))),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_pin,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            ' Deliver Food',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: large,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      ),
                                    ),
                                    if (value.pickedUp)
                                      DeliveryDetails(
                                        userPosition: userPosition,
                                        orderData: orderData,
                                        restaurant: restaurant,
                                        billingData: billingData,
                                        deliveryInstruction:
                                            value.deliveryInstruction,
                                      )
                                  ],
                                ),
                              ),
                      )
                    ],
                  ),
                SizedBox(
                  height: 20,
                ),
                if (context.read<LiveTaskProvider>().showUploadImage)
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        XFile? pickedFile = await ImagePicker().pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (pickedFile != null) {
                          Reference ref = FirebaseStorage.instance
                              .ref()
                              .child('pickup_images/${orderData.orderId}');
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => Dialog(
                                    // insetPadding: const EdgeInsets.all(20),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20.0),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(),
                                          Text('    Uploading...')
                                        ],
                                      ),
                                    ),
                                  ));
                          await ref.putFile(File(pickedFile.path));
                          Navigator.of(context).pop();
                          final result = await Navigator.of(context)
                              .push(transitionToNextScreen(PickupScreen(
                            remainingTime: value.remainingTime!,
                            orderData: orderData,
                            restaurant: restaurant,
                          )));
                          if (result is bool) {
                            context
                                .read<LiveTaskProvider>()
                                .toggleReachedPickedUp();
                            context
                                .read<LiveTaskProvider>()
                                .setPickedUp(result);
                          }
                        }
                      } catch (e) {}
                    },
                    style: ButtonStyle(
                        side: WidgetStatePropertyAll(BorderSide(
                            color: Color(0xff9c9ba6).withOpacity(.52))),
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))))),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/svgs/addImage.svg',
                            colorFilter: ColorFilter.mode(
                                Color(0xff9c9ba6), BlendMode.srcATop),
                          ),
                          Text(
                            ' upload image',
                            style: TextStyle(
                                color: Color(0xff9C9BA6),
                                fontSize: medium,
                                fontWeight: FontWeight.w300),
                          )
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeliveryDetails extends StatelessWidget {
  const DeliveryDetails({
    super.key,
    required this.orderData,
    required this.restaurant,
    required this.billingData,
    required this.userPosition,
    this.deliveryInstruction,
  });
  final OrderData orderData;
  final Restaurant restaurant;
  final Map billingData;
  final LatLng userPosition;
  final String? deliveryInstruction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                    text: orderData.orderByName!,
                    style: TextStyle(
                        fontSize: mediumSmall,
                        color: colorBrightGreen,
                        fontWeight: w600,
                        height: 2)),
                TextSpan(
                    text: '\n${orderData.deliveryAddress!}',
                    style: TextStyle(
                        fontSize: small, height: 1.5, color: Color(0xff505050)))
              ])),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Color(0xffffed47).withOpacity(.14),
                borderRadius: BorderRadius.all(Radius.circular(8)),
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
                      text: ' ${deliveryInstruction ?? "No Instructions"}.',
                      style: TextStyle(
                          fontSize: small,
                          color: Colors.black,
                          fontWeight: FontWeight.w300))
                ])),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
                onTap: () {
                  Toast.showToast(message: "Opening Maps...");
                  launchUrl(Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=${userPosition.latitude},${userPosition.longitude}&travelmode=two-wheeler'));
                },
                child: SvgPicture.asset('assets/svgs/gmaps.svg')),
            const SizedBox(
              width: 20,
            ),
            InkWell(
                onTap: () {
                  launchUrl(Uri.parse(
                      "tel:${context.read<LiveTaskProvider>().userPhonenumber}"));
                },
                child: SvgPicture.asset('assets/svgs/dial.svg')),
            const SizedBox(
              width: 20,
            ),
            Consumer<LiveTaskProvider>(
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    InkWell(
                        onTap: () => Navigator.of(context)
                                .push(transitionToNextScreen(ChatPage(
                              orderId: orderData.orderId,
                              orderById: orderData.orderByid,
                            ))),
                        child: SvgPicture.asset('assets/svgs/msg.svg')),
                    if (value.unreadByDriver > 0)
                      DecoratedBox(
                        decoration: BoxDecoration(
                            color: colorBrightGreen, shape: BoxShape.circle),
                        child: const SizedBox(height: 10, width: 10),
                      ),
                  ],
                );
              },
            )
          ],
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
            onPressed: () {
              context.read<LiveTaskProvider>().sendReachedNotification();
              Navigator.of(context).push(transitionToNextScreen(DeliveryScreen(
                billingData: billingData,
                orderData: orderData,
                restaurant: restaurant,
                deliveryInstruction: deliveryInstruction,
              )));
            },
            style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)))),
                minimumSize: WidgetStatePropertyAll(
                    Size(MediaQuery.of(context).size.width, 50)),
                backgroundColor: WidgetStatePropertyAll(colorBrightGreen)),
            child: Text(
              'Reached Delivery Location',
              style: TextStyle(
                  fontSize: medium, color: Colors.white, fontWeight: w600),
            ))
      ],
    );
  }
}

class PickupDetails extends StatelessWidget {
  const PickupDetails({super.key, required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 85 - 70,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.nukkadName!,
                      style: TextStyle(
                          color: colorGreen,
                          fontSize: mediumSmall,
                          fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 10,
                  ),
                  Text(restaurant.nukkadAddress!,
                      style:
                          TextStyle(fontSize: small, color: Color(0xff505050)))
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.hardEdge,
              child: restaurant.image == null
                  ? Image.asset(
                      'assets/dummy/areaimg.png',
                      height: 85,
                      width: 85,
                      fit: BoxFit.cover,
                    )
                  : Image.network(restaurant.image!,
                      height: 85, width: 85, fit: BoxFit.cover),
            )
          ]),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                      onTap: () {
                        Toast.showToast(message: "Opening Maps...");
                        launchUrl(Uri.parse(
                            'https://www.google.com/maps/dir/?api=1&destination=${restaurant.latitude!},${restaurant.longitude!}&travelmode=two-wheeler'));
                      },
                      child: SvgPicture.asset('assets/svgs/gmaps.svg')),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                      onTap: () {
                        launchUrl(Uri.parse("tel:${restaurant.phoneNumber!}"));
                      },
                      child: SvgPicture.asset('assets/svgs/dial.svg')),
                  const SizedBox(
                    width: 10,
                  ),
                  SvgPicture.asset('assets/svgs/msg.svg')
                ],
              ),
              // ElevatedButton(
              //     onPressed: () {},
              //     style: ButtonStyle(
              //         padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
              //         shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              //             borderRadius: BorderRadius.all(Radius.circular(8)))),
              //         backgroundColor: WidgetStatePropertyAll(colorGreen)),
              // child: Text(
              //   ' Ready for pickup ',
              //   style: TextStyle(
              //       color: Colors.white,
              //       fontSize: small,
              //       fontWeight: FontWeight.w600),
              //     ))
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: colorGreen),
                  child: Text(
                    ' Ready for pickup ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: small,
                        fontWeight: FontWeight.w600),
                  ))
            ],
          ),
        ),
        ElevatedButton(
            onPressed: () async {
              if (!context.read<LiveTaskProvider>().showUploadImage) {
                context.read<LiveTaskProvider>().toggleReachedPickedUp();
              }
            },
            style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)))),
                minimumSize: WidgetStatePropertyAll(
                    Size(MediaQuery.of(context).size.width, 50)),
                backgroundColor: WidgetStatePropertyAll(
                    context.read<LiveTaskProvider>().showUploadImage
                        ? colorGray
                        : colorBrightGreen)),
            child: Text(
              'Reached Pickup Location',
              style: TextStyle(
                  fontSize: medium, color: Colors.white, fontWeight: w600),
            ))
      ],
    );
  }
}
