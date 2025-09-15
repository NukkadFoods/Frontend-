import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/Controller/Profile/restaurant_model.dart';
import 'package:restaurant_app/Controller/ads_slider.dart';
import 'package:restaurant_app/Screens/User/login_screen.dart';
import 'package:restaurant_app/Screens/home/chart.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/HomeBody/analyticsData.dart';
import 'package:restaurant_app/Widgets/customs/HomeBody/homeAppBar.dart';
import 'package:restaurant_app/Widgets/customs/HomeBody/timeLineFilter.dart';
import 'package:restaurant_app/provider/report_provider.dart';
import 'package:sizer/sizer.dart';

import '../../Widgets/customs/pagetransition.dart';
import '../Wallet/viewEarningsScreen.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  String selectedFilter = 'Today';
  RestaurantModel? restaurantModel;
  bool showContainer = false;
  late ReportProvider provider;
  bool isOpen = true;

  @override
  void initState() {
    fetchRestaurantModel();
    super.initState();
    provider = ReportProvider(context: context);
  }

  void fetchRestaurantModel() {
    print('fetchRestaurantModel() called');

    String? restaurantJson =
        SharedPrefsUtil().getString(AppStrings.restaurantModel);
    print(restaurantJson);
    if (restaurantJson != null && restaurantJson.isNotEmpty) {
      restaurantModel = RestaurantModel.fromJson(json.decode(restaurantJson));
      checkIfOpen();
      // print(restaurantModel!.user!.operationalHours!.toJson());
      if (mounted) {
        setState(() {});
      }
    }
  }

  Map<String, dynamic> openingHours = {};
  void checkIfOpen() {
    var timing = restaurantModel!.user!.operationalHours;
    setState(() {
      print('Operational hours: ${timing!}');
      openingHours = timing as Map<String, dynamic>;
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
      if (currentTime.isAfter(open) && currentTime.isBefore(close)) {
        setState(() {
          isOpen = true;
        });
      } else {
        setState(() {
          isOpen = false;
        });
      }
    } else {
      setState(() {
        isOpen = false; // Closed if hours are null
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (restaurantModel!.user == null) {
        SharedPrefsUtil().remove(AppStrings.userId);
        SharedPrefsUtil().remove(AppStrings.userInfo);
        Navigator.of(context).pushAndRemoveUntil(
            transitionToNextScreen(const Login_Screen()),
            (route) => route.isFirst);
      }
    });
    return ChangeNotifierProvider<ReportProvider>(
      create: (context) => provider,
      builder: (context, child) => Scaffold(
        body: restaurantModel!.user == null
            ? Center(
                child: const CircularProgressIndicator(),
              )
            : Stack(children: [
                Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    top: 0,
                    child: Image.asset(
                      'assets/images/otpbg.png',
                      fit: BoxFit.cover,
                    )),
                SingleChildScrollView(
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          child: restaurantModel != null
                              ? HomeAppBar(
                                  restaurantModel: restaurantModel!,
                                  onChanged: () {
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                )
                              : SizedBox.shrink(),
                        ),
                        if (!(restaurantModel!.user!.isOpen && isOpen))
                          buildAlert(),
                        AdsSlider(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.h),
                          child: Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF47D3FF),
                                      Color(0xFF5A00CF)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      width: 2,
                                      color: const Color(
                                        0xFF5CC7FA,
                                      ))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer<ReportProvider>(
                                    builder: (context, value, child) => Text(
                                      'Sales : ${value.getBannerString()}',
                                      style: h3TextStyle.copyWith(
                                        color: textWhite,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Consumer<ReportProvider>(
                                    builder: (context, value, child) => Text(
                                      '₹ ${value.getBannerAmount()}',
                                      style: h2TextStyle.copyWith(
                                        color: const Color(0xffFAFF00),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Consumer<ReportProvider>(
                                    builder: (context, value, child) => Text(
                                      'This Week Sales : ₹ ${value.totalWeek.toStringAsFixed(2)}',
                                      style: h6TextStyle.copyWith(
                                          color: textWhite),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
                          child: Center(
                            child: Text(
                              'Sales Report',
                              style: h3TextStyle.copyWith(color: primaryColor),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: TimeLineFilter(
                            onFilterSelected: (String value) {
                              setState(() {
                                selectedFilter = value;
                                switch (value) {
                                  case "Today":
                                    context
                                        .read<ReportProvider>()
                                        .toggleChip(0);
                                    break;
                                  case "This Week":
                                    context
                                        .read<ReportProvider>()
                                        .toggleChip(1);
                                    break;
                                  case "This Month":
                                    context
                                        .read<ReportProvider>()
                                        .toggleChip(2);
                                    break;
                                }
                              });
                            },
                          ),
                        ),
                        showContainer
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        showContainer = false;
                                        setState(() {});
                                      },
                                      child: Text(
                                        'Back To Graph',
                                        style: TextStyle(
                                            color: primaryColor,
                                            decoration:
                                                TextDecoration.underline),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  )
                                ],
                              )
                            : SizedBox.shrink(),
                        Padding(
                          padding: showContainer
                              ? EdgeInsets.fromLTRB(2.h, 0.h, 2.h, 0.h)
                              : EdgeInsets.all(2.h),
                          child: showContainer
                              ? Padding(
                                  padding: EdgeInsets.only(top: 1.h),
                                  child: AnalyticsData(),
                                )
                              : Column(
                                  children: [
                                    Consumer<ReportProvider>(
                                        builder: (context, value, child) =>
                                            BarChartSample4(
                                              todayData: value.todayData,
                                              weeklyData: value.weeklyData,
                                              monthlyData: value.monthlyData,
                                              onToggle: () {
                                                // setState(() {
                                                //   showContainer = !showContainer;
                                                // });
                                                Navigator.of(context).push(
                                                    transitionToNextScreen(
                                                        const EarningScreen()));
                                              },
                                            )),
                                    SizedBox(
                                      height: 4.h,
                                    )
                                  ],
                                ),
                        ),

                        // Padding(
                        //   padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                        //   child: const AnalyticsData(),
                        // ),
                      ],
                    ),
                  ),
                ),
              ]),
      ),
    );
  }

  Widget buildAlert() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const Text(
                'Your Restaurant is not visible to our users since it is marked as Closed',
                style: TextStyle(color: Colors.white)),
            if (!restaurantModel!.user!.isOpen)
              Text(
                  'Press the "OPEN" button on this screen to Open your Nukkad and Receive Orders',
                  style: TextStyle(color: Colors.white))
            else
              Text(
                  "Please update the 'Opening Hours' from settings to mark your Nukkad as Open",
                  style: TextStyle(color: Colors.white))
          ],
        ),
      ),
    );
  }
}
