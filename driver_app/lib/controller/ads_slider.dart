import 'dart:convert';
import 'package:card_swiper/card_swiper.dart';
import 'package:driver_app/widgets/constants/colors.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class AdsSlider extends StatefulWidget {
  const AdsSlider({super.key});

  @override
  _AdsSliderState createState() => _AdsSliderState();
}

class _AdsSliderState extends State<AdsSlider> {
  List<Advertisement> activeAds = [];
  Advertisement? randomAd;
  int _currentIndex = 0;
  bool isOffer = true; // Set this to true to show the offer images
  int strakday = 0;
  String currentmonth = '';
  // static final String baseurl = dotenv.env['BASE_URL']!;
  static final String baseurl = AppStrings.baseURL;

  @override
  void initState() {
    super.initState();
    fetchActiveAds();
  }

  Future<void> fetchActiveAds() async {
    try {
      final response =
          await http.get(Uri.parse('$baseurl/adds/getAddsByType/Rider'));

      // print('GET Active Advertisements response code: ${response.statusCode}');
      // print('GET Active Advertisements response body: ${response.body}');

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
          activeAds = ads;
        }
      } else if (response.statusCode == 404) {
        // Handle not found error
        print('Error: No active advertisements found.');
        activeAds =
            []; // Return an empty list if no active advertisements are found
      }

      activeAds = []; // Return an empty list for other errors
    } catch (e) {
      print('Error occurred while fetching active advertisements: $e');
      activeAds = []; // Return an empty list in case of error
    }
    // if (activeAds.isNotEmpty) {
    //   randomAd = activeAds[Random().nextInt(activeAds.length)];
    // }
    if (mounted) {
      setState(() {});
    }
    // } else {
    //   // Handle error if needed
    //   print('Failed to load ads: ${response.statusCode}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (activeAds.isEmpty) {
      return Image.asset(
        'assets/images/noorder.png',
        fit: BoxFit.cover,
      );
    }
    return Container(
      height: 25.h,
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      child: Stack(
        children: [
          Container(
            height: 20.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                // Show different images when isOffer is true
                return SizedBox(
                  height: 25.h, // Adjust height as needed
                  child: GestureDetector(
                    onTap: () {
                      print('Banner tapped');
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        activeAds[index - 1].bannerLink,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),
                );
              },
              itemCount: activeAds.length,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              viewportFraction: 0.99,
              scale: 0.9,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(activeAds.length + 1, (index) {
                return Container(
                  margin: EdgeInsets.all(0.5.w),
                  width: _currentIndex == index ? 2.w : 1.5.w,
                  height: _currentIndex == index ? 2.w : 1.5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? primaryColor : textGrey3,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
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
