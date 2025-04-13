import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';

class RateAndComplaintPage extends StatefulWidget {
  final String restaurantId;
  final String orderid;

  const RateAndComplaintPage({super.key, required this.restaurantId, required this.orderid});

  @override
  _RateAndComplaintPageState createState() => _RateAndComplaintPageState();
}

class _RateAndComplaintPageState extends State<RateAndComplaintPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController complaintController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
  bool isLoading = false;
  final _auth = FirebaseAuth.instance;
  String _complaintType = 'Restaurant';
  String dboyId=''; // Default selected value
  @override
  void initState() {
    super.initState();
    getdeliveryboyid();
    if (_auth.currentUser == null) {
      createUser();
      print('User not logged in logging in...');
      login();
    } else {
      print('user already logged in...');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> createUser() async {
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '$userId@gmail.com',
        password: 'firebase',
      );
      print('User created successfully');
    } catch (e) {
      print('Error: $e');
    }
  }

  void login() async {
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: '$userId@gmail.com', password: 'firebase');
      print('logged in to Firebase');
    } catch (e) {
      print('Login error in firebase');
    }
    // _user = userCredential.user;
  }

  void getdeliveryboyid()async{
    final data = await FirebaseFirestore.instance
      .collection('tracking')
      .doc(widget.orderid)
      .get();
  
  // Fetch and store the dboyId from the Firestore document
  dboyId = data.data()?['dBoyId'];
  
  // Debug print to verify the fetched dboyId
  print('Delivery Boy ID: $dboyId');
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('complaint_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to upload image: $e',
        backgroundColor: textWhite,
        textColor: primaryColor,
      );
      return null;
    }
  }

String generateUniqueId() {
  // Get today's date in DDMMYY format
  final String todayDate = DateFormat('ddMMyy').format(DateTime.now());

  // Keep the rest of the string structure intact
  final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

  // Generate a 5-digit random string
  final String randomString = List.generate(5, (index) => Random().nextInt(10)).join();

  // Replace the first 6 digits of the timestamp with today's date
  final String updatedTimestamp = todayDate + timestamp.substring(6);

  // Return the formatted unique ID
  return '$updatedTimestamp-$randomString';
}
  Future<void> addComplaint() async {
    setState(() {
      isLoading = true;
    });

    String title = titleController.text;
    String descriptionText = complaintController.text;

    // Upload image if selected
    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImageToFirebase(_selectedImage!);
      if (imageUrl == null) {
        setState(() {
          isLoading = false; // Stop loading if image upload failed
        });
        return; // Don't proceed if image upload failed
      }
    }

    // Determine the role based on the selected complaint type
    String role = _complaintType == 'Driver' ? 'Rider' : 'Restaurant';
    String complaintagainstid=_complaintType =='Driver' ? dboyId : widget.restaurantId;
    // Construct the description JSON
    String description = json.encode({
      'title': title,
      'description': descriptionText,
      'image': imageUrl,
    });

    final url = Uri.parse('${AppStrings.baseURL}/complaint/addComplaint');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'ID': generateUniqueId(),
      'role': 'by user',
      'status': 'Processing',
      'orderID': widget.orderid,
      'description': description,
      "complaint_done_by_id": userId,
      "complaint_done_by_role": "User", 
      "complaint_done_against_id": complaintagainstid,
      "complaint_done_against_role": role, 
      "title": title,  
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
          msg: 'Complaint registered. Actions will be taken...!!',
          backgroundColor: textWhite,
          textColor: primaryColor,
          gravity: ToastGravity.CENTER,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to submit. Try again later...!!',
          backgroundColor: textWhite,
          textColor: primaryColor,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Something went wrong...!!',
        backgroundColor: textWhite,
        textColor: primaryColor,
      );
      print(e);
    } finally {
      setState(() {
        isLoading = false; // Stop loading in both success and failure cases
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add the radio buttons for complaint type selection
          Text('Complaint Against',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,color: isdarkmode ? textGrey2: textBlack)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _complaintType = 'Restaurant';
                    });
                  },
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Restaurant',
                        groupValue: _complaintType,
                        activeColor: primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _complaintType = value!;
                          });
                        },
                      ),
                      SizedBox(width: 1.w), // Adjust width as needed
                      Text(
                        'Restaurant',
                        style: TextStyle(fontSize: 12.sp,color: isdarkmode ? textGrey2: textBlack),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _complaintType = 'Driver';
                    });
                  },
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Driver',
                        groupValue: _complaintType,
                        activeColor: primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _complaintType = value!;
                          });
                        },
                      ),
                      SizedBox(width: 1.w), // Adjust width as needed
                      Text(
                        'Driver',
                        style: TextStyle(fontSize: 12.sp,color: isdarkmode ? textGrey2: textBlack),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text('Submit a Complaint',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,color: isdarkmode? textGrey2: textBlack)),
          SizedBox(height: 2.h),
          TextField(
            style: TextStyle(color: isdarkmode? textGrey2: textBlack),
            controller: titleController,
            maxLength: 25,
            decoration: const InputDecoration(
              labelText: 'Complaint Title',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            style: TextStyle(color: isdarkmode? textGrey2: textBlack),
            controller: complaintController,
            decoration: const InputDecoration(
              labelText: 'Complaint Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 2.h),
          // Button to pick an image
          Row(
            children: [
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: isdarkmode ? textGrey1 : textWhite),
                onPressed: _pickImage,
                child:
                    const Text('Upload Image', style: TextStyle(color: primaryColor)),
              ),
              SizedBox(width: 2.w),
              // Display the selected image if available
              _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      height: 10.h,
                      width: 10.h,
                      fit: BoxFit.cover,
                    )
                  : const Text('No image selected'),
            ],
          ),
          SizedBox(height: 2.h),
          isLoading
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : mainButton('Submit Complaint', textWhite, () {
                  if (titleController.text.isNotEmpty &&
                      complaintController.text.isNotEmpty) {
                    addComplaint();
                  } else {
                    Fluttertoast.showToast(
                      msg:
                          'Please enter a title and description for the complaint',
                      backgroundColor: textWhite,
                      textColor: primaryColor,
                    );
                  }
                }),
        ],
      ),
    );
  }
}
