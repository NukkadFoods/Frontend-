import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/food_controller.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/Food/allRestaurants.dart';

class FavouriteRestaurants extends StatefulWidget {
  const FavouriteRestaurants({
    super.key,
    required this.userFavouriteRestaurantIds,
    required this.userLat,
    required this.userLng,
  });
  final List<String> userFavouriteRestaurantIds;
  final num userLat;
  final num userLng;

  @override
  State<FavouriteRestaurants> createState() => _FavouriteRestaurantsState();
}

class _FavouriteRestaurantsState extends State<FavouriteRestaurants> {
  bool isAllRestaurantsLoaded = false;
  FetchAllRestaurantsModel? fetchAllRestaurantsModel;

  bool isFavouriteRestaurantsLoaded = false;
  List<Restaurants>? fetchFavouriteRestaurantsModel;

  @override
  void initState() {
    super.initState();
    fetchAllRestaurants();
  }

  void fetchAllRestaurants() async {
    setState(() {
      isAllRestaurantsLoaded = false;
      isFavouriteRestaurantsLoaded = false;
    });
    var allRestaurantsResult =
        await FoodController.fetchAllRestaurants(context: context);
    fetchAllRestaurantsModel = allRestaurantsResult.fold(
      (String text) {
        isAllRestaurantsLoaded = true;
        // context.showSnackBar(message: text);
        return null;
        // return FetchAllRestaurantsModel.empty();
      },
      (FetchAllRestaurantsModel allRestaurantsModel) {
        getFavouriteRestaurants(
            allRestaurantsModel: allRestaurantsModel,
            userFavouriteRestaurantIds: widget.userFavouriteRestaurantIds);
        print("allRestaurantsModel: $fetchAllRestaurantsModel");
        isAllRestaurantsLoaded = true;
        return allRestaurantsModel;
      },
    );
  }

  void getFavouriteRestaurants({
    required FetchAllRestaurantsModel allRestaurantsModel,
    required List<String> userFavouriteRestaurantIds,
  }) {
    setState(() {
      isFavouriteRestaurantsLoaded = false;
    });

    fetchFavouriteRestaurantsModel =
        allRestaurantsModel.getFavoriteRestaurants(userFavouriteRestaurantIds);

    print("favouriteRestaurantsModel: $fetchFavouriteRestaurantsModel");
    isFavouriteRestaurantsLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
     bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
       
        title: Text('Favourite Restaurants', style: h4TextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: isAllRestaurantsLoaded && isFavouriteRestaurantsLoaded
            ? fetchFavouriteRestaurantsModel != null && fetchFavouriteRestaurantsModel!.isNotEmpty
                ? ListView.separated(
                    itemBuilder: (context, index) => restaurant(
                      context: context,
                      restaurantModel: fetchFavouriteRestaurantsModel![index],
                      isFavourite: true,
                      userLng: widget.userLng,
                      userLat: widget.userLat,
                    ),
                    separatorBuilder: (context, index) => SizedBox(height: 2.h),
                    itemCount: fetchFavouriteRestaurantsModel!.length,
                  )
                : const Center(child: Text("No Favourite Restaurant", style: TextStyle(color: textBlack)))
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
