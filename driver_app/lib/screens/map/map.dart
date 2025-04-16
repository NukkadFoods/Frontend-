import 'package:driver_app/controller/orders/order_controller.dart';
import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/providers/map_provider.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:driver_app/widgets/home/order_found.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../widgets/common/transition_to_next_screen.dart';
import '../live_task_screens/live_task_screen.dart';

class MapWithOrderScreen extends StatelessWidget {
  const MapWithOrderScreen(
      {super.key,
      required this.orderData,
      required this.restaurant,
      required this.userPosition,
      required this.billingData,
      required this.unassigned,
      this.onDeclineUnassigned,
      this.onAcceptedUnassigned});
  final OrderData orderData;
  final Restaurant restaurant;
  final LatLng userPosition;
  final Map billingData;
  final bool unassigned;
  final VoidCallback? onDeclineUnassigned;
  final VoidCallback? onAcceptedUnassigned;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MapProvider(
          orderData: orderData,
          restaurant: restaurant,
          userPosition: userPosition),
      builder: (context, child) => Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(
            'Order id',
            style: TextStyle(fontSize: medium, fontWeight: w600),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                // context.read<MapProvider>().addMarkers();
              },
              icon: Icon(Icons.arrow_back_ios_new)),
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<MapProvider>(
                builder: (context, value, child) => GoogleMap(
                  // liteModeEnabled: true,
                  tiltGesturesEnabled: false,
                  zoomControlsEnabled: true,
                  markers: context.read<MapProvider>().markers,
                  initialCameraPosition: CameraPosition(
                      target:
                          LatLng(restaurant.latitude!, restaurant.longitude!),
                      zoom: 14),
                  polylines: Set<Polyline>.of(value.polylines.values),
                  onMapCreated: (controller) async {
                    context.read<MapProvider>().mapController = controller;
                    context.read<MapProvider>().addMarkers();
                    // });
                  },
                ),
              ),
            ),
            OrderFound(
              onMap: true,
              orderData: orderData,
            ),
            if (!(orderData.accepted == true))
              Row(children: [
                ElevatedButton(
                    onPressed: () {
                      if (unassigned && onDeclineUnassigned != null) {
                        onDeclineUnassigned!();
                      } else {
                        OrderController.declineOrder(orderData);
                      }
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                        minimumSize: WidgetStatePropertyAll(
                            Size(MediaQuery.of(context).size.width / 2, 50)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8))))),
                    child: Text(
                      'Decline',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                ElevatedButton(
                    onPressed: () async {
                      if (unassigned) {
                        final result =
                            await OrderController.acceptUnassignedOrder(
                                orderData);
                        if (!result) {
                          showUnavailableDialog(context);
                          onAcceptedUnassigned!();
                          Navigator.of(context).pop();
                          return;
                        }
                        onAcceptedUnassigned!();
                      } else {
                        OrderController.acceptOrder(orderData);
                      }
                      Navigator.of(context).pushReplacement(
                          transitionToNextScreen(LiveTaskScreen(
                        userPosition: userPosition,
                        billingData: billingData,
                        orderData: orderData,
                        restaurant: restaurant,
                      )));
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(colorBrightGreen),
                        minimumSize: WidgetStatePropertyAll(
                            Size(MediaQuery.of(context).size.width / 2, 50)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(8))))),
                    child: Text(
                      'Accept',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ])
          ],
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
}
