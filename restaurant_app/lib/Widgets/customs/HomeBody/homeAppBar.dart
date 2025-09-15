import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:restaurant_app/Controller/Profile/restaurant_model.dart';
import 'package:restaurant_app/Controller/subscription/subscription_resquest.dart';
import 'package:restaurant_app/Screens/AccessibilityTab/ads_page.dart';
import 'package:restaurant_app/Screens/AccessibilityTab/complain_page.dart';
import 'package:restaurant_app/Screens/AccessibilityTab/help_center.dart';
import 'package:restaurant_app/Screens/AccessibilityTab/nukkad_manager.dart';
import 'package:restaurant_app/Screens/AccessibilityTab/nukkad_settting.dart';
import 'package:restaurant_app/Screens/AccessibilityTab/payOuts.dart';
import 'package:restaurant_app/Screens/AccessibilityTab/promotions.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/toast.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../../../Screens/notificationScreen.dart';
import '../../constants/colors.dart';
import '../../constants/shared_preferences.dart';
import '../../constants/texts.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key, required this.restaurantModel, required this.onChanged});
  final RestaurantModel? restaurantModel;
  final VoidCallback onChanged;

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  late bool isNukkadOpen;
  String userid = '';
  GetSubscriptionModel? subscription;
  @override
  void initState() {
    super.initState();
    userid = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    fetchSubscription(context, userid);
    isNukkadOpen = widget.restaurantModel!.user!.isOpen;
  }

  void fetchSubscription(BuildContext context, String subscriptionId) async {
    subscription = await SubscribeController.getSubscriptionById(
      context: context,
      id: subscriptionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8.h,
      width: 100.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 40.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.restaurantModel!.user!.nukkadName ?? "",
                  style: h5TextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
                Text(
                  widget.restaurantModel!.user!.nukkadAddress ?? "",
                  style: body5TextStyle.copyWith(
                    fontSize: 9.sp,
                    color: textGrey2,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 25.w,
            height: 4.5.h,
            child: GestureDetector(
              onTap: () async {
                Toast.showToast(
                    message:
                        "${isNukkadOpen ? "Closing" : "Opening"} your Nukkad");
                try {
                  await LoginController.updateIsOpen(
                      isOpen: !isNukkadOpen,
                      uid: widget.restaurantModel!.user!.id!);
                  setState(() {
                    isNukkadOpen = !isNukkadOpen;
                  });
                  widget.restaurantModel!.user!.isOpen = isNukkadOpen;
                } catch (e) {
                  Toast.showToast(
                      message: e is http.ClientException
                          ? "Can't Update, Unstable Internet"
                          : e.toString(),
                      isError: true);
                }
                widget.onChanged();
              },
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: isNukkadOpen ? textGrey2 : colorSuccess,
                  ),
                  child: Center(
                    child: Text(
                      isNukkadOpen ? 'CLOSE' : 'OPEN',
                      style: h5TextStyle.copyWith(
                        color: textWhite,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  transitionToNextScreen(
                    const NotificationScreen(),
                  ),
                );
              },
              child: Icon(
                Icons.notifications_outlined,
                color: textBlack,
                size: 22.sp,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    //Scrolling given for content in Container()
                    return SingleChildScrollView(
                        child: Container(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Container(
                                width: 100.w,
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    topLeft: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Accessibility",
                                      style: body3TextStyle.copyWith(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Card.outlined(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: IconButton(
                                                  color: Colors.red,
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      transitionToNextScreen(
                                                          PromotionsPage()),
                                                    );
                                                  },
                                                  icon: Image.asset(
                                                      'assets/images/promotions.png'),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "Promotions",
                                              style: body6TextStyle,
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Card.outlined(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: IconButton(
                                                  color: Colors.red,
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      transitionToNextScreen(
                                                          AdsPage()),
                                                    );
                                                  },
                                                  icon: Image.asset(
                                                      'assets/images/Group.png'),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "Ads",
                                              style: body6TextStyle,
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Card.outlined(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: IconButton(
                                                  color: Colors.red,
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      transitionToNextScreen(
                                                          ComplaintsWidget()),
                                                    );
                                                  },
                                                  icon: Image.asset(
                                                      'assets/images/iconCarrier.png'),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "Complains",
                                              style: body6TextStyle,
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Card.outlined(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: IconButton(
                                                  color: Colors.red,
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      transitionToNextScreen(
                                                          HelpCenterWidget()),
                                                    );
                                                  },
                                                  icon: Image.asset(
                                                      'assets/images/helpcenter.png'),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "Help Center",
                                              style: body6TextStyle,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Column(
                                        //   children: [
                                        //     Card.outlined(
                                        //       child: Padding(
                                        //         padding:
                                        //             const EdgeInsets.all(5.0),
                                        //         child: IconButton(
                                        //           color: Colors.red,
                                        //           onPressed: () {
                                        //             Navigator.push(
                                        //               context,
                                        //               transitionToNextScreen(
                                        //                   subscription == null
                                        //                       ? GetSubscription()
                                        //                       : ActiveSubscriptionScreen(
                                        //                           subscription:
                                        //                               subscription)),
                                        //             );
                                        //           },
                                        //           icon: Image.asset(
                                        //               'assets/images/subs.png'),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //     Text(
                                        //       'Subscription',
                                        //       style: body6TextStyle,
                                        //     )
                                        //     // Text("Subscription")
                                        //   ],
                                        // ),
                                        Column(
                                          children: [
                                            Card.outlined(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: IconButton(
                                                  color: Colors.red,
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      transitionToNextScreen(
                                                          NukkadManagerWidget()),
                                                    );
                                                  },
                                                  icon: Image.asset(
                                                      'assets/images/persion_manager.png'),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Manager',
                                              style: body6TextStyle,
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Card.outlined(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: IconButton(
                                                  color: Colors.red,
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      transitionToNextScreen(
                                                          PayOutsWidget()),
                                                    );
                                                  },
                                                  icon: Image.asset(
                                                      'assets/images/payOut.png'),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Payouts',
                                              style: body6TextStyle,
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Card.outlined(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: IconButton(
                                                  color: Colors.red,
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      transitionToNextScreen(
                                                          NukkadSettingWidget()),
                                                    );
                                                  },
                                                  icon: Image.asset(
                                                      'assets/images/setting.png'),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Setting',
                                              style: body6TextStyle,
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ))));
                  });
            },
            child: Icon(
              Icons.menu,
              color: textBlack,
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }
}
