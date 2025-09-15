import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/screens/authentication_screens/profile_screen.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:driver_app/widgets/common/loading_popup.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:driver_app/widgets/constants/shared_preferences.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/material.dart';
import 'city_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, this.isRegistering = true});
  final bool isRegistering;

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? selectedCity;
  List<String> cities = [];
  bool _isLoading = false;
  bool loadingCities = true;

  @override
  void initState() {
    getCities();
    super.initState();
  }

  void getCities() async {
    // final String baseurl = dotenv.env['BASE_URL']!;
    final String baseurl = AppStrings.baseURL;
    try {
      final response = await http.get(Uri.parse('$baseurl/city/getAllCities'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        for (var cityData in responseData) {
          cities.add(cityData['cityName']);
        }
        if (cities.isNotEmpty) {
          selectedCity = cities[0];
        }
      }
    } catch (e) {
      Toast.showToast(message: 'Error loading Cities', isError: true);
    }
    loadingCities = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _changeCity() async {
    final city = await showModalBottomSheet(
      useSafeArea: false,
      context: context,
      builder: (context) => CitySelectionScreen(
        cities: cities,
        selectedCity: selectedCity,
      ),
    );
    if (city != null) {
      setState(() {
        selectedCity = city;
      });
    }
  }

  Future<void> saveUserInfoKeyValue(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoStr = prefs.getString('user_info');
    Map<String, dynamic> userInfo = {};
    if (userInfoStr != null) {
      userInfo = jsonDecode(userInfoStr);
    }
    userInfo[key] = value;
    await prefs.setString('user_info', jsonEncode(userInfo));
    print('Updated user info: ${jsonEncode(userInfo)}');
  }

  // Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String userInfoStr = jsonEncode(userInfo); // Convert Map to JSON string
  //   await prefs.setString('user_info', userInfoStr); // Store JSON string
  //   print('Stored user info: $userInfoStr');
  // }

  void _handleLocation() async {
    if (_isLoading) {
      return; // Prevent multiple clicks
    }

    setState(() {
      _isLoading = true;
    });

    if (selectedCity != null) {
      await saveUserInfoKeyValue("city", selectedCity);

      Navigator.of(context).push(
        transitionToNextScreen(ProfileScreen()),
      );
    } else {
      Toast.showToast(message: 'Please select city', isError: true);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> update() async {
    if (selectedCity == null) {
      return false;
    }
    showLoadingPopup(context, "Updating...");
    final baseUrl = AppStrings.baseURL;
    String uid = SharedPrefsUtil().getString('uid')!;
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/auth/updateDeliveryBoyById'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'id': uid,
                'updateData': {'city': selectedCity}
              }));
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        final temp = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'deliveryBoyData', jsonEncode(temp['deliveryBoy']));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loadingCities
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/buildings.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // SizedBox(
                //   height: 20,
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Which city would you like to work in?',
                    style: TextStyle(
                      color: colorGreen,
                      fontSize: extraLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Deliver food in your nearby location',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: medium,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  // width: 180,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: colorLightGray,
                      )),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/locpin.png'),
                      TextButton(
                        onPressed: _changeCity,
                        child: Text(
                          selectedCity == null
                              ? '  Choose City'
                              : '  $selectedCity',
                          style: TextStyle(
                              fontSize: medium, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FullWidthGreenButton(
                      label: 'CONTINUE',
                      onPressed: () async {
                        if (widget.isRegistering) {
                          _handleLocation();
                        } else {
                          bool updated = await update();
                          if (updated) {
                            Navigator.of(context).pop(true);
                          } else {
                            Toast.showToast(
                                message: 'Something went wrong', isError: true);
                          }
                        }
                      },
                      isLoading: _isLoading,
                    )),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: _changeCity,
                  child: Text(
                    'Change City?',
                    style: TextStyle(
                      color: colorGreen,
                      fontSize: mediumSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 30,
                // )
              ],
            ),
    );
  }
}
