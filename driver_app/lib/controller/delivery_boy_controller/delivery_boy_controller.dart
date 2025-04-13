import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:driver_app/controller/delivery_boy_controller/delivery_boy_model.dart';
import 'package:driver_app/controller/delivery_boy_controller/get_delivery_boy_by_id_model.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class DeliveryBoyController {
  static Map deliveryBoyData={};

  static Future<Either<String, GetDeliveryBoyByIdModel>> getDeliveryBoyById({
    required String id,
    required BuildContext context,
  }) async {
    try {
      final response = await http
          .get(Uri.parse('${AppStrings.deliveryBoyByIdEndpoint}/$id'));
      final jsonResponse = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonResponse['executed'] == true) {
        final deliveryBoyModel = GetDeliveryBoyByIdModel.fromJson(jsonResponse);

        return Right(deliveryBoyModel);
      } else if (response.statusCode == 404) {
        return Left(jsonResponse['message']);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left(jsonResponse['message']);
      } else if (response.statusCode == 500) {
        return Left(AppStrings.noDeliveryBoyFound);
      } else {
        return Left(jsonResponse['message']);
      }
    } catch (e) {
      return Left(AppStrings.serverError);
    }
  }

  static Future<Either<String, String>> updateDeliveryBoyById({
    required String id,
    required Map<String, dynamic> updateData,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppStrings.updateDeliveryBoyEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'updateData': updateData,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonResponse['executed'] == true) {
        print(jsonResponse);
        // final deliveryBoy =
        //     GetDeliveryBoyByIdModel.fromJson(jsonResponse['deliveryBoy']);
        return Right(jsonResponse['message']);
      } else if (response.statusCode == 404) {
        return Left(jsonResponse['message']);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left(jsonResponse['message']);
      } else if (response.statusCode == 500) {
        return Left(AppStrings.noDeliveryBoyFound);
      } else {
        return Left(jsonResponse['message']);
      }
    } catch (e) {
      return Left(AppStrings.serverError);
    }
  }

  static Future<Either<String, String>> deleteDeliveryBoyById({
    required String id,
    required BuildContext context,
  }) async {
    try {
      final response = await http
          .delete(Uri.parse('${AppStrings.deliveryBoyByIdEndpoint}/$id'));
      final jsonResponse = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonResponse['executed'] == true) {
        return Right(jsonResponse['message']);
      } else if (response.statusCode == 404) {
        return Left(jsonResponse['message']);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left(jsonResponse['message']);
      } else if (response.statusCode == 500) {
        return Left(AppStrings.noDeliveryBoyFound);
      } else {
        return Left(jsonResponse['message']);
      }
    } catch (e) {
      return Left(AppStrings.serverError);
    }
  }

  static Future<Either<String, List<DeliveryBoy>>> getAllDeliveryBoys({
    required BuildContext context,
  }) async {
    try {
      final response =
          await http.get(Uri.parse(AppStrings.allDeliveryBoysEndpoint));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final deliveryBoys = (jsonResponse['deliveryBoys'] as List)
            .map((i) => DeliveryBoy.fromJson(i))
            .toList();
        return Right(deliveryBoys);
      } else if (response.statusCode == 500) {
        return Left(AppStrings.noDeliveryBoysFound);
      } else {
        return Left(jsonResponse['message']);
      }
    } catch (e) {
      return Left(AppStrings.serverError);
    }
  }
}
