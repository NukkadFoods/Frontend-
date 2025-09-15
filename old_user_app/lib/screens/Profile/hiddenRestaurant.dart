import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/Widgets/customs/Food/allRestaurants.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/show_snack_bar_extension.dart';
import 'package:user_app/widgets/constants/strings.dart';

class HiddenRestaurants extends StatefulWidget {
  const HiddenRestaurants({super.key});

  @override
  State<HiddenRestaurants> createState() => _HiddenRestaurantsState();
}

class _HiddenRestaurantsState extends State<HiddenRestaurants> {
  UserModel? userModel;
  bool isUserInfoLoaded = false;
  List<Restaurants> hiddenRestaurants = [];

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    setState(() {
      isUserInfoLoaded = false;
      hiddenRestaurants = [];
    });
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    var userResult =
        await UserController.getUserById(context: context, id: userId);
    userResult.fold((String text) {
      setState(() {
        isUserInfoLoaded = true;
        // context.showSnackBar(message: text);
      });
    }, (UserModel user) {
      setState(() {
        userModel = user;
        hiddenRestaurants = userModel!.user!.hiddenrestaurants?? [];
        isUserInfoLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
     bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
       
        title: Text('Hidden Restaurants', style: h4TextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack)),
        centerTitle: true,
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: !isUserInfoLoaded
              ? const Center(child: CircularProgressIndicator())
              : hiddenRestaurants.isEmpty && isUserInfoLoaded
                  ?  Text('No Hidden Restaurants',style: TextStyle(color: isdarkmode ? textGrey2: textBlack),)
                  : ListView.separated(
                      itemBuilder: (context, index) => restaurant(
                        context: context,
                        restaurantModel: hiddenRestaurants[index],
                        isFavourite: userModel!
                                .user!.favoriteRestaurants!.isEmpty
                            ? false
                            : userModel!.user!.favoriteRestaurants!.contains(
                                hiddenRestaurants[index],
                              ),
                        userLng: userModel!.user!.addresses![0].longitude ?? 0,
                        userLat: userModel!.user!.addresses![0].latitude ?? 0,
                      ),
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 2.h),
                      itemCount: hiddenRestaurants.length,
                    )),
    );
  }
}
