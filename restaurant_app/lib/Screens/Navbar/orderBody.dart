import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/notification.dart';
import 'package:restaurant_app/Controller/order/order_controller.dart';
import 'package:restaurant_app/Controller/order/orders_model.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/customs/OrderBody/sortingBar.dart';
import 'package:sizer/sizer.dart';
import '../../Widgets/customs/OrderBody/orderFilters.dart';
import '../../Widgets/customs/OrderBody/orderStatusSelector.dart';
import '../../Widgets/customs/OrderBody/orderWidget.dart';
import 'package:restaurant_app/Controller/Profile/restaurant_model.dart';

typedef OrdersRefreshCallback = void Function();

class OrderBody extends StatefulWidget {
  const OrderBody({super.key});

  @override
  State<OrderBody> createState() => _OrderBodyState();
}

class _OrderBodyState extends State<OrderBody> {
  bool isOngoing = true;

  bool isLoading = false;

  // String? uid;

  // List<Map<String, dynamic>> myOrder = [];

  // List<Map<String, dynamic>> responseDataList = [];
  Map<String, List<Orders>>? groupedOrders;
  OrdersModel? ordersModel;
  List<Orders> myOrder = [];
  List<Orders> allOrder = [];
  List<Orders>? pendingOrCancelledOrders;
  List<Orders>? deliveredOrCancelledOrders;
  int selectedindex = 0;
  late RestaurantModel restaurant;

  @override
  void initState() {
    super.initState();
    fetchRestaurantModel();
    getAllOrders();
    NotificationService.orderRefresh = getAllOrders;
  }

  void fetchRestaurantModel() {
    String? restaurantJson =
        SharedPrefsUtil().getString(AppStrings.restaurantModel);
    if (restaurantJson != null && restaurantJson.isNotEmpty) {
      restaurant = RestaurantModel.fromJson(json.decode(restaurantJson));
    }
  }

