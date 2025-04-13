import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/Controller/notification.dart';
import 'package:restaurant_app/Controller/order/order_model.dart';
import 'package:restaurant_app/Controller/order/orders_model.dart';
import 'package:restaurant_app/Controller/order/update_order_response_model.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/toast.dart';

class OrderController {
  static Future<Either<String, OrdersModel>> getAllOrders({
    required BuildContext context,
    required String uid,
  }) async {
    try {
      print(AppStrings.getAllOrdersEndpoint);
      final response =
          await http.get(Uri.parse(AppStrings.getAllOrdersEndpoint));
      final jsonResponse = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (jsonResponse["orders"].isNotEmpty)) {
        final ordersModel = OrdersModel.fromJson(jsonResponse);
        // return ordersModel;
        return Right(ordersModel);
      } else if ((response.statusCode == 200 || response.statusCode == 201) &&
          (jsonResponse["orders"].isEmpty)) {
        // context.showSnackBar(message: AppStrings.noItemsFound);
        return Left(AppStrings.noItemsFound);
      } else if (response.statusCode == 404) {
        // context.showSnackBar(message: json.decode(response.body)['message']);
        return Left(json.decode(response.body)['message']);
      } else {
        // context.showSnackBar(message: AppStrings.failedToLoadOrderItems);
        return Left(AppStrings.failedToLoadOrderItems);
      }
    } catch (e) {
      // context.showSnackBar(message: AppStrings.serverError);
      print(e);
      return Left(AppStrings.serverError);
    }
  }

  static Future<Either<String, OrderModel>> getOrderByID({
    required String uid,
    required String orderId,
    required BuildContext context,
  }) async {
    try {
      print("${AppStrings.getOrderByIDEndpoint}/$uid/$orderId");
      final response = await http
          .get(Uri.parse("${AppStrings.getOrderByIDEndpoint}/$uid/$orderId"));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final orderModel = OrderModel.fromJson(jsonResponse);
        return Right(orderModel);
      } else if (response.statusCode == 404) {
        return Left(json.decode(response.body)['message']);
      } else {
        return Left(AppStrings.failedToLoadOrderItem);
      }
    } catch (e) {
      return Left(AppStrings.serverError);
    }
  }

  static Future<Either<String, UpdateOrderResponseModel>> updateOrder(
      {Map? billingDetail,
      required String uid,
      required String orderId,
      required String status,
      required BuildContext context}) async {
    Map updateData = {"status": status};
    if (billingDetail != null) {
      billingDetail['latePrep'] =
          DateTime.now().isAfter(DateTime.parse(billingDetail['expectedPrep']));
      updateData['billingDetail'] = billingDetail;
    }
    var reqData = {"updateData": updateData};
    String requestBody = jsonEncode(reqData);
    try {
      print("${AppStrings.updateOrderEndpoint}/$uid/$orderId");
      final response = await http.put(
        Uri.parse("${AppStrings.updateOrderEndpoint}/$uid/$orderId"),
        headers: {AppStrings.contentType: AppStrings.applicationJson},
        body: requestBody,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        // context.showSnackBar(message: jsonResponse['message']);
        FirebaseFirestore.instance.runTransaction((t) async {
          t.update(
              FirebaseFirestore.instance.collection('tracking').doc(orderId),
              {'status': status});
        });
        final restaurantName = jsonDecode(SharedPrefsUtil()
            .getString(AppStrings.restaurantModel)!)['user']['nukkadName'];
        NotificationService.sendNotification(
            toUid: uid,
            toApp: 'user',
            title: "Order $status",
            body: "Your order from ${restaurantName ?? ''} is $status");
        return Right(UpdateOrderResponseModel.fromJson(jsonResponse));
      } else if (response.statusCode == 404) {
        final jsonResponse = jsonDecode(response.body);
        // context.showSnackBar(message: jsonResponse['message']);
        return Left(jsonResponse['message']);
      } else {
        // context.showSnackBar(message: AppStrings.failedToUpdateOrderItem);
        return Left(AppStrings.failedToUpdateOrderItem);
      }
    } catch (e) {
      // context.showSnackBar(message: AppStrings.serverError);
      return Left(AppStrings.serverError);
    }
  }

  static Future<void> deleteOrder({
    required String uid,
    required String orderId,
    required BuildContext context,
  }) async {
    try {
      print("${AppStrings.deleteOrderEndpoint}/$uid/$orderId");
      final response = await http.delete(
        Uri.parse("${AppStrings.deleteOrderEndpoint}/$uid/$orderId"),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        Toast.showToast(message: '${jsonResponse['message']}');
      } else if (response.statusCode == 404) {
        final jsonResponse = jsonDecode(response.body);
        Toast.showToast(message: '${jsonResponse['message']}');
      } else {
        Toast.showToast(
            message: AppStrings.failedToDeleteOrderItem, isError: true);
      }
    } catch (e) {
      Toast.showToast(message: AppStrings.serverError, isError: true);
    }
  }
}
