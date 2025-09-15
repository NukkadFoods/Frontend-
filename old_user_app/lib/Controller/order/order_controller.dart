import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:user_app/Controller/order/order_model.dart';
import 'package:user_app/Controller/order/orders_model.dart';
import 'package:user_app/Controller/order/update_order_response_model.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/toasts.dart';

class OrderController {
  static Future<Either<String, OrdersModel>> getAllOrders({
    required BuildContext context,
    required String uid,
  }) async {
    try {
      print("${AppStrings.getAllOrdersEndpoint}/$uid");
      final response =
          await http.get(Uri.parse("${AppStrings.getAllOrdersEndpoint}/$uid"));
      final jsonResponse = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (jsonResponse["orders"].length != 0)) {
        final ordersModel = OrdersModel.fromJson(jsonResponse);
        // return ordersModel;
        return Right(ordersModel);
      } else if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonResponse["orders"].length == 0) {
        // context.showSnackBar(message: AppStrings.noItemsFound);
        // Toast.showToast(message:AppStrings.noOrdersFound,isError: true);
        return const Left(AppStrings.noOrdersFound);
      } else if (response.statusCode == 404) {
        // context.showSnackBar(message: json.decode(response.body)['message']);
        context.read<GlobalProvider>().firstOrder = true;
        return Left(json.decode(response.body)['message']);
      } else if (response.statusCode == 500) {
        // context.showSnackBar(message: json.decode(response.body)['message']);
        return const Left(AppStrings.noOrdersFound);
      } else {
        // context.showSnackBar(message: AppStrings.failedToLoadOrderItems);
        return const Left(AppStrings.failedToLoadOrderItems);
      }
    } catch (e) {
      Toast.showToast(message: 'Something went wrong!', isError: true);
      // context.showSnackBar(message: AppStrings.serverError);
      return const Left(AppStrings.serverError);
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
        Toast.showToast(message: 'Something went wrong!', isError: true);
        return const Left(AppStrings.failedToLoadOrderItem);
      }
    } catch (e) {
      Toast.showToast(message: 'Something went wrong!', isError: true);
      return const Left(AppStrings.serverError);
    }
  }

  static Future<Either<String, UpdateOrderResponseModel>> updateOrder({
    required String uid,
    required String orderId,
    required String status,
    required BuildContext context,
  }) async {
    var reqData = {
      "updateData": {"status": status}
    };
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
        return Right(UpdateOrderResponseModel.fromJson(jsonResponse));
      } else if (response.statusCode == 404) {
        final jsonResponse = jsonDecode(response.body);
        // context.showSnackBar(message: jsonResponse['message']);
        Toast.showToast(message: 'Something went wrong!', isError: true);
        return Left(jsonResponse['message']);
      } else {
        // context.showSnackBar(message: AppStrings.failedToUpdateOrderItem);
        Toast.showToast(message: 'Something went wrong!', isError: true);
        return const Left(AppStrings.failedToUpdateOrderItem);
      }
    } catch (e) {
      Toast.showToast(message: 'Something went wrong!', isError: true);
      // context.showSnackBar(message: AppStrings.serverError);
      return const Left(AppStrings.serverError);
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
      } else if (response.statusCode == 404) {
        Toast.showToast(message: 'Something went wrong!', isError: true);
      } else {
        Toast.showToast(message: 'Something went wrong!', isError: true);
      }
    } catch (e) {
      Toast.showToast(message: 'Something went wrong!', isError: true);
    }
  }

  static Future<Either<String, String>> createOrder({
    required BuildContext context,
    required OrderModel orderData, // Pass order data as a map
  }) async {
    try {
      String requestBody = jsonEncode(orderData.toJson());

      print(AppStrings.createOrderEndpoint);

      final response = await http.post(
        Uri.parse(AppStrings.createOrderEndpoint),
        headers: {
          AppStrings.contentType: AppStrings.applicationJson,
        },
        body: requestBody,
      );
      print('order creation ${response.statusCode}');
      print('order creation ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return Right(jsonResponse['message']); // Return the success message
      } else if (response.statusCode == 400) {
        final jsonResponse = jsonDecode(response.body);
        return Left(jsonResponse['message']); // Return the error message
      } else {
        return const Left(
            AppStrings.failedToCreateOrderItem); // Generic error message
      }
    } catch (e) {
      return const Left(AppStrings.serverError);
    }
  }
}
