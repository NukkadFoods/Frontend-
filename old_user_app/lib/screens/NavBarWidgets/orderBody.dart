import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/food/food_controller.dart';
import 'package:user_app/Controller/order/order_controller.dart';
import 'package:user_app/Controller/order/orders_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/screens/Support/helpSupportScreen.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/Orders/orderStatusSelector.dart';
import 'package:user_app/widgets/customs/Orders/placedOrderDetails.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:user_app/widgets/customs/request_login.dart';

class OrdersBody extends StatefulWidget {
  const OrdersBody({super.key});

  @override
  State<OrdersBody> createState() => _OrdersBodyState();
}

class _OrdersBodyState extends State<OrdersBody> {
  bool _isOngoing = true;
  bool isLoading = true;
  OrdersModel? ordersModel;
  List<Orders> pendingOrCancelledOrders = [];
  List<Orders>? deliveredOrCancelledOrders;
  bool isAllRestaurantsLoaded = false;
  FetchAllRestaurantsModel? fetchAllRestaurantsModel;
  Timer? _timer; // Timer to manage the refresh
  Map<String, String>?
      status; //this map records the status of each order which is compared with new status and do setstate
  // Counter to track the number of refreshes
  @override
  void initState() {
    super.initState();
    getOrders();
    _startTimer();
    // getStreakCount();
  }

