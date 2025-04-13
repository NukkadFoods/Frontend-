import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/favorite_controller.dart';
import 'package:user_app/Controller/food/food_controller.dart';
import 'package:user_app/Controller/food/model/category_model.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/food/model/menu_model.dart';
import 'package:user_app/Controller/subscription_resquest.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/screens/Restaurant/cartScreen.dart';
import 'package:user_app/screens/Support/chatSupportScreen.dart';
import 'package:user_app/screens/registerScreen.dart';
import 'package:user_app/utils/extensions.dart';
import 'package:user_app/widgets/buttons/viewCartButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/Food/ratingWidget.dart';
import 'package:user_app/widgets/customs/Food/search.dart';
import 'package:user_app/widgets/customs/Restaurants/foodItemWidget.dart';
import 'package:user_app/widgets/customs/Restaurants/foodTypeToggle.dart';
import 'package:intl/intl.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:user_app/widgets/customs/toasts.dart' as toast;

class RestaurantScreen extends StatefulWidget {
  RestaurantScreen({
    super.key,
    required this.restaurantID,
    required this.isFavourite,
    required this.restaurantName,
    required this.res,
  });
  final String restaurantID;
  bool isFavourite;
  final String restaurantName;
  final Restaurants res;

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  List<bool> isFilterSelected = [false, false, false, false, false];
  int _cartCounter = 0;
  double _cartTotal = 0;
  bool _isFloatingContainerVisible = false;
  GlobalKey fabKey = GlobalKey();
  String openedTill = '';
  // List<bool> isMenuSelected = [false, false, false, false, false, false, false];
  List<bool> isMenuSelected = [];
  int selectedMenuIndex = -1;
  double freeDeliveryOver = 0;
  int selectedIndex = 0;

  bool isMenuLoaded = false;
  bool isCategoryLoaded = false;
  FullMenuModel? fullMenu;
  List<String> subCategoryNames = [];
  List<MenuItemModel> menuItemsList = [];
  Map<String, List<MenuItemModel>> menuItemsByCategory = {};
  List<CategoryModel> categories = [];
  List<String> categoriesName = [];
  List<String> subCategories = [];
  final Map<String, List<String>> subCategoryMap = {};
  List<MenuItemCategory> menuCategories = [];
  final TextEditingController searchController = TextEditingController();
  bool isFavouriteLoading = false;
  bool isOpen = false;

  // Sample response from the server
  Map<String, dynamic> openingHours = {};

  void toggleSelection(int index) {
    setState(() {
      isFilterSelected[index] = !isFilterSelected[index];
      filterMenuItem();
    });
  }

