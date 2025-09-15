import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart'
    as stt; // Import speech_to_text
import 'package:user_app/Controller/food/all_menu_item_controller.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/utils/extensions.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/network_image_widget.dart';

import '../../../screens/Restaurant/restaurantScreen.dart';

class MySearchBar extends StatefulWidget {
  const MySearchBar({
    super.key,
    required this.restaurantsList,
    this.favoriteRestaurants,
  });
  final List<Restaurants> restaurantsList;
  final List<Restaurants>? favoriteRestaurants;

  @override
  State<MySearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<MySearchBar> {
  String search = '';
  List<Map<String, String>> result = [];
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            searchBar("What are you looking for?", controller, (value) {
              search = value;
              result.clear();
              result.addAll(AllMenu.items.where((itemName) {
                return itemName['itemName']!.contains(value.toLowerCase());
              }));
              setState(() {});
            }, context, showBackButton: true),
            if (search.isNotEmpty && result.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(4),
                  itemCount: result.length,
                  itemBuilder: (context, index) {
                    int temp = widget.restaurantsList.indexWhere(
                        (value) => value.id! == result[index]['uid']);
                    if (temp >= 0) {
                      Restaurants restaurants = widget.restaurantsList[temp];
                      return ListTile(
                        dense: true,
                        minTileHeight: 0,
                        onTap: () async {
                          // Store restaurant latitude and longitude in shared preferences
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setDouble('restaurant_latitude',
                              restaurants.latitude?.toDouble() ?? 0);
                          await prefs.setDouble('restaurant_longitude',
                              restaurants.longitude?.toDouble() ?? 0);

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RestaurantScreen(
                                        restaurantID: restaurants.id ?? "",
                                        isFavourite: widget.favoriteRestaurants!
                                            .contains(restaurants),
                                        res: restaurants,
                                        restaurantName:
                                            restaurants.nukkadName ?? "",
                                      )));
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: NetworkImageWidget(
                            imageUrl: result[index]['imageUrl'] ?? "",
                            width: 12.w,
                            height: 12.w,
                          ),
                        ),
                        title: Text(
                          result[index]['itemName']!.capitalize(),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          restaurants.nukkadName!.capitalize(),
                          style:
                              const TextStyle(color: textGrey1, fontSize: 12),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}

Widget searchBar(String barText, TextEditingController controller,
    Function(String)? onChanged, BuildContext context,
    {bool showBackButton = false}) {
  FocusNode focusNode = FocusNode();
  bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  // Declare a SpeechToText instance
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;

  // Function to check and request microphone permission
  Future<bool> checkPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      // Request permission if it's not granted
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  // Function to show a dialog if permission is denied
  void showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Microphone Permission Required'),
          content: const Text(
              'Please enable microphone access to use voice search.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await openAppSettings(); // Open app settings for the user to enable the permission
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // Function to start listening for voice input
  void startListening() async {
    bool permissionGranted = await checkPermission(); // Check permission
    if (permissionGranted) {
      bool available = await speech.initialize();
      if (available) {
        Fluttertoast.showToast(
            msg: 'listening ......',
            backgroundColor: textWhite,
            textColor: textBlack,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP);
        speech.listen(onResult: (val) {
          controller.text =
              val.recognizedWords; // Set recognized text in the TextField
          if (onChanged != null) {
            onChanged(val
                .recognizedWords); // Call the onChanged function with recognized words
          }
        });
      }
    } else {
      // If permission is not granted, show the dialog
      showPermissionDialog(context);
    }
  }

  // Function to stop listening
  void stopListening() {
    speech.stop();
  }

  return Container(
    height: 7.h,
    margin: EdgeInsets.fromLTRB(2.w, 2.h, 2.w, 0),
    child: TextField(
      style: TextStyle(color: isdarkmode ? textGrey2 : textBlack),
      autofocus: showBackButton,
      focusNode: focusNode,
      onTapOutside: (event) => focusNode.unfocus(),
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: showBackButton
            ? InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                ),
              )
            : null, // Return null when showBackButton is false to hide the icon

        hintText: barText,

        contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.h),
        hintStyle: body4TextStyle.copyWith(
          color: isdarkmode ? textGrey2 : const Color.fromARGB(255, 0, 0, 0),
          fontSize: 13,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                // Search button pressed
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
              onPressed: () {
                if (isListening) {
                  stopListening(); // Stop listening if already listening
                } else {
                  startListening(); // Start listening for voice input
                }
                isListening = !isListening; // Toggle listening state
                // Microphone button pressed
              },
              icon: SvgPicture.asset(
                'assets/icons/microphone_icon.svg',
                color: primaryColor,
                height: 2.5.h,
              ),
            ),
          ],
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: textBlack, width: 0.1.h),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: textGrey2, width: 0.1.h),
        ),
        filled: true,
      ),
    ),
  );
}
