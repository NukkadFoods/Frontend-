import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/Ads/Ads_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/screens/Restaurant/restaurantScreen.dart';
import 'package:user_app/screens/rewards/rewardsScreen.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

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
  String currentmonth = '';

  @override
  void initState() {
    super.initState();
    fetchActiveAds();
    currentmonth = getCurrentMonth();
  }

  Future<void> fetchActiveAds() async {
    // //  API call to fetch active advertisements
    // final response =
    //     await http.get(Uri.parse('${AppStrings.baseURL}/adds/getActiveAdds'));

    // if (response.statusCode == 200) {
    //   final data = json.decode(response.body);
    //   activeAds = (data['adds'] as List)
    //       .map((adJson) => Advertisement.fromJson(adJson))
    //       .toList();
    activeAds = await AdvertisementController.getActiveAdvertisements();
    if (activeAds.isNotEmpty) {
      randomAd = activeAds[Random().nextInt(activeAds.length)];
    }
    if (mounted) {
      setState(() {});
    }
    // } else {
    //   // Handle error if needed
    //   print('Failed to load ads: ${response.statusCode}');
    // }
  }

  String getCurrentMonth() {
    // Create a DateTime object for the current date
    DateTime now = DateTime.now();

    // Get the month in a full format (e.g., October)

    // Define a list of month names
    List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    // Return the current month's name
    return monthNames[now.month - 1]; // Subtracting 1 for zero-based index
  }

  @override
  Widget build(BuildContext context) {
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
                if (index != 0) {
                  return SizedBox(
                    height: 25.h, // Adjust height as needed
                    child: GestureDetector(
                      onTap: () {
                        if (activeAds[index - 1].restaurantId != null) {
                          final restaurant = context
                              .read<GlobalProvider>()
                              .restaurants!
                              .restaurants!
                              .firstWhere((res) =>
                                  res.id == activeAds[index - 1].restaurantId);
                          Navigator.of(context).push(transitionToNextScreen(
                              RestaurantScreen(
                                  restaurantID:
                                      activeAds[index - 1].restaurantId!,
                                  isFavourite: false,
                                  restaurantName: restaurant.nukkadName!,
                                  res: restaurant)));
                        }
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
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(transitionToNextScreen(const RewardsScreen()));
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/ads/ad1bg.png'),
                          fit: BoxFit.cover,
                        ),
                        gradient: LinearGradient(
                          colors: [Color(0xFF17A1FA), Color(0xFF9747FF)],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Foodie \nRewards !',
                                  style: TextStyle(
                                    color: const Color(0xFFFFCE5B),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Consumer<GlobalProvider>(
                                  builder: (context, value, child) => Text(
                                    'Day ${value.streak} of daily streak,\nEarn ₹ ${value.constants['foodieReward']} in wallet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                                Text(
                                  '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Center(
                                  child: Consumer<GlobalProvider>(
                                    builder: (context, value, child) =>
                                        SvgPicture.asset(
                                      'assets/icons/day${value.streak%7}.svg',
                                      height: 15.h,
                                      width: 15.h,
                                      colorFilter: value.streak == 0
                                          ? const ColorFilter.mode(
                                              Colors.white, BlendMode.srcATop)
                                          : null,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/quest.svg',
                                      height: 10,
                                      width: 10,
                                      color: textWhite,
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: activeAds.length + 1,
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