  filterMenuItem() {
    List<String> selectedLabels = [];
    menuItemsList = [];
    if (!isMenuSelected.contains(true)) {
      menuItemsByCategory.forEach((key, value) {
        menuItemsList.addAll(value);
      });
      if (isFilterSelected.contains(true)) {
        for (int i = 0; i < isFilterSelected.length; i++) {
          if (isFilterSelected[i] == true) {
            selectedLabels.add(AppStrings.lable[i]);
          }
        }
        // i want that any menu item which lable is in selected label to be added to it
        menuItemsList = menuItemsList.where((element) {
          return selectedLabels.contains(element.label);
        }).toList();
      }
    } else {
      menuItemsList = menuItemsByCategory[
          menuItemsByCategory.keys.toList()[isMenuSelected.indexOf(true)]]!;
      if (isFilterSelected.contains(true)) {
        for (int i = 0; i < isFilterSelected.length; i++) {
          if (isFilterSelected[i] == true) {
            selectedLabels.add(AppStrings.lable[i]);
          }
        }
        // i want that any menu item which lable is in selected label to be added to it
        menuItemsList = menuItemsList.where((element) {
          return selectedLabels.contains(element.label);
        }).toList();
      }
    }
    if (searchController.text.isNotEmpty) {
      menuItemsList = menuItemsList.where((element) {
        return element.menuItemName!
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  onChangedSearch(String text) {
    filterMenuItem();
  }

  void updateCartCounter(bool isAdd) {
    setState(() {
      if (isAdd) {
        _cartCounter++;

        // _cartTotal += price;
      } else {
        _cartCounter--;
        // _cartTotal -= price;
      }
      SharedPrefsUtil().setInt(AppStrings.cartItemCountKey, _cartCounter);
    });
  }

  void updateCartPrice(double price) {
    setState(() {
      _cartTotal += price;
    });
    if (_cartTotal < freeDeliveryOver &&
        0 < _cartTotal &&
        SubscribeController.subscription == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          backgroundColor: primaryColor,
          content: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Cart Updated",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  "Add Items worth ₹ ${freeDeliveryOver - _cartTotal} to get Free Delivery",
                  style: const TextStyle(color: Colors.white, height: 1.5),
                )
              ],
            ),
          )));
    }
    SharedPrefsUtil().setDouble(AppStrings.cartItemTotalKey, _cartTotal);
  }

  void handleMenuSelection(int index) {
    setState(() {
      if (selectedMenuIndex == index) {
        isMenuSelected[index] = false;
        selectedMenuIndex = -1;
      } else {
        if (selectedMenuIndex != -1) {
          isMenuSelected[selectedMenuIndex] = false;
        }
        isMenuSelected[index] = true;
        selectedMenuIndex = index;
      }

      filterMenuItem();
    });
  }

  routeCart() async {
    if (userModel!.user!.addresses![0].hint == "temp") {
      toast.Toast.showToast(message: "Please Enter details to proceed");
      final user = await Navigator.of(context)
          .push(transitionToNextScreen(const RegistrationScreen()));
      if (user is! UserModel) {
        return;
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'CurrentAddress', user.user!.addresses![0].address!);
        await prefs.setString(
            'CurrentSaveAs', user.user!.addresses![0].saveAs!);
        await prefs.setDouble(
            'CurrentLatitude', user.user!.addresses![0].latitude!);
        await prefs.setDouble(
            'CurrentLongitude', user.user!.addresses![0].longitude!);
        userModel = user;
      }
    }
    if (_cartTotal < 70) {
      toast.Toast.showToast(
          message:
              "Minimum cart Total should be greater than ₹ 70 to place order",
          isError: true);
      return;
    }
    Navigator.push(
        context,
        transitionToNextScreen(
          CartScreen(
            updateCartCounter: updateCartCounter,
            updateCartPrice: updateCartPrice,
            restaurantname: widget.restaurantName,
            restaurantUID: widget.restaurantID,
            restaurant: widget.res,
            menuItems: menuItemsList,
          ),
        ));
  }

  void didPopNext() {
    // super.didPopNext();
    // Refresh data when returning to this screen
    getUserInfo();
    getMenu();
  }

  UserModel? userModel;
  bool isUserInfoLoaded = false;
  void getUserInfo() async {
    setState(() {
      isUserInfoLoaded = false;
    });

    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    var userResult =
        await UserController.getUserById(context: context, id: userId);

    userResult.fold((String text) {
      // Handle the error case
      isUserInfoLoaded = true;
      _cartCounter = 0;
      // context.showSnackBar(message: text);
      if (mounted) {
        setState(() {});
      }
    }, (UserModel user) {
      // Prepare the data
      var cartTotalQuantity =
          user.user!.getCartTotalQuantityForRestaurant(widget.restaurantID);
      var cartTotal = user.user!.getCartTotalForRestaurant(widget.restaurantID);

      // Update the state
      isUserInfoLoaded = true;
      userModel = user;
      _cartCounter = cartTotalQuantity;
      _cartTotal = cartTotal;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isOpen = widget.res.isOpen ?? false;
    getUserInfo();
    getMenu();
    checkIfOpen();
  }

  void checkIfOpen() {
    var timing = widget.res.operationalHours;
    var isopen = widget.res.isOpen ?? false;
    setState(() {
      print('Operational hours: ${timing!.toJson()}');
      openingHours = timing.toJson();
    });

    var now = DateTime.now();
    var dayOfWeek = DateFormat('EEEE').format(now);

    // Fetch the opening and closing hours for the current day
    String? hours = openingHours[dayOfWeek];

    if (hours != null) {
      // Split hours into opening and closing time
      List<String> times = hours.split(' - ');
      String openingTime = times[0];
      String closingTime = times[1];

      // Parse opening and closing times with the current date
      DateTime open = DateFormat.jm().parse(openingTime);
      DateTime close = DateFormat.jm().parse(closingTime);

      // Adjust open and close to the current date
      open = DateTime(now.year, now.month, now.day, open.hour, open.minute);
      close = DateTime(now.year, now.month, now.day, close.hour, close.minute);

      // Handle overnight closing times
      if (close.isBefore(open)) {
        close = close.add(
            const Duration(days: 1)); // Add a day if it closes after midnight
      }

      var currentTime = DateTime.now();
      print(close.difference(currentTime).inMinutes);
      if (close.difference(currentTime).inMinutes < 61) {
        openedTill = "Opened till $closingTime";
      }

      if (currentTime.isAfter(open) && currentTime.isBefore(close) && isopen) {
        setState(() {
          isOpen = true;
        });
      } else {
        setState(() {
          isOpen = false;
          final openingDays = openingHours.keys.toList();
          String nextDay = openingDays[
              (openingDays.indexOf(dayOfWeek) + 1) % openingDays.length];
          openedTill =
              "It will open by $nextDay ${openingHours[nextDay].split(" - ")[0]}";
          Fluttertoast.showToast(
              msg: 'Restaurant Is Closed ...!!',
              backgroundColor: textWhite,
              textColor: primaryColor);
        });
      }
    } else {
      //we will open by
      if (openingHours.length == 1) {
        openedTill =
            "It will open by ${openingHours.keys.first} ${openingHours.values.first.split(" - ")[0]}";
      } else {
        final days = openingHours.keys.toList();
        String day = "";
        for (int i = 1; i < 7; i++) {
          final temp = DateFormat('EEEE').format(now.add(Duration(days: i)));
          if (days.contains(temp)) {
            day = temp;
            break;
          }
        }
        if (day.isNotEmpty) {
          openedTill =
              "It will open by $day ${openingHours[day].split(" - ")[0]}";
        }
      }
      setState(() {
        isOpen = false;
        Fluttertoast.showToast(
            msg: 'Restaurant Is Closed ...!!',
            backgroundColor: textWhite,
            textColor: primaryColor); // Closed if hours are null
      });
    }
  }

  Future<void> getMenu() async {
    freeDeliveryOver = SubscribeController.subscription != null
        ? (context
                    .read<GlobalProvider>()
                    .constants['premiumFreeDeliveryOver'] ??
                context.read<GlobalProvider>().freeDeliveryOver)
            .toDouble()
        : context.read<GlobalProvider>().freeDeliveryOver;
    setState(() {
      subCategoryNames = [];
      menuItemsList = [];
      menuItemsByCategory = {};
      categories = [];
      categoriesName = [];
      subCategories = [];
      isMenuLoaded = false;
      isCategoryLoaded = false;
      isMenuSelected = [];
    });

    var result = await FoodController.getMenuItems(
      context: context,
      uid: widget.restaurantID,
    );

    result.fold(
      (String errorMessage) {
        if(mounted){

        setState(() {
          isMenuLoaded = true;
          isCategoryLoaded = true;
        });
        }
        Fluttertoast.showToast(
            msg: errorMessage,
            backgroundColor: textWhite,
            textColor: primaryColor);
      },
      (dynamic menuModel) {
        if (menuModel is FullMenuModel) {
          fullMenu = menuModel;
          _processFullMenu();
          categories = fullMenu!.menuItems!
              .map((item) => CategoryModel(
                    category: item.category!,
                    categoryImg: item.categoryImg!,
                  ))
              .toSet()
              .toList();
          categoriesName = fullMenu!.menuItems!
              .map((item) => item.category!)
              .toSet()
              .toList();
          subCategories = fullMenu!.menuItems!
              .expand((item) => item.subCategory!)
              .map((subItem) => subItem.subCategoryName!)
              .toSet()
              .toList();
          isMenuSelected = List.generate(
              fullMenu!.menuItems!
                  .map((item) => item.category!)
                  .toSet()
                  .toList()
                  .length,
              (index) => false);
          menuCategories = List.generate(
              menuItemsByCategory.length,
              (index) => MenuItemCategory(
                  name: menuItemsByCategory.keys.toList()[index],
                  itemCount: menuItemsByCategory[
                          menuItemsByCategory.keys.toList()[index]]!
                      .length));
          menuItemsByCategory.forEach((key, value) {
            menuItemsList.addAll(value);
          });
        } else {
          Fluttertoast.showToast(
              msg: 'Something went wrong..!!',
              backgroundColor: textWhite,
              textColor: primaryColor);
        }

        isMenuLoaded = true;
        isCategoryLoaded = true;
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void _processFullMenu() {
    if (fullMenu!.menuItems != null) {
      for (var menuItem in fullMenu!.menuItems!) {
        if (menuItem.category != null && menuItem.subCategory != null) {
          String category = menuItem.category!;
          subCategoryMap[category] = [];
          subCategoryMap[category]!.addAll(menuItem.subCategory!.isEmpty
              ? []
              : menuItem.subCategory!.map((subCategory) =>
                  subCategory.subCategoryName!.isEmpty
                      ? ""
                      : subCategory.subCategoryName!));
          if (!menuItemsByCategory.containsKey(category)) {
            menuItemsByCategory[category] = [];
          }
          menuItemsByCategory[category]!.addAll(menuItem.subCategory!
              .expand((subCategory) => subCategory.menuItems!));
        }
      }
      categoriesName = menuItemsByCategory.keys.toList();
      // getSubAndMenuItemCategoryNames(menuItems: fullMenu!);
    }
  }

  void favouriteHandler() async {
    setState(() {
      isFavouriteLoading = true;
    });
    if (widget.isFavourite) {
      var result = await FavoriteController.removeFavorite(
          uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
          favorite: widget.restaurantID);
      result.fold((String error) {
        setState(() {
          isFavouriteLoading = false;
          Fluttertoast.showToast(
              msg: ' $error',
              backgroundColor: textWhite,
              textColor: colorSuccess);
        });
      }, (String success) {
        setState(() {
          widget.isFavourite = !widget.isFavourite;
          isFavouriteLoading = false;
          Fluttertoast.showToast(
              msg: ' $success',
              backgroundColor: textWhite,
              textColor: colorSuccess);
        });
      });
    } else {
      var result = await FavoriteController.addFavorite(
          uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
          favorite: widget.restaurantID);
      result.fold((String error) {
        setState(() {
          isFavouriteLoading = false;
          Fluttertoast.showToast(
              msg: 'Something went wrong ...!',
              backgroundColor: textWhite,
              textColor: primaryColor);
        });
      }, (String success) {
        setState(() {
          widget.isFavourite = !widget.isFavourite;
          isFavouriteLoading = false;
          Fluttertoast.showToast(
              msg: success,
              backgroundColor: textWhite,
              textColor: colorSuccess);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: _buildAppBarWidget(isOpen),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.7,
            child: Image.asset('assets/images/background.png',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover),
          ),

          _buildCategoryAndMenuRowWidget(isdarkmode),
          if (_isFloatingContainerVisible)
            _buildFloatingActionContainer(isdarkmode),
          // Place the Positioned widget for the view cart button outside the SingleChildScrollView
          Positioned(
            bottom: 1.h,
            left: 1.w,
            right: 1.w,
            child: Center(
              child: _cartCounter > 0 && isUserInfoLoaded && isOpen
                  ? viewCartButton(
                      _cartCounter, routeCart, _cartTotal, isdarkmode)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(isdarkmode),
    );
  }

  PreferredSizeWidget _buildAppBarWidget(bool isopen) => AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new)),
        actions: [
          isFavouriteLoading
              ? Text(!widget.isFavourite ? 'Adding...' : 'Removing...')
              : IconButton(
                  onPressed: favouriteHandler,
                  icon: widget.isFavourite
                      ? const Icon(
                          Icons.favorite_rounded,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border_rounded,
                          color: textGrey1,
                        ),
                ),
          isopen
              ? IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                )
              : TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(transitionToNextScreen(ChatSupportScreen()));
                  },
                  child: Text('Help',
                      style: h6TextStyle.copyWith(color: primaryColor)),
                )
        ],
        centerTitle: true,
      );
  Widget _buildFloatingActionButton(isdarkmode) => Padding(
        padding:
            EdgeInsets.only(right: 1.w, bottom: _cartCounter > 0 ? 7.h : 1.h),
        child: SizedBox(
          height: 5.h,
          // width: 23.w,
          child: FloatingActionButton.extended(
            key: fabKey,
            backgroundColor:
                _isFloatingContainerVisible ? Colors.black : primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: () {
              setState(() {
                _isFloatingContainerVisible = !_isFloatingContainerVisible;
              });
            },
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isFloatingContainerVisible
                    ? const Icon(
                        Icons.close,
                        applyTextScaling: true,
                        color: Colors.white,
                      )
                    : SvgPicture.asset('assets/icons/menu.svg',
                        color: isdarkmode ? textBlack : textGrey2),
                SizedBox(width: 1.w),
                Text(
                  _isFloatingContainerVisible ? 'Cancel' : "MENU",
                  style: h6TextStyle.copyWith(
                      color: _isFloatingContainerVisible
                          ? textWhite
                          : isdarkmode
                              ? textBlack
                              : Colors.white,
                      fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ),
      );
  Widget _buildFloatingActionContainer(isdarkmode) =>
      _isFloatingContainerVisible
          ? Positioned(
              bottom: -(fabKey.currentContext!.findRenderObject()! as RenderBox)
                      .localToGlobal(
                          Offset(0, -MediaQuery.sizeOf(context).height))
                      .dy +
                  10,
              right: 4.w,
              child: Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * .4),
                width: MediaQuery.sizeOf(context).width * .4,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: isdarkmode ? textGrey1 : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: menuCategories.isNotEmpty && isCategoryLoaded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int index = 0;
                                  index < menuCategories.length;
                                  index++)
                                Container(
                                  margin: const EdgeInsets.all(5),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex =
                                            index; // Update selectedIndex when a menu category is tapped
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            menuCategories[index]
                                                .name
                                                .replaceAll("_", " ")
                                                .capitalize(),
                                            style: TextStyle(
                                                color: index == selectedIndex
                                                    ? Colors.red
                                                    : Colors.grey,
                                                fontWeight:
                                                    index == selectedIndex
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                fontSize: 14.sp,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ),
                                        Text(
                                          '${menuCategories[index].itemCount}',
                                          style: TextStyle(
                                            color: index == selectedIndex
                                                ? Colors.red
                                                : Colors.grey,
                                            fontWeight: index == selectedIndex
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : !isMenuLoaded
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : const Center(
                                child: Text(AppStrings.noCategoriesFound),
                              ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink();

  Widget _buildCategoryAndMenuRowWidget(bool isdarkmode) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
            child: isOpen
                ? Container(
                    margin: EdgeInsets.only(left: 1.w, right: 1.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: textGrey3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(10),
                        child: Opacity(
                          opacity: isOpen ? 1 : 0.5, // Grayscale when closed
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              widget.restaurantName,
                                              style: h5TextStyle.copyWith(
                                                  color: isdarkmode
                                                      ? textGrey2
                                                      : textBlack),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          Lottie.asset(
                                              'assets/animations/restaurant.json',
                                              height: 4.h,
                                              width: 8.w),
                                        ],
                                      ),
                                    ),
                                    ratingWidget(widget.res.getAverageRating()),
                                  ],
                                ),
                                Text(
                                  ' ${widget.res.distanceFromUser}, ${widget.res.city}',
                                  style: h6TextStyle.copyWith(
                                      color: isdarkmode ? textGrey2 : textGrey1,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 9.sp),
                                ),
                                // if (openedTill.isNotEmpty)
                                Text(openedTill,
                                    style: TextStyle(
                                        fontSize: 8.sp,
                                        color: isdarkmode
                                            ? textGrey2
                                            : textBlack)),
                                Divider(
                                  thickness: 0.1.h,
                                  indent: 5,
                                  endIndent: 10,
                                  color: textGrey1,
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/distance.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    Flexible(
                                      child: Text(
                                        '  ${widget.res.distanceFromUser}',
                                        style: body5TextStyle.copyWith(
                                            color: isdarkmode
                                                ? textGrey2
                                                : textBlack,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    Text(
                                      '  Free delivery on orders above ${freeDeliveryOver.toInt()}',
                                      style: body5TextStyle.copyWith(
                                          color: isdarkmode
                                              ? textGrey2
                                              : textBlack),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )),
                  )
                : Column(
                    children: [
                      Text(
                        'Sorry Restaurant is not accepting orders at this time\n$openedTill',
                        style: h4TextStyle.copyWith(color: primaryColor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: 30.h,
                          width: 80.w,
                          child: SvgPicture.asset(
                            'assets/icons/closed.svg',
                          ))
                    ],
                  ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: searchBar('Search in ${widget.restaurantName}',
                searchController, onChangedSearch, context,
                showBackButton: false),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: foodTypeToggle(toggleSelection, isFilterSelected, context),
          ),
          isMenuLoaded && isCategoryLoaded && menuItemsList.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: menuItemsList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == menuItemsList.length) {
                        return SizedBox(
                            height: 70 +
                                (_cartCounter > 0 && isUserInfoLoaded && isOpen
                                    ? 5.8.h
                                    : 0));
                      }
                      return Opacity(
                        opacity: isOpen && menuItemsList[index].inStock!
                            ? 1
                            : 0.5, // Grayscale when closed
                        child: FoodItemWidget(
                            updateCartCounter: (value) {
                              updateCartCounter(value);
                            }, // Implement your logic
                            menuItem: menuItemsList[index],
                            restaurantId:
                                widget.restaurantID, // Example restaurant ID
                            updateCartPrice:
                                updateCartPrice, // Implement your logic
                            isOpen: isOpen && menuItemsList[index].inStock!,
                            cart:
                                userModel == null ? [] : userModel!.user!.cart),
                      );
                    },
                  ),
                )
              : !isMenuLoaded || !isCategoryLoaded
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : Center(
                      child: Text(
                        'No Items Found',
                        style: TextStyle(
                            color: isdarkmode ? textWhite : textBlack),
                      ),
                    ),
        ],
      );
}
