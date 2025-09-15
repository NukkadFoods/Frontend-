import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:user_app/widgets/constants/strings.dart';

class AdvertisementController {
  static Future<List<Advertisement>> getActiveAdvertisements() async {
    try {
      final response = await http
          .get(Uri.parse('${AppStrings.baseURL}/adds/getAddsByType/User'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['adds'] != null) {
          List<Advertisement> ads = [];
          final now = DateTime.now();
          for (int i = 0; i < data['adds'].length; i++) {
            if (data["adds"][i]['status'] == "active" &&
                now.isBefore(DateTime.parse(data["adds"][i]['endDate']))) {
              ads.add(Advertisement.fromJson(data['adds'][i]));
            }
          }
          return ads;
        }
      } else if (response.statusCode == 404) {
        // Handle not found error
        print('Error: No active advertisements found.');
        return []; // Return an empty list if no active advertisements are found
      }

      return []; // Return an empty list for other errors
    } catch (e) {
      print('Error occurred while fetching active advertisements: $e');
      return []; // Return an empty list in case of error
    }
  }
}

class Advertisement {
  final String id;
  final String? restaurantId;
  final String title;
  final String description;
  final String status;
  final double amountPaid;
  final DateTime startDate;
  final DateTime endDate;
  final String bannerLink;

  Advertisement({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.status,
    required this.amountPaid,
    required this.startDate,
    required this.endDate,
    required this.bannerLink,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['_id'],
      restaurantId: json['restaurantId'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      amountPaid: json['amountPaid'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      bannerLink: json['bannerLink'],
    );
  }
}
