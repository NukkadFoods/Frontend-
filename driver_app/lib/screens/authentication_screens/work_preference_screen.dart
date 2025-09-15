import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/screens/authentication_screens/work_preference_screen_two.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:driver_app/widgets/sigin_signup/work_area_container.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/colors.dart';
import '../../utils/font-styles.dart';
import 'dart:convert';

class WorkPreferenceScreen extends StatefulWidget {
  const WorkPreferenceScreen({super.key, this.isRegistering = true});
  final bool isRegistering;
  @override
  State<WorkPreferenceScreen> createState() => _WorkPreferenceScreenState();
}

class _WorkPreferenceScreenState extends State<WorkPreferenceScreen> {
  String? selectedArea;
  String? selectedDescription;
  Map<String, dynamic>? deliveryBoyData;
  List<Map<String, String>> areas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getAreas();
  }

  Future<void> getDeliveryBoyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? temp = prefs.getString('deliveryBoyData');
    if (temp != null) {
      deliveryBoyData = jsonDecode(temp);
      setState(() {});
    }
  }

  void getAreas() async {
    _isLoading = true;
    String? city;
    if (widget.isRegistering) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userInfoStr = prefs.getString('user_info');
      Map<String, dynamic> userInfo = {};
      if (userInfoStr != null) {
        userInfo = jsonDecode(userInfoStr);
        city = userInfo['city'].toString().trim();
      }
    } else {
      await getDeliveryBoyData();
      city = deliveryBoyData!['city'].toString().trim();
    }
    if (city != null) {
      // final String baseurl = dotenv.env['BASE_URL']!;
      // final String baseurl = AppStrings.baseURL;
      try {
        // final response =
        //     await http.get(Uri.parse('$baseurl/city/getAreasByCity/$city'));
        // if (response.statusCode == 200) {
        //   final responseData = jsonDecode(response.body);
        Map hubs = (await FirebaseFirestore.instance
                .collection('hubs')
                .doc('metadata')
                .get())
            .get(city.toLowerCase());
        for (var areaData in hubs.entries) {
          areas.add({
            'areaName': areaData.key.toString().trim().capitalize(),
            'description': (areaData.value['description'] ?? "No Description")
                .toString()
                .trim()
                .capitalize()
          });
          // }
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        print(e);
        _isLoading = false;
        if (mounted) {
          setState(() {});
        }

        Toast.showToast(
            message: e is http.ClientException
                ? 'No Internet'
                : 'Error loading Areas',
            isError: true);
      }
    }
  }

  Future<void> _saveWorkPreferences() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    if (selectedArea != null) {
      // await prefs.setString('locationName', selectedArea!);
      // await prefs.setString('description', selectedDescription!);
      await saveUserInfoKeyValue('locationName', selectedArea!);
      await saveUserInfoKeyValue('description', selectedDescription!);
    }
  }

  void _onAreaSelected(Map<String, String> selection) {
    setState(() {
      selectedArea = selection['area'];
      selectedDescription = selection['description'];
    });
  }

  Future<void> saveUserInfoKeyValue(String key, dynamic value) async {
    Map<String, dynamic> newData = {key: value};
    await saveUserInfo(newData);
  }

  Future<void> saveUserInfo(Map<String, dynamic> newData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoStr = prefs.getString('user_info');
    Map<String, dynamic> userInfo =
        userInfoStr != null ? jsonDecode(userInfoStr) : {};
    userInfo.addAll(newData);
    await prefs.setString('user_info', jsonEncode(userInfo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back_ios_rounded,
          ),
        ),
        title: const Text(
          'Work Preferences',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (widget.isRegistering)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorGreen,
                        border: Border.all(
                          width: 2,
                          color: colorGreen,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            fontSize: mediumSmall,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: 70,
                      color: colorGreen,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorGreen,
                        border: Border.all(
                          width: 2,
                          color: colorGreen,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Center(
                        child: Text(
                          '2',
                          style: TextStyle(
                            fontSize: mediumSmall,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: 70,
                      color: colorGreen,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: colorGreen,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            fontSize: mediumSmall,
                            color: colorGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (widget.isRegistering)
                const SizedBox(
                  height: 10,
                ),
              if (widget.isRegistering)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Personal\nInformation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: small,
                        color: colorGreen,
                      ),
                    ),
                    Text(
                      'Documentation',
                      style: TextStyle(
                        fontSize: small,
                        color: colorGreen,
                      ),
                    ),
                    Text(
                      'Work\nPreferences',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: small,
                        color: colorGreen,
                      ),
                    ),
                  ],
                ),
              if (widget.isRegistering)
                const SizedBox(
                  height: 30,
                ),
              const Text(
                'WORK AREA',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Select the area you want to work in'),
              const SizedBox(
                height: 30,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: widget.isRegistering
                        ? MediaQuery.of(context).size.height * .5
                        : MediaQuery.of(context).size.height * .6),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ListView.builder(
                        itemCount: areas.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: WorkAreaContainer(
                            area: areas[index]['areaName']!,
                            description: areas[index]['description']!,
                            selectedArea: selectedArea,
                            onAreaSelected: _onAreaSelected,
                          ),
                        ),
                      ),
              ),
              const SizedBox(
                height: 30,
              ),
              FullWidthGreenButton(
                  label: 'NEXT',
                  onPressed: () async {
                    await _saveWorkPreferences();
                    Navigator.of(context)
                        .push(transitionToNextScreen(WorkPreferenceScreenTwo(
                      isRegistering: widget.isRegistering,
                    )));
                  })
            ],
          ),
        ),
      ),
    );
  }
}