  void getAllOrders() async {
    if (!mounted) {
      return; // Widget is not mounted, do nothing
    }
    setState(() {
      isLoading = true;
      groupedOrders = {};
      allOrder = [];
      pendingOrCancelledOrders = [];
      deliveredOrCancelledOrders = [];
    });
    selectedindex = 0;
    var result = await OrderController.getAllOrders(
      context: context,
      uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
    );
    result.fold((String message) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      // context.showSnackBar(message: message);
    }, (OrdersModel getAllOrders) {
      ordersModel = getAllOrders;
      // log(ordersModel!.orders![0].orderData!.restaurantuid.toString());
      if (ordersModel!.orders!.isNotEmpty) {
        ordersModel!.orders = ordersModel!.orders!.reversed.toList();
        groupedOrders = ordersModel!.groupOrdersByStatus();
        pendingOrCancelledOrders = ordersModel!
            .groupOrdersByStatus()
            .values
            .where((ordersList) => ordersList.any((order) =>
                order.orderData!.status == 'Pending' ||
                order.orderData!.status == 'Canceled' ||
                order.orderData!.status == 'Accepted' ||
                order.orderData!.status == 'On the way' ||
                order.orderData!.status == 'Preparing' ||
                order.orderData!.status == 'Ready'))
            .expand((ordersList) => ordersList)
            .toList();
        deliveredOrCancelledOrders = ordersModel!
            .groupOrdersByStatus()
            .values
            .where((ordersList) => ordersList.any((order) =>
                order.orderData!.status == 'Delivered' ||
                order.orderData!.status == 'delivered' ||
                order.orderData!.status == 'Declined' ||
                // order.orderData!.status == 'On the way' ||
                order.orderData!.status == 'Canceled'))
            .expand((ordersList) => ordersList)
            .toList();
        allOrder = ordersModel!
            .groupOrdersByStatus()
            .values
            .expand((order) => order)
            .toList();

        if (isOngoing == true) {
          myOrder = pendingOrCancelledOrders ?? [];
        } else {
          myOrder = deliveredOrCancelledOrders ?? [];
        }
      }
      isLoading = false;
    });
    if (mounted) {
      setState(() {});
    }
  }

  void _handelSelectedTab(int idx) {
    setState(() {
      selectedindex = idx;
    });
    if (isOngoing) {
      switch (idx) {
        case 0:
          setState(() {
            myOrder = pendingOrCancelledOrders ?? [];
            // myOrder = responseDataList
            //     .where((order) =>
            //         order['status'] == 'Pending' ||
            //         order['status'] == 'Canceled' ||
            //         order['status'] == 'Accepted' ||
            //         order['status'] == 'On the way' ||
            //         order['status'] == 'Ready')
            //     .toList();
          });
        case 1:
          setState(() {
            myOrder = groupedOrders!["Pending"] ?? [];
            // myOrder = responseDataList
            //     .where((order) => order['status'] == 'Pending')
            //     .toList();
          });
          break;
        case 2:
          setState(() {
            myOrder = groupedOrders!["Preparing"] ?? [];
            // myOrder = responseDataList
            //     .where((order) => order['status'] == 'Accepted')
            //     .toList();
          });
          break;
        case 3:
          setState(() {
            myOrder = groupedOrders!["Ready"] ?? [];
            // myOrder = responseDataList
            //     .where((order) => order['status'] == 'Ready')
            //     .toList();
          });
          break;
        case 4:
          setState(() {
            myOrder = groupedOrders!["On the way"] ?? [];
            // myOrder = responseDataList
            //     .where((order) => order['status'] == 'On the way')
            //     .toList();
          });
          break;
        default:
          setState(() {
            myOrder = pendingOrCancelledOrders ?? [];
            // myOrder = responseDataList
            //     .where((order) =>
            //         order['status'] == 'Pending' ||
            //         order['status'] == 'Canceled' ||
            //         order['status'] == 'Accepted' ||
            //         order['status'] == 'On the way' ||
            //         order['status'] == 'Ready')
            //     .toList();
          });
          break;
      }
    } else {
      List<Orders> responseDataListPrv = deliveredOrCancelledOrders ?? [];
      // List<Map<String, dynamic>> responseDataListPrv = responseDataList
      //     .where((order) =>
      //         order['status'] == 'Delivered' || order['status'] == 'Canceled')
      //     .toList();
      switch (idx) {
        case 0:
          setState(() {
            myOrder = deliveredOrCancelledOrders ?? [];
            // myOrder = responseDataListPrv
            //     .where((order) =>
            //         order['status'] == 'Delivered' ||
            //         order['status'] == 'Canceled')
            //     .toList();
          });
        case 1:
          DateTime now = DateTime.now();
          TimeOfDay currentTime = TimeOfDay.fromDateTime(now);

          setState(() {
            myOrder = responseDataListPrv.where((order) {
              DateTime orderDateTime = DateTime.parse(order.orderData!.date!);
              TimeOfDay orderTime = TimeOfDay.fromDateTime(orderDateTime);
              return orderTime.hour < currentTime.hour ||
                  (orderTime.hour == currentTime.hour &&
                      orderTime.minute <= currentTime.minute);
            }).toList();
            // myOrder = responseDataListPrv.where((order) {
            //   DateTime orderDateTime = DateTime.parse(order['date']);
            //   TimeOfDay orderTime = TimeOfDay.fromDateTime(orderDateTime);
            //   return orderTime.hour < currentTime.hour ||
            //       (orderTime.hour == currentTime.hour &&
            //           orderTime.minute <= currentTime.minute);
            // }).toList();
          });
          break;
        case 2:
          setState(() {
            myOrder = groupedOrders!["Canceled"] ?? [];
            // myOrder = responseDataList
            //     .where((order) => order['status'] == 'Canceled')
            //     .toList();
          });
          break;
        case 3:
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);

          setState(() {
            myOrder = responseDataListPrv.where((order) {
              DateTime orderDate = DateTime.parse(order.orderData!.date!);
              DateTime orderDateOnly =
                  DateTime(orderDate.year, orderDate.month, orderDate.day);
              return orderDateOnly.isAtSameMomentAs(today);
            }).toList();
            // myOrder = responseDataListPrv.where((order) {
            //   DateTime orderDate = DateTime.parse(order['date']);
            //   DateTime orderDateOnly =
            //       DateTime(orderDate.year, orderDate.month, orderDate.day);
            //   return orderDateOnly.isAtSameMomentAs(today);
            // }).toList();
          });
          break;
        case 4:
          setState(() {
            DateTime now = DateTime.now();
            DateTime today = DateTime(now.year, now.month, now.day);

            setState(() {
              myOrder = responseDataListPrv.where((order) {
                DateTime orderDate = DateTime.parse(order.orderData!.date!);
                DateTime orderDateOnly =
                    DateTime(orderDate.year, orderDate.month, orderDate.day);
                return orderDateOnly.isBefore(today);
              }).toList();
            });
            // myOrder = responseDataListPrv.where((order) {
            //     DateTime orderDate = DateTime.parse(order['date']);
            //     DateTime orderDateOnly =
            //         DateTime(orderDate.year, orderDate.month, orderDate.day);
            //     return orderDateOnly.isBefore(today);
            //   }).toList();
            // });
          });
          break;
        default:
          setState(() {
            myOrder = deliveredOrCancelledOrders ?? [];
            // myOrder = responseDataListPrv
            //     .where((order) =>
            //         order['status'] == 'Delivered' ||
            //         order['status'] == 'Canceled')
            //     .toList();
          });
          break;
      }
    }
  }

  void _handelOrderFilter(String text) {
    switch (text) {
      case 'Newest First':
        setState(() {
          myOrder.sort((b, a) => DateTime.parse(a.orderData!.date!)
              .compareTo(DateTime.parse(b.orderData!.date!)));
        });
      case 'Oldest First':
        setState(() {
          myOrder.sort((a, b) => DateTime.parse(a.orderData!.date!)
              .compareTo(DateTime.parse(b.orderData!.date!)));
        });
        break;
      case 'Order Cost : Low to High':
        setState(() {
          myOrder.sort((a, b) => a.orderData!.billingDetail!['nukkad_earning']
              .compareTo(b.orderData!.billingDetail!['nukkad_earning']));
        });
      case 'Order Cost : High to Low':
        setState(() {
          myOrder.sort((b, a) => a.orderData!.billingDetail!['nukkad_earning']
              .compareTo(b.orderData!.billingDetail!['nukkad_earning']));
        });

      default:
        setState(() {
          if (isOngoing) {
            myOrder = pendingOrCancelledOrders ?? [];
          } else {
            myOrder = deliveredOrCancelledOrders ?? [];
          }
        });
        break;
    }
  }

  void _handleOrderTypeChanged(bool newValue) {
    setState(() {
      isOngoing = newValue;
      if (isOngoing == true) {
        myOrder = pendingOrCancelledOrders ?? [];
        // myOrder = responseDataList
        //     .where((order) =>
        //         order['status'] == 'Pending' ||
        //         order['status'] == 'Canceled' ||
        //         order['status'] == 'Accepted' ||
        //         order['status'] == 'On the way' ||
        //         order['status'] == 'Ready')
        //     .toList();
      } else {
        myOrder = deliveredOrCancelledOrders ?? [];
        // myOrder = responseDataList
        //     .where((order) =>
        //         order['status'] == 'Delivered' || order['status'] == 'Canceled')
        //     .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Image.asset(
        'assets/images/otpbg.png',
        fit: BoxFit.cover,
      ),
      SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              child: OrderStatusSelector(
                onOrderStatusChanged: _handleOrderTypeChanged,
              ),
            ),
            Flexible(
              child: RefreshIndicator(
                onRefresh: () async {
                  getAllOrders();
                },
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: SortingBar(
                          type: isOngoing,
                          onOrderFilterChanged: _handelOrderFilter),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      child: OrderFilter(
                        type: isOngoing,
                        selected: _handelSelectedTab,
                        selectedindex: selectedindex,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                ),
                              )
                            : myOrder.isEmpty
                                ? Center(
                                    child: Text(AppStrings.noOrdersFound),
                                  )
                                : ListView.builder(
                                    itemCount: myOrder.length,
                                    itemBuilder: (context, index) {
                                      return OrderWidget(
                                        type: isOngoing,
                                        nukkad: restaurant.user!,
                                        order: myOrder[index],
                                        onOrdersRefresh: getAllOrders,
                                      );
                                    }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ]));
  }
}
