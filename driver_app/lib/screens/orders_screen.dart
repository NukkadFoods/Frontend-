import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/earnings/earnings_controller.dart';
import 'package:driver_app/controller/orders/order_controller.dart';
import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:driver_app/widgets/home/order_found.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int selectedIndex = 0;
  List earnings = [];
  bool isEarningsLoading = false;
  Map bufferedOrders = {};
  Map bufferedRestaurants = {};

  @override
  void initState() {
    super.initState();
    getEarnings();
  }

  void getEarnings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString('uid')!;
    try {
      final Map response = await EarningsController.getEarnings(uid: userid);
      if (response.containsKey("earnings")) {
        earnings = response['earnings']['earnings'].reversed.toList();
      } else {
        Toast.showToast(message: "Something went wrong", isError: true);
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: "No Internet", isError: true);
      }
      print(e);
    }
    isEarningsLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedIndex == 0 ? colorBrightGreen : Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1,
                              color: selectedIndex == 0
                                  ? colorBrightGreen
                                  : colorGreen),
                          borderRadius: BorderRadius.circular(15))),
                  child: Row(
                    children: [
                      Icon(Icons.timelapse_outlined,
                          color:
                              selectedIndex == 0 ? Colors.white : colorGreen),
                      const SizedBox(width: 10),
                      Text("Ongoing",
                          style: TextStyle(
                              fontSize: 20,
                              color: selectedIndex == 0
                                  ? Colors.white
                                  : colorBrightGreen)),
                    ],
                  )),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedIndex == 1 ? colorBrightGreen : Colors.white,
                      side: BorderSide(
                          width: 1,
                          color: selectedIndex == 1
                              ? colorBrightGreen
                              : colorGreen),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history_outlined,
                        color: selectedIndex == 1 ? Colors.white : colorGreen,
                      ),
                      const SizedBox(width: 10),
                      Text("Previous",
                          style: TextStyle(
                              fontSize: 20,
                              color: selectedIndex == 1
                                  ? Colors.white
                                  : colorGreen)),
                    ],
                  ))
            ],
          ),
          if ((isEarningsLoading && selectedIndex == 1))
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: selectedIndex == 0
                    ? OngoingOrders()
                    : earnings.isEmpty
                        ? Center(
                            child: Text("No previous orders found",
                                textAlign: TextAlign.center),
                          )
                        : ListView.builder(
                            itemCount: earnings.length,
                            itemBuilder: (context, index) => CompletedOrder(
                                bufferedOrders: bufferedOrders,
                                bufferedRestaurants: bufferedRestaurants,
                                userid: earnings[index]['userId'],
                                orderId: earnings[index]['orderId']),
                          ),
              ),
            )
        ],
      ),
    );
  }
}

class OngoingOrders extends StatelessWidget {
  const OngoingOrders({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: OrderController.orderStream,
      builder: (context, snapshot) {
        OrderController.setStatus();
        List<OrderData> orders = [];
        if (snapshot.hasData) {
          for (MapEntry item in snapshot.data!.data()!['orders'].entries) {
            if (item.value['accepted'] == true) {
              orders.add(OrderData.fromJson(item.value));
            }
          }
        }
        if (orders.isEmpty) {
          return Center(
            child: Text("No Ongoing Orders Found!"),
          );
        } else {
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) => OrderFound(
              orderData: orders[index],
            ),
          );
        }
      },
    );
  }
}

class CompletedOrder extends StatefulWidget {
  const CompletedOrder(
      {super.key,
      required this.userid,
      required this.orderId,
      required this.bufferedOrders,
      required this.bufferedRestaurants});
  final String userid;
  final String orderId;
  final Map bufferedOrders;
  final Map bufferedRestaurants;

  @override
  State<CompletedOrder> createState() => _CompletedOrderState();
}

class _CompletedOrderState extends State<CompletedOrder> {
  bool isLoading = true;
  late OrderData orderData;
  late Restaurant restaurant;
  String distance = '';
  bool error = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      if (widget.bufferedOrders.containsKey(widget.orderId)) {
        orderData = OrderData.fromJson(widget.bufferedOrders[widget.orderId]);
      } else {
        final response = await http.get(Uri.parse(
            "${AppStrings.baseURL}/order/orders/${widget.userid}/${widget.orderId}"));
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body)['order'];
          orderData = OrderData.fromJson(json);
          widget.bufferedOrders[orderData.orderId] = json;
        }
      }

      if (widget.bufferedRestaurants.containsKey(orderData.restaurantuid)) {
        restaurant = Restaurant.fromJson(
            widget.bufferedRestaurants[orderData.restaurantuid]);
      } else {
        final response2 = await http.post(Uri.parse(
            '${AppStrings.baseURL}/auth/getRestaurantUser/${orderData.restaurantuid}'));
        final jsonResponse = jsonDecode(response2.body);
        if (response2.statusCode == 200 && jsonResponse['executed']) {
          final json = jsonResponse['user'];
          restaurant = Restaurant.fromJson(json);
          widget.bufferedRestaurants[orderData.restaurantuid] = json;
        }
      }

      final userData = (await FirebaseFirestore.instance
              .collection('tracking')
              .doc(orderData.orderId)
              .get())
          .data()!;
      distance =
          "${(Geolocator.distanceBetween(userData['userLat'], userData['userLng'], restaurant.latitude!, restaurant.longitude!) / 1000).toStringAsFixed(2)} Km";
    } on http.ClientException {
      error = true;
      Toast.showToast(message: "Unstable Internet.", isError: true);
    } catch (e) {
      error = true;
      if (kDebugMode) {
        print(e);
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return error
        ? SizedBox.shrink()
        : Container(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ID: ${orderData.orderId ?? ""}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: colorBrightGreen,
                                    fontSize: mediumSmall,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text(
                                "${DateFormat("dd-MM-yy").format(DateTime.parse(orderData.date!))}, ${orderData.time}${orderData.billingDetail!['pickDistance'] != null ? "\nPickup: ${orderData.billingDetail!['pickDistance'].toStringAsFixed(2)} km" : ''}\t\t\t\t|\t\t\t\tDrop: $distance",
                                style: TextStyle(
                                    fontSize: small, color: Colors.grey),
                              )
                            ],
                          )),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    orderData.billingDetail!['lateDelivery'] ==
                                            true
                                        ? Colors.red
                                        : colorGreen),
                            child: Text(
                                orderData.billingDetail!['lateDelivery'] == true
                                    ? "Late"
                                    : "On Time",
                                style: TextStyle(color: Colors.white)),
                          )
                        ]),
                    Divider(thickness: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Earning recieved :"),
                          Text(orderData.billingDetail!['delivery_boy_earning']
                              .toString())
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Wallet Cash recieved :"),
                          Text((orderData.billingDetail!['lateDelivery'] == true
                                  ? 0.0
                                  : orderData.billingDetail![
                                      'delivery_boy_wallet_cash'])
                              .toString())
                        ],
                      ),
                    ),
                    Divider(indent: 8, endIndent: 8, height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total :"),
                          Text((orderData
                                      .billingDetail!['delivery_boy_earning'] +
                                  (orderData.billingDetail!['lateDelivery'] ==
                                          true
                                      ? 0.0
                                      : orderData.billingDetail![
                                          'delivery_boy_wallet_cash']))
                              .toStringAsFixed(2))
                        ],
                      ),
                    ),
                  ]),
          );
  }
}
