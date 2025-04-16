import 'package:driver_app/controller/earnings/earnings_controller.dart';
import 'package:driver_app/controller/orders/order_controller.dart';
import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/providers/order_found_provider.dart';
import 'package:driver_app/screens/live_task_screens/live_task_screen.dart';
import 'package:driver_app/screens/map/map.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:driver_app/widgets/constants/shared_preferences.dart';
import 'package:driver_app/widgets/home/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../utils/font-styles.dart';

class OrderFound extends StatelessWidget {
  const OrderFound({
    super.key,
    this.onMap = false,
    this.unassigned = false,
    required this.orderData,
    this.onDeclineUnassigned,
    this.onAcceptedUnassigned,
  });
  final bool onMap;
  final bool unassigned;
  final VoidCallback? onDeclineUnassigned;
  final VoidCallback? onAcceptedUnassigned;
  final OrderData orderData;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrderFoundProvider(orderData: orderData),
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Colors.grey[300]!,
          ),
          borderRadius: onMap
              ? BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8))
              : BorderRadius.circular(8),
        ),
        width: double.infinity,
        child: Consumer<OrderFoundProvider>(
          builder: (context, value, child) => !value.restaurantFetched
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()])
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(transitionToNextScreen(MapWithOrderScreen(
                            billingData: value.billingData!,
                            restaurant: value.restaurantDetails!,
                            orderData: orderData,
                            userPosition: value.userPosition!,
                            unassigned: unassigned,
                            onDeclineUnassigned: onDeclineUnassigned,
                            onAcceptedUnassigned: onAcceptedUnassigned,
                          )));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Earning',
                                  style: TextStyle(
                                    fontSize: small,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '₹${value.billingData!['total_delivery_boy_earning']}',
                                  style: TextStyle(
                                    color: colorBrightGreen,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // SizedBox(
                                //   height: 10,
                                // ),
                                // Row(
                                //   children: [
                                //     Icon(
                                //       Icons.storefront,
                                //       color: colorBrightGreen,
                                //       size: medium,
                                //     ),
                                //     Text(
                                //       ' ${value.pickDistance.toStringAsFixed(1)} KM',
                                //       style: TextStyle(
                                //         fontSize: small,
                                //       ),
                                //     )
                                //   ],
                                // ),
                                // SizedBox(
                                //   height: 10,
                                // ),
                                // Row(
                                //   children: [
                                //     const SizedBox(width: 4),
                                //     Image.asset(
                                //       'assets/images/greenlocationicon.png',
                                //     ),
                                //     Text(
                                //       '  ${value.dropDistance.toStringAsFixed(1)} KM',
                                //       style: TextStyle(
                                //         fontSize: small,
                                //       ),
                                //     )
                                //   ],
                                // ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(width: 4),
                                    Image.asset('assets/images/timer.png'),
                                    Text(
                                      //assuming that rider will cover 1 km in 2 minutes ie 30 kmph
                                      '  ${((value.dropDistance + value.pickDistance) * 2).round()} Mins',
                                      style: TextStyle(
                                        fontSize: small,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.storefront,
                                      color: colorBrightGreen,
                                      size: 30,
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .4),
                                          child: Text(
                                            value
                                                .restaurantDetails!.nukkadName!,
                                            style: TextStyle(
                                              color: colorBrightGreen,
                                              fontSize: mediumSmall,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .4),
                                          child: Text(
                                            value.restaurantDetails!
                                                .nukkadAddress!,
                                            maxLines: 3,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: small,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Stack(
                                  children: [
                                    Positioned(
                                      left:
                                          15, // Adjust based on icon alignment
                                      top: 0, // Adjust based on icon size
                                      bottom: 40,
                                      child: CustomPaint(
                                        size: Size(1,
                                            70), // Adjust height based on requirement
                                        painter: DottedLinePainter(),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                            height:
                                                40), // Adjust based on icon size
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.home,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                            SizedBox(width: 10),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .4),
                                              child: Text(
                                                orderData.deliveryAddress!,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: mediumSmall,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      indent: 8,
                      endIndent: 8,
                      height: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.storefront_outlined,
                                  color: colorBrightGreen),
                              Text(
                                  "  Pickup : ${value.pickDistance.toStringAsFixed(1)} KM",
                                  style: TextStyle(fontSize: small)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/greenlocationicon.png',
                              ),
                              Text(
                                  "  Drop : ${value.dropDistance.toStringAsFixed(1)} KM",
                                  style: TextStyle(fontSize: small)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      indent: 8,
                      endIndent: 8,
                      height: 2,
                    ),
                    if (!onMap)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16, bottom: 16, top: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Base Earning: ",
                                  style: TextStyle(fontSize: small),
                                ),
                                Text(
                                  orderData
                                      .billingDetail!['delivery_boy_earning']
                                      .toString(),
                                  style: TextStyle(fontSize: small),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Wallet Earning (Before ${DateFormat('h:mm a').format(DateTime.parse(orderData.timetoprepare!))}): ",
                                    style: TextStyle(fontSize: small)),
                                Text(
                                    orderData.billingDetail![
                                            'delivery_boy_wallet_cash']
                                        .toString(),
                                    style: TextStyle(fontSize: small)),
                              ],
                            ),
                            Divider(
                              indent: 8,
                              endIndent: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID: ${orderData.orderId!.substring(6)}',
                                      style: TextStyle(
                                          fontSize: mediumSmall,
                                          color: colorBrightGreen,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      '${orderData.date!.split('T')[0]}, ${orderData.time}',
                                      style: TextStyle(
                                        fontSize: small,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: colorBrightGreen,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Text(
                                          'New',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        )),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                        'To ${orderData.orderByName!.split(' ')[0]}')
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (!(onMap || orderData.accepted == true))
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                final result = await showDeclineWarning(
                                    context,
                                    ((orderData.billingDetail![
                                                    'delivery_boy_earning']
                                                .toDouble() as double) *
                                            .15)
                                        .clamp(0, 20)
                                        .toDouble()
                                        .roundOff());
                                if (result != true) {
                                  return;
                                }
                                if (unassigned && onDeclineUnassigned != null) {
                                  onDeclineUnassigned!();
                                } else {
                                  OrderController.declineOrder(orderData);
                                }
                                await EarningsController.addEarning(
                                    uid: SharedPrefsUtil().getString('uid')!,
                                    orderId: orderData.orderId!,
                                    userId: orderData.orderByid!,
                                    amount: -((orderData.billingDetail![
                                                    'delivery_boy_earning']
                                                .toDouble() as double) *
                                            .15)
                                        .clamp(0, 20)
                                        .toDouble()
                                        .roundOff());
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Colors.black),
                                  minimumSize: WidgetStatePropertyAll(Size(
                                      onMap
                                          ? MediaQuery.of(context).size.width /
                                                  2 -
                                              2
                                          : MediaQuery.of(context).size.width /
                                                  2 -
                                              18,
                                      50)),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft:
                                                  Radius.circular(8))))),
                              child: Text(
                                'Decline',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                          ElevatedButton(
                              onPressed: () async {
                                orderData.billingDetail!['pickDistance'] =
                                    value.pickDistance;
                                if (unassigned) {
                                  final result = await OrderController
                                      .acceptUnassignedOrder(orderData);
                                  if (!result) {
                                    showUnavailableDialog(context);
                                    onAcceptedUnassigned!();
                                    return;
                                  }
                                  onAcceptedUnassigned!();
                                } else {
                                  OrderController.acceptOrder(orderData);
                                }
                                Navigator.of(context)
                                    .push(transitionToNextScreen(LiveTaskScreen(
                                  userPosition: value.userPosition!,
                                  billingData: value.billingData!,
                                  orderData: orderData,
                                  restaurant: value.restaurantDetails!,
                                )));
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(colorBrightGreen),
                                  minimumSize: WidgetStatePropertyAll(Size(
                                      onMap
                                          ? MediaQuery.of(context).size.width /
                                                  2 -
                                              2
                                          : MediaQuery.of(context).size.width /
                                                  2 -
                                              18,
                                      50)),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomRight:
                                                  Radius.circular(8))))),
                              child: Text(
                                'Accept',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ],
                      ),
                    if (orderData.accepted == true)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  OrderController.location
                                      .updateOrderId(orderData.orderId!);
                                  OrderController.location.initialize();
                                  Navigator.of(context).push(
                                      transitionToNextScreen(LiveTaskScreen(
                                    userPosition: value.userPosition!,
                                    billingData: value.billingData!,
                                    orderData: orderData,
                                    restaurant: value.restaurantDetails!,
                                  )));
                                },
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size.fromHeight(50),
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8)))),
                                child: Text(
                                  'Complete Order',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  void showUnavailableDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                    "Sorry, the following order was accepted by other delivery person."),
              ),
            ));
  }

  Future showDeclineWarning(BuildContext context, double amount) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "\nDeclining the order will result a penalty of ",
                style: TextStyle(color: Colors.black, fontSize: mediumSmall),
                children: [
                  TextSpan(
                      text: '₹ $amount ',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const TextSpan(text: 'on you.\nDo you want to proceed?'),
                ])),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(colorGreen)),
              child: const Text("Yes", style: TextStyle(color: Colors.white))),
          const SizedBox(width: 10),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"))
        ],
      ),
    );
  }
}
