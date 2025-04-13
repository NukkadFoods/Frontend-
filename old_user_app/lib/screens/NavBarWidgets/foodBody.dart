// ignore_for_file: file_names
import 'dart:async';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/all_menu_item_controller.dart';
import 'package:user_app/Controller/food/food_controller.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/food/model/vegmenu.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/Widgets/customs/Food/offersSlider.dart';
import 'package:user_app/screens/Restaurant/nearestResto.dart';
import 'package:user_app/screens/banned_screen.dart';
import 'package:user_app/screens/nointernet.dart';
import 'package:user_app/screens/ontimepromisescreen.dart';
import 'package:user_app/widgets/buttons/customanimation.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/Food/adsSlider.dart';
import 'package:user_app/widgets/customs/Food/appBar.dart';
import 'package:user_app/widgets/customs/Food/restaurantSlider.dart';
import 'package:user_app/widgets/customs/Food/searchBar.dart';
import 'package:user_app/widgets/customs/Food/sectionGrid.dart';
import 'package:user_app/widgets/customs/Food/sectionSlider.dart';
import 'package:user_app/widgets/customs/Food/vegitemsearch.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:user_app/widgets/filters.dart';
import 'package:user_app/widgets/food/build_all_restaurant_list_widget.dart';
import 'package:user_app/widgets/sortbottomsheet.dart';

class FoodBody extends StatefulWidget {
  const FoodBody({super.key});

  @override
  State<FoodBody> createState() => _FoodBodyState();
}

