import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/Food/allRestaurants.dart';

class BuildAllRestaurantListWidget extends StatelessWidget {
  const BuildAllRestaurantListWidget({
    super.key,
    this.fetchAllRestaurantsModel,
    required this.favouriteRestaurantsList,
    required this.userLat,
    required this.userLng,
    this.navigator,
    required this.currentFilters,
  });
  final FetchAllRestaurantsModel? fetchAllRestaurantsModel;
  final List<Restaurants> favouriteRestaurantsList;
  final num userLat;
  final num userLng;
  final Map currentFilters;
  final NavigatorState? navigator;

  @override
  Widget build(BuildContext context) {
    bool isCuisineMatched = false;
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    final sortedRestaurants = fetchAllRestaurantsModel!.restaurants!
      ..sort((a, b) => b.isOpen! ? 1 : -1);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ALL RESTAURANTS',
                style: isdarkmode
                    ? titleTextStyle.copyWith(color: textGrey2)
                    : titleTextStyle,
                textAlign: TextAlign.center,
              ),
              Text(
                '${fetchAllRestaurantsModel != null ? fetchAllRestaurantsModel!.restaurants!.length : 0} Restaurants delivering to you',
                style: body5TextStyle.copyWith(color: textGrey2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          child: fetchAllRestaurantsModel != null &&
                  fetchAllRestaurantsModel!.restaurants!.isNotEmpty
              ? ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  // Sort the restaurants by the `isOpen` field
                  itemCount: fetchAllRestaurantsModel!
                      .restaurants!
                      // .where((restaurant) => restaurant.isOpen!)
                      .length,
                  itemBuilder: (context, index) {
                    // Sort the list: Open restaurants at the top

                    final distance = calculateDistance(
                      userLat,
                      userLng,
                      sortedRestaurants[index].latitude ?? 0,
                      sortedRestaurants[index].longitude ?? 0,
                    );

                    double distanceKm = 0.0;
                    final String temp = distance.split(' ')[0];
                    if (temp.endsWith('k')) {
                      distanceKm = double.tryParse(temp.split('k')[0]) ?? 0.0;
                      distanceKm = distanceKm * 1000;
                    } else {
                      distanceKm =
                          double.tryParse(distance.split(' ')[0]) ?? 0.0;
                      if (distance.endsWith("meters")) {
                        distanceKm = distanceKm / 1000;
                      }
                    }

                    final travelTime = estimateTravelTime(distance);
                    isCuisineMatched = false;
                    for (int i = 0; i < currentFilters["Cuisine"].length; i++) {
                      if (sortedRestaurants[index]
                          .cuisines!
                          .contains(currentFilters["Cuisine"][i])) {
                        isCuisineMatched = true;
                        break;
                      }
                    }

                    if ((isCuisineMatched ||
                            currentFilters["Cuisine"].isEmpty) &&
                        (currentFilters['Distance'] == null ||
                            currentFilters['Distance'] > distanceKm) &&
                        (currentFilters['Delivery Time'] == null ||
                            currentFilters['Delivery Time'] >
                                double.tryParse(travelTime.split(' ')[0])) &&
                        (currentFilters['Rating'] == null ||
                            currentFilters['Rating'] <=
                                sortedRestaurants[index].getAverageRating())) {
                      return restaurant(
                          userLat: userLat,
                          userLng: userLng,
                          context: context,
                          restaurantModel: sortedRestaurants[index],
                          isFavourite:
                              fetchAllRestaurantsModel!.isFavoriteRestaurant(
                            restaurant: sortedRestaurants[index],
                            favoriteIds: favouriteRestaurantsList,
                          ),
                          navigator: navigator);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                )
              : Center(
                  child: Text(
                    AppStrings.noRestaurantsFound,
                    style: TextStyle(color: isdarkmode ? textWhite : textBlack),
                  ),
                ),
        ),
      ],
    );
  }
}