  void _startTimer() {
    if (SharedPrefsUtil().getString(AppStrings.userId) == null) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      getOrders(); // Call the method to execute your functions
    });
  }

  Future getOrders() async {
    if (!mounted || SharedPrefsUtil().getString(AppStrings.userId) == null) {
      return; // Widget is not mounted, do nothing
    }
    int? deliveredLength;
    if (mounted) {
      deliveredLength = (deliveredOrCancelledOrders ?? []).length;
    }
    Map<String, String> temp = {};
    // setState(() {
    // isLoading = true;
    pendingOrCancelledOrders = [];
    deliveredOrCancelledOrders = [];
    // });
    var result = await OrderController.getAllOrders(
      context: context,
      uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
    );
    result.fold((String message) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        // Fluttertoast.showToast(
        //     msg: ' $message',
        //     backgroundColor: textWhite,
        //     textColor: textBlack,
        //     gravity: ToastGravity.CENTER);
        print(message);
      }
    }, (OrdersModel getAllOrders) {
      ordersModel = getAllOrders;
      if (ordersModel!.orders!.isNotEmpty) {
        pendingOrCancelledOrders = ordersModel!
            .groupOrdersByStatus()
            .values
            .where((ordersList) => ordersList.any((order) =>
                order.status!.toLowerCase() == 'pending' ||
                order.status!.toLowerCase() == 'preparing' ||
                order.status!.toLowerCase() == 'accepted' ||
                order.status!.toLowerCase() == 'on the way' ||
                order.status!.toLowerCase() == 'ready'))
            .expand((ordersList) => ordersList)
            .toList();
        pendingOrCancelledOrders = pendingOrCancelledOrders.reversed.toList();
        pendingOrCancelledOrders.forEach((order) {
          temp[order.id!] = order.status!;
        });
        deliveredOrCancelledOrders = ordersModel!
            .groupOrdersByStatus()
            .values
            .where((ordersList) => ordersList.any((order) =>
                order.status!.toLowerCase() == 'delivered' ||
                order.status!.toLowerCase() == 'canceled'))
            .expand((ordersList) => ordersList)
            .toList();
      }
      if (mounted && (deliveredLength != deliveredOrCancelledOrders!.length)) {
        getStreakCount();
      }
      isLoading = false;
      if (status == null) {
        status = temp;
        setState(() {});
        context
            .read<GlobalProvider>()
            .addOngoingOrder(List.from(pendingOrCancelledOrders));
        return;
      }
      if (mounted) {
        if (temp.length != status!.length) {
          status = temp;
          setState(() {});
          context
              .read<GlobalProvider>()
              .addOngoingOrder(List.from(pendingOrCancelledOrders));
        } else {
          doSetState(temp);
        }
      }
    });
  }

  Future fetchAllRestaurants() async {
    setState(() {
      isAllRestaurantsLoaded = false;
    });
    var result = await FoodController.fetchAllRestaurants(context: context);
    result.fold((String text) {
      setState(() {
        isAllRestaurantsLoaded = true;
        Fluttertoast.showToast(
            msg: text, backgroundColor: textWhite, textColor: textBlack);
      });
    }, (FetchAllRestaurantsModel allRestaurantsModel) {
      fetchAllRestaurantsModel = allRestaurantsModel;
      isAllRestaurantsLoaded = true;
      print("allRestaurantsModel: $fetchAllRestaurantsModel");
    });
    if (mounted) {
      setState(() {});
    }
  }

  void doSetState(Map<String, String> map) {
    if (map.isEmpty &&
        context.read<GlobalProvider>().ongoingOrders.isNotEmpty) {
      setState(() {});
      context
          .read<GlobalProvider>()
          .addOngoingOrder(List.from(pendingOrCancelledOrders));
      return;
    }
    map.forEach((key, value) {
      if (status!.containsKey(key)) {
        if (status![key] != map[key]) {
          status = map;
          setState(() {});
          context
              .read<GlobalProvider>()
              .addOngoingOrder(List.from(pendingOrCancelledOrders));
        }
      } else {
        status = map;
        setState(() {});
        context
            .read<GlobalProvider>()
            .addOngoingOrder(List.from(pendingOrCancelledOrders));
      }
    });
  }

  void _handleOrderTypeChanged(bool isOngoing) {
    setState(() {
      _isOngoing = isOngoing;
    });
  }

  void getStreakCount() async {
    if (deliveredOrCancelledOrders == null ||
        deliveredOrCancelledOrders!.isEmpty) {
      return;
    }
    try {
      int streak = 0;
      String? lastStreakCreditedOn = (await FirebaseFirestore.instance
              .collection('constants')
              .doc('streakRecord')
              .get())
          .data()![SharedPrefsUtil().getString(AppStrings.userId)];
      final todayDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime currentDay = DateTime.parse(
          deliveredOrCancelledOrders!.last.date!.substring(0, 10));
      DateTime previousDay = currentDay.subtract(const Duration(days: 1));
      if (todayDate.difference(currentDay).inDays > 1) {
        streak = 0;
        context.read<GlobalProvider>().updateStreak(streak);
        return;
      } else {
        streak = 1;
      }
      context.read<GlobalProvider>().orderedToday =
          currentDay.isAtSameMomentAs(todayDate);
      for (final order in deliveredOrCancelledOrders!
          .where((order) => order.status == 'Delivered')
          .toList()
          .reversed) {
        final dateString = order.date!.substring(0, 10);
        final date = DateTime.parse(dateString);
        if (lastStreakCreditedOn == dateString) {
          break;
        }
        if (date.isAtSameMomentAs(currentDay)) {
          continue;
        } else if (date.isAtSameMomentAs(previousDay)) {
          streak += 1;
          currentDay = previousDay;
          previousDay = currentDay.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
      context.read<GlobalProvider>().updateStreak(streak);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Stack(children: [
      Opacity(
          opacity: 0.5,
          child: Image.asset(
            'assets/images/background.png',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          )),
      SharedPrefsUtil().getString(AppStrings.userId) == null
          ? loginRequest(context)
          : Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Orders',
                      style: h3TextStyle.copyWith(
                          color: isdarkmode ? textGrey2 : textBlack),
                    ),
                  ),
                  OrderStatusSelector(
                      onOrderStatusChanged: _handleOrderTypeChanged),
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.red,
                                  ),
                                )
                              : _isOngoing
                                  ? pendingOrCancelledOrders.isEmpty
                                      ? const Center(
                                          child: Text(AppStrings.noOrdersFound))
                                      : _buildOrderList(
                                          context: context,
                                          orderList: pendingOrCancelledOrders,
                                          isOngoing: _isOngoing)
                                  : deliveredOrCancelledOrders!.isEmpty
                                      ? const Center(
                                          child: Text(AppStrings.noOrdersFound))
                                      : Builder(builder: (context) {
                                          final orders = List.from(
                                              deliveredOrCancelledOrders!
                                                  .reversed);
                                          return ListView.builder(
                                            itemCount: orders.length,
                                            itemBuilder: (context, index) {
                                              return PlacedOrderDetails(
                                                isOngoing: _isOngoing,
                                                context: context,
                                                order: orders[index],
                                              );
                                            },
                                          );
                                        }),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: SizedBox(
                            height: 6.h,
                            width: 100.w,
                            child: Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    transitionToNextScreen(
                                      const HelpSupportScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Need help with the orders?',
                                  style: body4TextStyle.copyWith(
                                      color: primaryColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    ]);
  }

  Widget _buildOrderList({
    required List<Orders?> orderList,
    required bool isOngoing,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: orderList.length,
            itemBuilder: (context, index) {
              return PlacedOrderDetails(
                isOngoing: isOngoing,
                context: context,
                order: orderList[index]!,
              );
            },
          ),
        ),
        SizedBox(
          height: 5.h,
        )
      ],
    );
  }
}
