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
    this.initialText, // Optional text from the previous screen
  });

  final List<Restaurants> restaurantsList;
  final List<Restaurants>? favoriteRestaurants;
  final String? initialText; // Optional parameter

  @override
  State<MySearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<MySearchBar> {
  String search = '';
  List<Map<String, String>> result = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      controller.text =
          widget.initialText!; // Set initial text to the controller
      search = widget.initialText!;
      result = AllMenu.items.where((item) {
        return item['itemName']!.contains(widget.initialText!.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            searchBar("What are you looking for?", controller, (value) {
              search = value;
              result.clear();
              result.addAll(AllMenu.items.where((item) {
                return item['itemName']!.contains(value.toLowerCase());
              }));
              setState(() {});
            }, context, showBackButton: true, text: widget.initialText),
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
                            imageUrl: result[index]['imageUrl'] ?? '',
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
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white54
                                  : Colors.black54,
                              fontSize: 12),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              )
            else if (search.isNotEmpty && result.isEmpty)
              const Expanded(
                child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          "Oops! Currently none of our Nukkads are serving this dish",
                          textAlign: TextAlign.center),
                    )),
              )
          ],
        ),
      ),
    );
  }
}

Widget searchBar(String barText, TextEditingController controller,
    Function(String)? onChanged, BuildContext context,
    {bool showBackButton = false, String? text}) {
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  Future<bool> checkPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

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
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void startListening() async {
    bool permissionGranted = await checkPermission();
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
          controller.text = val.recognizedWords;
          if (onChanged != null) {
            onChanged(val.recognizedWords);
          }
        });
      }
    } else {
      showPermissionDialog(context);
    }
  }

  void stopListening() {
    speech.stop();
  }

  if (text != null && text.isNotEmpty) {
    controller.text = text; // Set the text if provided
  }

  return Container(
    height: 7.h,
    margin: EdgeInsets.fromLTRB(2.w, 2.h, 2.w, 0),
    child: TextField(
      style: TextStyle(color: isdarkmode ? textGrey2 : textBlack),
      autofocus: showBackButton,
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: isdarkmode ? textGrey2 : Colors.black,
          ),
        ),
        hintText: barText,
        contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.h),
        hintStyle: body4TextStyle.copyWith(
          color: const Color.fromARGB(255, 0, 0, 0),
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
                  stopListening();
                } else {
                  startListening();
                }
                isListening = !isListening;
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
