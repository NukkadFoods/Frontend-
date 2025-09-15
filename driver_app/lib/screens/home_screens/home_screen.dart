import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/ads_slider.dart';
import 'package:driver_app/controller/orders/order_controller.dart';
import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/widgets/common/loading_popup.dart';
import 'package:driver_app/widgets/common/menu.dart';
import 'package:driver_app/widgets/home/order_found.dart';
import 'package:driver_app/widgets/home/searching.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSearching = false;
  bool showContainer = false;
  bool streamInitialized = false;
  late Map deliveryBoyData;
  List<OrderData> unassignedOrders = [];
  List<String> declinedUnassignedOrders = [];

  @override
  void initState() {
    super.initState();
    getDeliveryBoyData();
  }

  Future<void> enableStream() async {
    await OrderController.getStream();
    streamInitialized = true;
    if (mounted) {
      setState(() {});
    }
  }

  void getUnassignedOrders() async {
    unassignedOrders.clear();
    final db = FirebaseFirestore.instance;
    for (var hub in DutyController.myHubs) {
      final Map rawOrderData =
          ((await db.collection('hubs').doc(hub['hubId']).get())
                  .data()!['unassigned'] ??
              {});
      for (var order in rawOrderData.entries) {
        final orderData = OrderData.fromJson(order.value);
        orderData.hubId = hub['hubId'];
        unassignedOrders.add(orderData);
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  void getDeliveryBoyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? temp = prefs.getString('deliveryBoyData');
    if (temp != null) {
      deliveryBoyData = jsonDecode(temp);
      await enableStream();
      DutyController.init(deliveryBoyData, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 200, // Set the width of the button
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DutyController.isOnDuty
                        ? Colors.grey
                        : colorBrightGreen,
                  ),
                  onPressed: () async {
                    if (DutyController.myHubs.isEmpty) {
                      DutyController.getHub(context);
                      return;
                    }
                    showLoadingPopup(context, "Starting Duty");
                    DutyController.isOnDuty = !DutyController.isOnDuty;
                    isSearching =
                        DutyController.isOnDuty; // Toggle the duty status
                    if (DutyController.isOnDuty) {
                      if (streamInitialized) {
                        getUnassignedOrders();
                        await DutyController.startDuty(context);
                      }
                    } else {
                      DutyController.endDuty();
                    }
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    DutyController.isOnDuty ? 'END DUTY' : 'START DUTY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              // DutyController.isOnDuty ? Image.asset('assets/images/sos.png') : SizedBox(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showContainer = !showContainer;
                  });
                },
                child: Icon(
                  showContainer ? Icons.close : Icons.menu,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            ],
          ),
          if (showContainer) Menu(),
          SizedBox(height: 20), // Adjust as needed for other content spacing
          if (DutyController.isOnDuty)
            if (streamInitialized)
              StreamBuilder(
                stream: OrderController.orderStream,
                builder: (context, snapshot) {
                  OrderController.setStatus();
                  List<OrderData> orders = [];
                  if (snapshot.hasData) {
                    for (MapEntry item
                        in snapshot.data!.data()!['orders'].entries) {
                      if (item.value['accepted'] == null) {
                        orders.add(OrderData.fromJson(item.value));
                      } else if (item.value['accepted'] == true) {
                        Toast.showToast(
                            message:
                                "You already have an active order. Please check ongoing orders.");
                      }
                    }
                  }
                  if (orders.isEmpty && unassignedOrders.isEmpty) {
                    return Expanded(child: Center(child: Searching()));
                  } else {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * .7),
                      child: ListView.builder(
                        itemCount: orders.length + unassignedOrders.length,
                        itemBuilder: (context, index) => index <
                                unassignedOrders.length
                            ? declinedUnassignedOrders
                                    .contains(unassignedOrders[index].orderId)
                                ? const SizedBox.shrink()
                                : OrderFound(
                                    orderData: unassignedOrders[index],
                                    unassigned: true,
                                    onDeclineUnassigned: () {
                                      declinedUnassignedOrders.add(
                                          unassignedOrders[index].orderId!);
                                      unassignedOrders.removeAt(index);
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    onAcceptedUnassigned: () {
                                      unassignedOrders.removeAt(index);
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                  )
                            : OrderFound(
                                orderData:
                                    orders[index - unassignedOrders.length],
                              ),
                      ),
                    );
                  }
                },
              )
            else
              CircularProgressIndicator(),

          if (!showContainer &&
              !DutyController.isOnDuty) // Placeholder to maintain layout
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AdsSlider(),
                  SizedBox(height: 20),
                  Text(
                    'No orders! Start duty to\nget new orders',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  // FullWidthGreenButton(
                  //   label: 'START DUTY',
                  //   onPressed: () async {
                  //     DutyController.isOnDuty = !DutyController.isOnDuty;
                  //     isSearching =
                  //         DutyController.isOnDuty; // Toggle the duty status
                  //     if (DutyController.isOnDuty) {
                  //       if (streamInitialized &&
                  //           (await OrderController.streamRef.get())
                  //               .get('orders')
                  //               .isEmpty) {
                  //         Toast.showToast(message: "Starting Duty...");
                  //         await DutyController.startDuty(context);
                  //       }
                  //     } else {
                  //       DutyController.endDuty();
                  //     }
                  //     setState(() {});
                  //   },
                  // ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
