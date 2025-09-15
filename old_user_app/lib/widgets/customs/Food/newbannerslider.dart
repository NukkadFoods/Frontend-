import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/Ads/Ads_model.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'dart:convert'; 

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  List<Advertisement> activeAds = [];

  @override
  void initState() {
    super.initState();
    fetchActiveAds();
  }

  Future<void> fetchActiveAds() async {
    //  API call to fetch active advertisements
    final response = await http.get(Uri.parse('${AppStrings.baseURL}/adds/getActiveAdds'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        activeAds = (data['adds'] as List)
            .map((adJson) => Advertisement.fromJson(adJson))
            .toList();
      });
    } else {
      // Handle error if needed
      print('Failed to load ads: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:  20.h,
      width: 100.w, // Adjust height as needed
      child: Swiper(
        itemCount: activeAds.length,
        itemBuilder: (BuildContext context, int index) {
          final ad = activeAds[index];
          return GestureDetector(
            onTap: () {
             // Banner tapped
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                ad.bannerLink,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        viewportFraction: 0.9,
        scale: 0.9,
      ),
    );
  }
}
