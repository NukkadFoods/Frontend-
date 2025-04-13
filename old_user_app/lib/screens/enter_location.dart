
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
// import 'package:http/http.dart' as http;
import 'package:user_app/widgets/customs/toasts.dart' as toast;
import 'package:user_app/widgets/input_fields/textInputField.dart';

class EnterLocation extends StatefulWidget {
  const EnterLocation({super.key, required this.isAdd});
  final bool isAdd;
  @override
  State<StatefulWidget> createState() {
    return _EnterLocationState();
  }
}

class _EnterLocationState extends State<EnterLocation> {
  TextEditingController housenocontroller = TextEditingController();
  TextEditingController apartmentcontroller = TextEditingController();
  TextEditingController colonycontroller = TextEditingController();
  TextEditingController reachcontroller = TextEditingController();
  TextEditingController saveascontroller = TextEditingController();
  UserModel? user;
  String? number;
  String? name;
  String? email;
  String? geneder;
  double? latitude;
  double? longitude;
  // Object? reference;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getPhoneNumber(); // Call the method to get the phone number
  }

  Future<void> getPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');
    name = prefs.getString('UserName');
    email = prefs.getString('UserEmail');
    geneder = prefs.getString('gender');
    latitude = prefs.getDouble('latitude');
    longitude = prefs.getDouble('longitude');
    // reference = jsonDecode(prefs.getString('refer'));
    print(name);
    print(number);
    print(email);
    print(geneder);
    // print(reference); // Retrieve the stored phone number
  }

  Future<void> userSignUp() async {
    // Validate inputs
    if (housenocontroller.text.isEmpty ||
        apartmentcontroller.text.isEmpty ||
        reachcontroller.text.isEmpty ||
        saveascontroller.text.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Please enter all details',
          backgroundColor: textWhite,
          textColor: primaryColor);
      return; // Exit the function if validation fails
    }

    // Validate location
    if (latitude == null || longitude == null) {
      Fluttertoast.showToast(
          msg: 'Please allow location access and select current location',
          backgroundColor: textWhite,
          textColor: primaryColor,
          toastLength: Toast.LENGTH_LONG);
      return; // Exit the function if validation fails
    }

    setState(() {
      isLoading = true;
    });

    String userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    var userResult =
        await UserController.getUserById(context: context, id: userId);

    userResult.fold((String text) {}, (UserModel userModel) {
      user = userModel;
    });

    try {
      // String baseUrl = dotenv.env['BASE_URL'];
      // String baseUrl = SharedPrefsUtil().getString('base_url')!;

      // Request data
      var reqData = {
        "username": name,
        "email": email,
        // "contact": number,
        "password": 'nopassword', // Securely handle passwords
        "addresses": [
          {
            "address":
                "${housenocontroller.text}, ${apartmentcontroller.text}, ${colonycontroller.text} ,${reachcontroller.text}",
            "latitude": latitude,
            "longitude": longitude,
            "area": apartmentcontroller.text,
            "hint": reachcontroller.text,
            "saveAs": saveascontroller.text,
          }
        ],
        "gender": geneder,
        "userImage": "www.image.com",
        // "referredby": reference, // Replace with actual image URL or buffer data
      };

      final result = await UserController.updateUserById(
          id: userId, updateData: reqData, context: context);
      result.fold((_) {
        toast.Toast.showToast(message: _, isError: true);
      }, (UserModel userModel) {
        final newData = user!.user!.toJson();
        newData.addAll(reqData);
        user!.user = User.fromJson(newData);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop(user!);
      });
      // Encode request body
      // String requestBody = jsonEncode(reqData);
      // print('$reqData');
      // // Send POST request
      // final response = await http.post(
      //   Uri.parse('$baseUrl/auth/userSignUp'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //   },
      //   body: requestBody,
      // );
      // print(response.body);
      // // Check for success
      // if (response.statusCode == 200) {
      //   final responseData = jsonDecode(response.body);
      //   print(response.statusCode);
      //   print(response.body);
      //   // Check if executed field is true
      //   if (responseData != null && responseData['executed']) {
      //     Fluttertoast.showToast(
      //         msg: 'Signup Successful. Please Login.',
      //         backgroundColor: textWhite,
      //         textColor: colorSuccess);
      //     Navigator.popUntil(context, (route) => route.isFirst);
      //   } else {
      //     Fluttertoast.showToast(
      //         msg: 'Something went wrong',
      //         backgroundColor: textWhite,
      //         textColor: primaryColor);
      //   }
      // } else {
      //   // Handle non-200 responses
      //   Fluttertoast.showToast(
      //       msg: 'Something went wrong',
      //       backgroundColor: textWhite,
      //       textColor: primaryColor);
      // }
    } catch (e) {
      // Handle network or API exceptions
      Fluttertoast.showToast(
          msg: 'Network Error or Server Issue',
          backgroundColor: textWhite,
          textColor: primaryColor,
          gravity: ToastGravity.CENTER);
      // } finally {
      //   setState(() {
      //     isLoading = false; // Reset loading state after request completes
      //   });
    }
  }

  void addAddress() async {
    // Validate inputs
    if (housenocontroller.text.isEmpty ||
        apartmentcontroller.text.isEmpty ||
        reachcontroller.text.isEmpty ||
        saveascontroller.text.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Please enter all details',
          backgroundColor: textWhite,
          textColor: primaryColor);
      return; // Exit the function if validation fails
    }

    // Validate location
    if (latitude == null || longitude == null) {
      Fluttertoast.showToast(
          msg: 'Please allow location access and select current location',
          backgroundColor: textWhite,
          textColor: primaryColor,
          toastLength: Toast.LENGTH_LONG);
      return; // Exit the function if validation fails
    }

    setState(() {
      isLoading = true;
    });
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";

    var userResult =
        await UserController.getUserById(context: context, id: userId);

    userResult.fold((String text) {}, (UserModel userModel) {
      setState(() {
        user = userModel;
      });
    });

    // Get existing addresses
    // List<Map<String, dynamic>> existingAddresses = user!.user!.addresses!
    //     .map((address) => {
    //           'address': address.address,
    //           'latitude': address.latitude,
    //           'longitude': address.longitude,
    //           'area': address.area,
    //           'hint': address.hint,
    //           'saveAs': address.saveAs,
    //         })
    //     .toList();
    List<Map<String, dynamic>> existingAddresses = [];
    for (Address address in user!.user!.addresses!) {
      if (!(address.area == 'temp' && address.hint == "temp")) {
        existingAddresses.add({
          'address': address.address,
          'latitude': address.latitude,
          'longitude': address.longitude,
          'area': address.area,
          'hint': address.hint,
          'saveAs': address.saveAs,
        });
      }
    }
    // if (existingAddresses.isEmpty) {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   await prefs.setString('CurrentAddress',
    //       "${housenocontroller.text}, ${apartmentcontroller.text}, ${colonycontroller.text} ,${reachcontroller.text}");
    //   await prefs.setString('CurrentSaveAs', saveascontroller.text);
    //   await prefs.setDouble('CurrentLatitude', latitude!);
    //   await prefs.setDouble('CurrentLongitude', longitude!);
    // }
    // Create new address
    Map<String, dynamic> newAddress = {
      'address':
          "${housenocontroller.text}, ${apartmentcontroller.text}, ${colonycontroller.text} ,${reachcontroller.text}",
      'latitude': latitude,
      'longitude': longitude,
      'area': apartmentcontroller.text,
      'hint': reachcontroller.text,
      'saveAs': saveascontroller.text, // unique name for the new address
    };

    // Append the new address to the existing addresses list
    existingAddresses.add(newAddress);

    // Prepare the update data
    Map<String, dynamic> updateData = {
      'addresses': existingAddresses,
    };

    // Call the update method
    await UserController.updateUserById(
      id: userId,
      updateData: updateData,
      context: context,
    );
    Fluttertoast.showToast(
        msg: 'Address Added ..!!',
        backgroundColor: textWhite,
        textColor: colorSuccess);
    setState(() {
      isLoading = false;
    });
    // Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.of(context).pop();
    Navigator.of(context).pop(Address.fromJson(newAddress));
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allows the layout to resize when the keyboard is visible
      body: SingleChildScrollView(
        child: Container(
          height: 100.h,
          width: 100.h,
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover, // Ensures the background image fits the screen
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back, size: 30),
                  ),
                  Text(
                    'Add Address',
                    style: TextStyle(
                      color: isdarkmode ? textWhite : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
              const SizedBox(height: 40),
              textInputField('House Flat no.', housenocontroller, (value) {
                print(value);
              }, context),

              const SizedBox(height: 40),
              textInputField('apartment / road / area', apartmentcontroller,
                  (value) {
                print(value);
              }, context),
              const SizedBox(height: 40),
              textInputField('Colony (optional) and Pincode', colonycontroller,
                  (value) {
                print(value);
              }, context),
              const SizedBox(height: 40),
              textInputField('How to reach. (LandMark)', reachcontroller,
                  (value) {
                print(value);
              }, context),
              const SizedBox(height: 40),
              textInputField('Save as.', saveascontroller, (value) {
                print(value);
              }, context, capitalization: TextCapitalization.sentences),
              const SizedBox(height: 40),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: primaryColor,
                    ))
                  : mainButton('Submit', textWhite, () {
                      widget.isAdd ? addAddress() : userSignUp();
                    }),
              const SizedBox(
                  height: 20), // Additional space at the bottom for scrolling
            ],
          ),
        ),
      ),
    );
  }
}