class _FoodBodyState extends State<FoodBody>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<String> foodCategories = [
    'Sandwich',
    'Khichadi',
    'Noodles',
    'chole bhature',
    'Gulab Jamun',
    'Rolls',
    'Kebab',
    'Ice Cream',
    'Rasgulla',
    'Pastry',
    'Fried Rice',
    'Dosa',
    'Burger',
    'Biryani',
    'Momos',
    'Paratha',
    'Pasta',
    'Chicken',
    'North Indian',
    'Samosa',
    'Coffee',
    'Shakes',
  ];
  List<String> foodImages = [
    'assets/food/bowl_1.png',
    'assets/food/bowl_2.png',
    'assets/food/noodles.png',
    'assets/food/chole.png',
    'assets/food/gulabjam.png',
    'assets/food/rolls.png',
    'assets/food/kabab.png',
    'assets/food/icecream.png',
    'assets/food/rasgulla.png',
    'assets/food/pastry.png',
    'assets/food/friedrice.png',
    'assets/food/dosa.png',
    'assets/food/burger.png',
    'assets/food/biryani.png',
    'assets/food/momos.png',
    'assets/food/paratha.png',
    'assets/food/pasta.png',
    'assets/food/chicken.png',
    'assets/food/north.png',
    'assets/food/samosa.png',
    'assets/food/cofee.png',
    'assets/food/shakes.png',
  ];
  Map currentFilters = {"Cuisine": []};
  UserModel? userModel;
  bool triedLoading = false;
  List offerData = [];
  NavigatorState? _navigator;
  String currentSortSetting = '';
  num? userLat;
  num? userLng;
  bool isAllRestaurantsLoaded = false;
  FetchAllRestaurantsModel? fetchAllRestaurantsModel;
  FetchAllRestaurantsModel? sortedRestaurantsModel;

  bool isLatestRestaurantsLoaded = false;
  List<Restaurants>? fetchLatestRestaurantsModel;

  bool isNearestRestaurantsLoaded = false;
  List<Restaurants>? fetchNearestRestaurantsModel;

  bool isQuickDeliveryRestaurantsLoaded = false;
  List<Restaurants>? fetchQuickDeliveryRestaurantsModel;

  bool isFavouriteRestaurantsLoaded = false;
  List<Restaurants>? fetchFavouriteRestaurantsModel;
  final TextEditingController searchController = TextEditingController();

  late String barText;
  String prefsSaveAs = '';
  String prefsAddress = '';
  var savedas;
  var address;
  bool _isOpen = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _loaddata();
  }

  Future<void> _loaddata() async {
    // _screenKey.currentState?.fetchAllRestaurants();
    fetchAllRestaurants();
    AllMenu.getAllMenuItems();
    Vegmenu.getAllVegMenuItems();
  }

  @override
  void dispose() {
    // Dispose of the timer when the widget is destroyed

    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void changeLocation() async {
    userLat = SharedPrefsUtil().getDouble("CurrentLatitude");
    userLng = SharedPrefsUtil().getDouble("CurrentLongitude");
    await _loaddata();
    if (mounted) {
      setState(() {});
    }
  }

  // Fetch all restaurants and update states for different types of restaurant lists
  void fetchAllRestaurants() async {
    setState(() {
      isAllRestaurantsLoaded = false;
      isLatestRestaurantsLoaded = false;
      isNearestRestaurantsLoaded = false;
      isQuickDeliveryRestaurantsLoaded = false;
      isFavouriteRestaurantsLoaded = false;
    });

    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    var userResult =
        await UserController.getUserById(context: context, id: userId);
    var allRestaurantsResult;

    userResult.fold((String text) {
      userLat = SharedPrefsUtil().getDouble("CurrentLatitude") ?? 0;
      userLng = SharedPrefsUtil().getDouble("CurrentLongitude") ?? 0;
      savedas = SharedPrefsUtil().getString("CurrentSaveAs") ?? '';
      address = SharedPrefsUtil().getString("CurrentAddress") ?? '';
      setState(() {
        isAllRestaurantsLoaded = true;
      });
    }, (UserModel userModel) async {
      if (userModel.user!.isBanned == true) {
        Navigator.of(context).pushAndRemoveUntil(
            transitionToNextScreen(const BannedScreen()), (_) => false);
        return;
      }
      userLat = userModel.user?.addresses![0].latitude ?? 0;
      userLng = userModel.user?.addresses![0].longitude ?? 0;
      savedas = userModel.user?.addresses![0].saveAs ?? '';
      address = userModel.user?.addresses![0].address ?? '';
      this.userModel = userModel;
      context.read<GlobalProvider>().user = userModel;
      await _updateUserLocation(userModel);
    });
    allRestaurantsResult =
        await FoodController.fetchAllRestaurants(context: context);
    fetchAllRestaurantsModel = allRestaurantsResult.fold(
      (String text) {
        isAllRestaurantsLoaded = true;

        return FetchAllRestaurantsModel.empty();
      },
      (FetchAllRestaurantsModel allRestaurantsModel) {
        if (mounted) {
          context.read<GlobalProvider>().updateResNames(allRestaurantsModel);
        }
        getLastestRestaurants(allRestaurantsModel: allRestaurantsModel);
        getNearestRestaurants(allRestaurantsModel: allRestaurantsModel);
        getQuickDeliveryRestaurants(allRestaurantsModel: allRestaurantsModel);
        getFavouriteRestaurants(
          allRestaurantsModel: allRestaurantsModel,
          userFavouriteRestaurantIds: userModel == null
              ? []
              : userModel!.user?.favoriteRestaurants ?? [],
        );
        isAllRestaurantsLoaded = true;
        return allRestaurantsModel;
      },
    );
    sortedRestaurantsModel = fetchAllRestaurantsModel;
    triedLoading = true;
  }

  Future<void> _updateUserLocation(UserModel userModel) async {
    userLat = SharedPrefsUtil().getDouble("CurrentLatitude") ??
        userModel.user?.addresses![0].latitude ??
        0;
    userLng = SharedPrefsUtil().getDouble("CurrentLongitude") ??
        userModel.user?.addresses![0].longitude ??
        0;
    savedas = SharedPrefsUtil().getString("CurrentSaveAs") ??
        userModel.user?.addresses![0].saveAs ??
        '';
    address = SharedPrefsUtil().getString("CurrentAddress") ??
        userModel.user?.addresses![0].address ??
        '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Only save if they are not already saved
    if (prefs.getString('CurrentAddress') == null ||
        prefs.getString('CurrentSaveAs') == null) {
      await prefs.setString('CurrentAddress', address);
      await prefs.setString('CurrentSaveAs', savedas);
      await prefs.setDouble('CurrentLatitude', userLat!.toDouble());
      await prefs.setDouble('CurrentLongitude', userLng!.toDouble());
    }
  }

// Fetch latest restaurants based on all restaurants model
  void getLastestRestaurants({
    required FetchAllRestaurantsModel allRestaurantsModel,
  }) {
    isLatestRestaurantsLoaded = false;
    if (mounted) {
      setState(() {});
    }

    fetchLatestRestaurantsModel =
        allRestaurantsModel.sortRestaurantsByTimestamp() ?? [];

    print("latestRestaurantsModel: $fetchLatestRestaurantsModel");
    isLatestRestaurantsLoaded = true;
  }

// Fetch nearest restaurants based on all restaurants model and user location
  void getNearestRestaurants({
    required FetchAllRestaurantsModel allRestaurantsModel,
  }) {
    if (mounted) {
      setState(() {
        isNearestRestaurantsLoaded = false;
      });
    }

    // Sort all restaurants by distance from user's location
    fetchNearestRestaurantsModel = allRestaurantsModel
            .sortRestaurantsByDistance(userLat ?? 0, userLng ?? 0) ??
        [];

    print("nearestRestaurantsModel: $fetchNearestRestaurantsModel");
    isNearestRestaurantsLoaded = true;
  }

// Fetch favorite restaurants based on all restaurants model and user's favorite list
  void getFavouriteRestaurants({
    required FetchAllRestaurantsModel allRestaurantsModel,
    required List<String> userFavouriteRestaurantIds,
  }) {
    setState(() {
      isFavouriteRestaurantsLoaded = false;
    });

    // Get favorite restaurants from the user's favorite list
    fetchFavouriteRestaurantsModel =
        allRestaurantsModel.getFavoriteRestaurants(userFavouriteRestaurantIds);

    print("favouriteRestaurantsModel: $fetchFavouriteRestaurantsModel");
    isFavouriteRestaurantsLoaded = true;
  }

  // Fetch restaurants for quick delivery based on preparation time
  void getQuickDeliveryRestaurants({
    required FetchAllRestaurantsModel allRestaurantsModel,
  }) {
    isQuickDeliveryRestaurantsLoaded = false;
    if (mounted) {
      setState(() {});
    }

    // Sort all restaurants by preparation time
    fetchQuickDeliveryRestaurantsModel =
        allRestaurantsModel.sortRestaurantsByTimeToPrepare() ?? [];

    print("quickDeliveryRestaurantsModel: $fetchQuickDeliveryRestaurantsModel");
    isQuickDeliveryRestaurantsLoaded = true;
  }

  // void _scrollListener() {
  //   if (_scrollController.position.pixels ==
  //           _scrollController.position.maxScrollExtent &&
  //       !_isLoading) {
  //     _loadMoreRestaurants();
  //   }
  // }

  // void _loadMoreRestaurants() async {
  //   if (!_isLoading) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     await Future.delayed(const Duration(seconds: 2));
  //     setState(() {
  //       restaurantNames.addAll([
  //         'New Restaurant ${restaurantNames.length + 1}',
  //         'New Restaurant ${restaurantNames.length + 2}',
  //       ]);
  //       restaurantImages.addAll(['new_image_url1', 'new_image_url2']);
  //       _isLoading = false;
  //     });
  //   }
  // }
  String _getGreetingBasedOnTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 11) {
      return 'Good Morning';
    } else if (hour >= 11 && hour < 16) {
      return 'Good Afternoon';
    } else if (hour >= 16 && hour < 20) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  String _getfoodTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 11) {
      return 'breakfast time';
    } else if (hour >= 11 && hour < 16) {
      return 'lunch time';
    } else if (hour >= 16 && hour < 20) {
      return 'breakfast time';
    } else {
      return 'dinner time';
    }
  }

  Widget _buildElevatedButton({
    required String label,
    required String iconPath,
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 34.w,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        label: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        ),
        icon: SvgPicture.asset(iconPath, height: 1.8.h),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          minimumSize: Size(3.w, 4.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: borderColor, width: 1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (triedLoading &&
          (fetchFavouriteRestaurantsModel == null ||
              fetchQuickDeliveryRestaurantsModel == null ||
              fetchNearestRestaurantsModel == null ||
              fetchLatestRestaurantsModel == null ||
              fetchAllRestaurantsModel == null ||
              userLat == null ||
              userLng == null)) {
        dev.log(userLat.toString());
        Navigator.of(context)
            .pushReplacement(transitionToNextScreen(const NoInternetScreen(
          fromHomeScreen: true,
        )));
      }
    });
    super.build(context);
    final String greeting = _getGreetingBasedOnTime();
    final String foodtime = _getfoodTime();
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    // Check if any of the key data is null
    if (fetchFavouriteRestaurantsModel == null ||
        fetchQuickDeliveryRestaurantsModel == null ||
        fetchNearestRestaurantsModel == null ||
        fetchLatestRestaurantsModel == null ||
        fetchAllRestaurantsModel == null ||
        userLat == null ||
        userLng == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isOpen) ...[
              _buildElevatedButton(
                label: 'Nearest ',
                iconPath: 'assets/icons/scooter.svg',
                backgroundColor: primaryColor,
                foregroundColor: isdarkmode ? textBlack : textWhite,
                borderColor: primaryColor,
                onPressed: () {
                  Navigator.of(context)
                      .push(transitionToNextScreen(Nearestresto(
                    restaurants: fetchNearestRestaurantsModel!,
                    favoriteRestaurants: fetchFavouriteRestaurantsModel ?? [],
                    userLat: userLat ?? 0,
                    userLng: userLng ?? 0,
                  )));
                },
              ),
              _buildElevatedButton(
                label: 'Pure Veg',
                iconPath: 'assets/icons/vegsymbol.svg',
                backgroundColor: isdarkmode ? textBlack : textWhite,
                foregroundColor: isdarkmode ? textWhite : textBlack,
                borderColor: colorSuccess,
                onPressed: () {
                  Navigator.of(context)
                      .push(transitionToNextScreen(MyVegSearchBar(
                    restaurantsList: fetchAllRestaurantsModel!.restaurants!,
                    favoriteRestaurants: fetchFavouriteRestaurantsModel,
                    initialText: 'Pure Veg Items',
                  )));
                },
              ),
              _buildElevatedButton(
                label: '  Filters  ',
                iconPath: 'assets/icons/filter.svg',
                backgroundColor: primaryColor,
                foregroundColor: isdarkmode ? textBlack : textWhite,
                borderColor: primaryColor,
                onPressed: () {
                  showFilterModal(context,
                      restaurantsModel: fetchAllRestaurantsModel!,
                      onChanged: (value) => setState(() {}),
                      currentFilters: currentFilters);
                },
              ),
              _buildElevatedButton(
                label: '  Sort     ',
                iconPath: 'assets/icons/sort.svg',
                backgroundColor: isdarkmode ? textBlack : textWhite,
                foregroundColor: isdarkmode ? textWhite : textBlack,
                borderColor: primaryColor,
                onPressed: () async {
                  await showSortBottomSheet(
                      context, sortedRestaurantsModel!, currentSortSetting,
                      (value) {
                    currentSortSetting = value;
                  });
                  setState(() {});
                },
              ),
            ],
            FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: primaryColor,
              foregroundColor: isdarkmode ? textBlack : textWhite,
              child: CustomAnimatedIcon(animation: _animationController),
            ),
            const SizedBox(height: 25)
          ],
        ),
        body: RefreshIndicator(
          color: primaryColor,
          onRefresh: _loaddata,
          child: Container(
            child: SingleChildScrollView(
              // controller: _scrollController,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color.fromRGBO(
                              253, 235, 210, 1), // Light peach/beige at the top
                          isdarkmode
                              ? Colors.transparent
                              : textWhite, // White at the bottom // White at the bottom
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        CustomAppBar(
                          savedAs: savedas,
                          address: address,
                          onAddressSelected: changeLocation,
                        ),
                        SearchContainer(
                          fetchAllRestaurantsModel: fetchAllRestaurantsModel,
                          fetchFavouriteRestaurantsModel:
                              fetchFavouriteRestaurantsModel,
                        ),
                        Text(
                          greeting,
                          style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 19.sp),
                        ),
                        Text(
                          'Rise and Shine Its $foodtime',
                          style: TextStyle(color: primaryColor, fontSize: 8.sp),
                        ),
                        SizedBox(
                          height: 2.h,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      child: AdsSlider(),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 4.w),
                    child: sectionSlider(
                        'Favorite Merchants',
                        fetchFavouriteRestaurantsModel ?? [],
                        isFavouriteRestaurantsLoaded,
                        context),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      child: SectionGrid(
                        restaurantsList: fetchAllRestaurantsModel!.restaurants!,
                        favoriteRestaurants: fetchFavouriteRestaurantsModel,
                        headerText: 'Hey, What\'s on your mind?',
                        names: foodCategories,
                        images: foodImages,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    child: offersSlider('Created for you', offerData, context),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Text(
                        'Restaurants near me'.toUpperCase(),
                        style: isdarkmode
                            ? titleTextStyle.copyWith(
                                fontSize: 13.sp, color: textGrey2)
                            : titleTextStyle.copyWith(fontSize: 13.sp),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Text(
                        'Quick Delivery',
                        style: isdarkmode
                            ? h5TextStyle.copyWith(color: textGrey2)
                            : h5TextStyle,
                      ),
                    ),
                  ),
                  Container(
                    height: 28.h,
                    padding: EdgeInsets.only(top: 3.h, left: 2.w, bottom: 3.h),
                    child: isQuickDeliveryRestaurantsLoaded
                        ? restaurantSlider(
                            context,
                            restaurants: fetchQuickDeliveryRestaurantsModel!,
                            favoriteRestaurants:
                                fetchFavouriteRestaurantsModel ?? [],
                            userLat: userLat ?? 0,
                            userLng: userLng ?? 0,
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Text(
                        'Nearest Restaurants',
                        style: isdarkmode
                            ? h5TextStyle.copyWith(color: textGrey2)
                            : h5TextStyle,
                      ),
                    ),
                  ),
                  Container(
                    height: 28.h,
                    padding: EdgeInsets.only(top: 3.h, left: 2.w, bottom: 3.h),
                    child: isNearestRestaurantsLoaded
                        ? restaurantSlider(
                            context,
                            restaurants: fetchNearestRestaurantsModel!,
                            favoriteRestaurants:
                                fetchFavouriteRestaurantsModel ?? [],
                            userLat: userLat ?? 0,
                            userLng: userLng ?? 0,
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Text(
                        'Latest Restaurants',
                        style: isdarkmode
                            ? h5TextStyle.copyWith(color: textGrey2)
                            : h5TextStyle,
                      ),
                    ),
                  ),
                  Container(
                    height: 28.h,
                    padding: EdgeInsets.only(top: 3.h, left: 2.w, bottom: 3.h),
                    child: isLatestRestaurantsLoaded
                        ? restaurantSlider(
                            context,
                            restaurants: fetchLatestRestaurantsModel!,
                            favoriteRestaurants:
                                fetchFavouriteRestaurantsModel ?? [],
                            userLat: userLat ?? 0,
                            userLng: userLng ?? 0,
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  Padding(
                    padding: EdgeInsets.all(1.h),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(transitionToNextScreen(
                              const OnTimePromisePage()));
                        },
                        child: Image.asset('assets/images/ontimebanner.png')),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2.h, bottom: 1.h),
                    child: Divider(
                      color: textGrey3,
                      thickness: 0.2.h,
                      indent: 3.w,
                      endIndent: 3.w,
                    ),
                  ),
                  isAllRestaurantsLoaded
                      ? BuildAllRestaurantListWidget(
                          currentFilters: currentFilters,
                          fetchAllRestaurantsModel: sortedRestaurantsModel!,
                          favouriteRestaurantsList:
                              fetchFavouriteRestaurantsModel ?? [],
                          userLat: userLat ?? 0,
                          userLng: userLng ?? 0,
                          navigator: _navigator,
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                  // Padding(
                  //   padding: EdgeInsets.only(bottom: 2.h),
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       Text(
                  //         'ALL RESTAURANTS',
                  //         style: titleTextStyle,
                  //         textAlign: TextAlign.center,
                  //       ),
                  //       Text(
                  //         '${restaurantNames.length} Restaurants delivering to you',
                  //         style: body5TextStyle.copyWith(color: textGrey2),
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Container(
                  //   margin: EdgeInsets.symmetric(horizontal: 3.w),
                  //   child: ListView.builder(
                  //     shrinkWrap: true,
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     itemCount: restaurantNames.length,
                  //     itemBuilder: (context, index) {
                  //       if (index == restaurantNames.length) {
                  //         {
                  //           return Column(
                  //             children: [
                  //               restaurant(context, restaurantNames[index]),
                  //               const CircularProgressIndicator(),
                  //             ],
                  //           );
                  //         }
                  //       } else {
                  //         return restaurant(context, restaurantNames[index]);
                  //       }
                  //     },
                  //   ),
                  // ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class SearchContainer extends StatefulWidget {
  const SearchContainer({
    super.key,
    required this.fetchAllRestaurantsModel,
    required this.fetchFavouriteRestaurantsModel,
  });

  final FetchAllRestaurantsModel? fetchAllRestaurantsModel;
  final List<Restaurants>? fetchFavouriteRestaurantsModel;

  @override
  State<SearchContainer> createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  Timer? _timer;
  List<String> cuisines = [
    "Indian",
    "Thai",
    "South Indian",
    "Italian",
    "Chinese"
  ];
  late String barText;

  @override
  void initState() {
    super.initState();
    barText = 'What are you looking for? "${getRandomCuisine()}"';
    _timer = Timer.periodic(
        const Duration(seconds: 2), (Timer t) => _updateCuisineText());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String getRandomCuisine() {
    final random = Random();
    return cuisines[random.nextInt(cuisines.length)];
  }

  void _updateCuisineText() {
    setState(() {
      barText = 'What are you looking for? "${getRandomCuisine()}"';
    });
  }

  void routsearchscreen() {
    Navigator.of(context).push(transitionToNextScreen(MySearchBar(
      restaurantsList: widget.fetchAllRestaurantsModel!.restaurants!,
      favoriteRestaurants: widget.fetchFavouriteRestaurantsModel,
    )));
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: GestureDetector(
        onTap: () {
          routsearchscreen();
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          width: 96.w,
          padding: EdgeInsets.only(left: 4.w),
          // child: searchBar(barText, searchController,
          //     (String text) {}, context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  barText,
                  softWrap: false,
                  style: body4TextStyle.copyWith(
                      color: isdarkmode
                          ? textGrey2
                          : const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      routsearchscreen();
                      print('Search button pressed');
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/search_icon.svg',
                      color: textBlack,
                      height: 2.5.h,
                    ),
                  ),
                  Text(
                    '|',
                    style: TextStyle(color: textBlack, fontSize: 3.h),
                  ),
                  IconButton(
                    onPressed: routsearchscreen,
                    icon: SvgPicture.asset(
                      'assets/icons/microphone_icon.svg',
                      color: primaryColor,
                      height: 2.5.h,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
