import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import '../../constants/colors.dart';
import '../../constants/texts.dart';

class MenuSearchBar extends StatefulWidget {
  // Add a callback function to the constructor
  final Function(String) onTextChanged;

  const MenuSearchBar({super.key, required this.onTextChanged});

  @override
  State<MenuSearchBar> createState() => _MenuSearchBarState();
}

class _MenuSearchBarState extends State<MenuSearchBar> {
  // Speech-to-text instance
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _searchText = ''; // Holds the recognized text

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText(); // Initialize the speech recognizer
  }

  // Function to check and request microphone permission
  Future<bool> _requestPermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      // If permission is denied, request permission
      status = await Permission.microphone.request();
    }
    return status.isGranted; // Return true if permission is granted
  }

  // Function to start or stop listening
  void _listen() async {
    // Check for microphone permission
    bool hasPermission = await _requestPermission();
    if (!hasPermission) {
      print("Microphone permission not granted");
      return; // Exit if permission is not granted
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        Fluttertoast.showToast(
          msg: 'Listening...',
          textColor: colorSuccess,
          backgroundColor: textWhite,
          gravity: ToastGravity.CENTER,
        );
        _speech.listen(
          onResult: (val) => setState(() {
            _searchText = val.recognizedWords; // Update the search text
            widget.onTextChanged(_searchText); // Send the recognized text to the parent
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop(); // Stop listening
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(253, 253, 247, 247),
      padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 2.h),
      child: Container(
        margin: EdgeInsets.fromLTRB(2.w, 2.h, 2.w, 0),
        child: TextField(
          controller: TextEditingController(text: _searchText), // Display recognized text
          onChanged: (text) {
            _searchText = text;
            widget.onTextChanged(text); // Send the entered text to the parent
          },
          decoration: InputDecoration(
            hintText: 'Search items or categories',
            contentPadding: EdgeInsets.symmetric(vertical: 1.h),
            hintStyle: body4TextStyle.copyWith(color: const Color(0xFF7E7E7E)),
            prefixIcon: IconButton(
              onPressed: () {
                print('Search button pressed');
              },
              icon: SvgPicture.asset(
                'assets/icons/search_icon.svg',
                color: textGrey2,
                height: 3.h,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: _listen, // Start speech-to-text on press
              icon: SvgPicture.asset(
                'assets/icons/microphone_icon.svg',
                color: primaryColor,
                height: 3.h,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: textGrey2, width: 0.2.h),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: textGrey2, width: 0.2.h),
            ),
          ),
        ),
      ),
    );
  }
}
