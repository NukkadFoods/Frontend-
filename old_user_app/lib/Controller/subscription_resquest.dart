import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/toasts.dart';

class SubscribeController {
  static GetSubscriptionModel? subscription;

  static Future<bool> subscribeUser({
    required BuildContext context,
    required SubscribeRequestModel subscribeRequest,
  }) async {
    final String url =
        "${AppStrings.baseURL}/subscribe/subscribe"; // Ensure endpoint is correct

    try {
      // Debugging: Print the request body
      print('Request body: ${jsonEncode(subscribeRequest.toJson())}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscribeRequest.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Subscription successful');
        final sub = jsonDecode(response.body)['subscription'];
        final plan = sub['plans'].last;
        subscription = GetSubscriptionModel(
            id: sub['_id'] ?? "",
            subscribedById: sub['subscribedById'] ?? "",
            role: "User",
            subscriptionPlanId: plan['subscriptionPlanId'] ?? "",
            startDate: plan['startDate'],
            endDate: plan['endDate']);
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
    final String url = "${AppStrings.baseURL}/subscribe/subscribe/$id";
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Create the subscription model

        if (responseData['plans'].isNotEmpty) {
          final plan = responseData['plans'].last;
          final sub = GetSubscriptionModel(
              id: responseData['_id'] ?? "",
              subscribedById: responseData['subscribedById'] ?? "",
              role: "User",
              subscriptionPlanId: plan['subscriptionPlanId'] ?? "",
              startDate: plan['startDate'],
              endDate: plan['endDate']);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isSubscribed', true);

          if (DateTime.now().isBefore(DateTime.parse(sub.endDate))) {
            subscription = sub;
            return sub;
          }
        }

        return null; // Return the subscription model
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
  final String endDate;

  SubscribeRequestModel({
    required this.subscribeById,
    required this.role,
    required this.subscriptionPlanId,
    required this.startDate,
    required this.endDate,
  });

  // Method to convert model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      "subscribeById": subscribeById,
      "role": role,
      "subscriptionPlanId": subscriptionPlanId,
      "startDate": startDate,
      'endDate': endDate
    };
  }
}

class GetSubscriptionModel {
  final String id; // The subscription ID
  final String subscribedById; // ID of the user subscribing
  final String role; // Role of the subscriber
  final String subscriptionPlanId; // ID of the subscription plan
  final String startDate; // Start date of the subscription
  final String endDate; // end date of the subscription

  GetSubscriptionModel({
    required this.id,
    required this.subscribedById,
    required this.role,
    required this.subscriptionPlanId,
    required this.startDate,
    required this.endDate,
  });

  // Method to create a SubscriptionModel from JSON
  factory GetSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return GetSubscriptionModel(
        id: json['_id'],
        subscribedById: json['subscribedById'],
        role: json['role'],
        subscriptionPlanId: json['subscriptionPlanId'],
        startDate: json['startDate'],
        endDate: json['endDate']);
  }
}
