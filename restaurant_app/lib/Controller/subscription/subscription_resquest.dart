import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscribeController {
  static Future<bool> subscribeUser({
    required BuildContext context,
    required SubscribeRequestModel subscribeRequest,
  }) async {
    final String url =
        "${AppStrings.baseURL}/subscribe/subscribe"; // Ensure endpoint is correct

    try {
      // Debugging: Print the request body
      print('Request body: ${jsonEncode(subscribeRequest.toJson())}');
      // final subscription = await getSubscriptionById(
      //     context: context,
      //     id: SharedPrefsUtil().getString(AppStrings.userId)!);
      // if (subscription != null) {
      //   final endDate = DateTime.parse(subscription.startDate)
      //       .add(const Duration(days: 120));
      //   if (endDate.isBefore(DateTime.now())) {
      //     Toast.showToast(message: "Previous Subscription is not ended yet. Can't Subscribe");
      //     return;
      //   }
      // }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscribeRequest.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Subscription successful');
        Toast.showToast(message: 'Subscribed...!!');
        return true;
      } else {
        // Print the response status and body for debugging
        print('Failed to subscribe: ${response.statusCode} - ${response.body}');
        Toast.showToast(message: "Oops, Something went wrong!", isError: true);
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  static Future<GetSubscriptionModel?> getSubscriptionById({
    required BuildContext context,
    required String id,
  }) async {
    final String url =
        "${AppStrings.baseURL}/subscribe/subscribe/$id"; // Build the full URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Create the subscription model
        GetSubscriptionModel subscription =
            GetSubscriptionModel.fromJson(responseData);

        // If subscription is found, store isSubscribed in Shared Preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isSubscribed', true);
        return subscription; // Return the subscription model
      } else {
        // Handle failure
        print('Failed to get subscription: ${response.body}');
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
    return null; // Return null if there was an error
  }
}

class SubscribeRequestModel {
  final String subscribeById;
  final String role;
  final String subscriptionPlanId;
  final String startDate;

  SubscribeRequestModel({
    required this.subscribeById,
    required this.role,
    required this.subscriptionPlanId,
    required this.startDate,
  });

  // Method to convert model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      "subscribeById": subscribeById,
      "role": role,
      "subscriptionPlanId": subscriptionPlanId,
      "startDate": startDate,
    };
  }
}

class GetSubscriptionModel {
  final String id; // The subscription ID
  final String subscribedById; // ID of the user subscribing
  final String role; // Role of the subscriber
  final String subscriptionPlanId; // ID of the subscription plan
  final String startDate; // Start date of the subscription
  final int version; // Version field, typically used by MongoDB

  GetSubscriptionModel({
    required this.id,
    required this.subscribedById,
    required this.role,
    required this.subscriptionPlanId,
    required this.startDate,
    required this.version,
  });

  // Method to create a SubscriptionModel from JSON
  factory GetSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return GetSubscriptionModel(
      id: json['_id'],
      subscribedById: json['subscribedById'],
      role: json['role'],
      subscriptionPlanId: json['subscriptionPlanId'],
      startDate: json['startDate'],
      version: json['__v'],
    );
  }
}
