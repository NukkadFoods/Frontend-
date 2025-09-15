import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/auth_provider.dart';
import 'package:sizer/sizer.dart';

typedef OnFilePicked = void Function(bool isPicked, String? imageUrl);

Widget uploadWidget({
  required BuildContext context, // Add context as a required parameter
  required OnFilePicked onFilePicked,
  Widget? child,
}) {
  return GestureDetector(
    onTap: () async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'pdf', 'png'],
        );

        if (result != null) {
          File file = File(result.files.single.path!);
          String fileName = file.path.split('/').last;

          showDialog(
            context: context,
            barrierDismissible: false, // Prevent user from dismissing
            builder: (BuildContext context) => Dialog(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Uploading..."),
                  ],
                ),
              ),
            ),
          );

          await authProvider.signInWithEmailAndPassword();

          firebase_storage.Reference ref = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child('images/$fileName');

          firebase_storage.UploadTask uploadTask = ref.putFile(file);

          uploadTask.then((firebase_storage.TaskSnapshot snapshot) async {
            Navigator.pop(context); // Close the dialog

            String downloadUrl = await snapshot.ref.getDownloadURL();
            onFilePicked(true, downloadUrl);
            print('Download URL: $downloadUrl');
          }).catchError((error) {
            Navigator.pop(context); // Close the dialog

            print('Firebase Storage Error: $error');
            onFilePicked(false, null);
          });
        } else {
          // User canceled the picker
          onFilePicked(false, null);
          print('User canceled the file picking');
        }
      } catch (e) {
        print('File picking error: $e');
      }
    },
    child: child ??
        Container(
          height: 15.h,
          width: 15.h,
          padding: EdgeInsets.all(5.h),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(
              color: Colors.grey[400]!,
              style: BorderStyle.solid,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            height: 4.h,
            width: 4.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: SvgPicture.asset(
              'assets/icons/add_icon.svg',
              height: 3.h,
            ),
          ),
        ),
  );
}