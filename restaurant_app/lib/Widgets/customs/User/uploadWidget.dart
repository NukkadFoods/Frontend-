import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/auth_provider.dart';
import 'package:sizer/sizer.dart';

typedef OnFilePicked = void Function(bool isPicked, String? imageUrl);
class UploadImageWidget extends StatefulWidget {
  final BuildContext context;
  final String type;
  final String? imageUrl;
  final ValueChanged<String?> onFilePicked;
  final VoidCallback onDelete;

  UploadImageWidget({
    required this.context,
    required this.type,
    this.imageUrl,
    required this.onFilePicked,
    required this.onDelete,
  });

  @override
  _UploadImageWidgetState createState() => _UploadImageWidgetState();
}

class _UploadImageWidgetState extends State<UploadImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            if (widget.imageUrl == null) {
              // Handle image selection and upload if no image URL exists
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'png'], // Adjust based on your needs
                );

                if (result != null) {
                  File file = File(result.files.single.path!);
                  String fileName = file.path.split('/').last;

                  // Show a progress dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
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

                  // Upload the file to Firebase Storage
                  firebase_storage.Reference ref = firebase_storage
                      .FirebaseStorage.instance
                      .ref()
                      .child('images/$fileName');

                  firebase_storage.UploadTask uploadTask = ref.putFile(file);

                  uploadTask.then((firebase_storage.TaskSnapshot snapshot) async {
                    Navigator.pop(context); // Close the dialog

                    String downloadUrl = await snapshot.ref.getDownloadURL();
                    widget.onFilePicked(downloadUrl);
                  }).catchError((error) {
                    Navigator.pop(context); // Close the dialog
                    print('Firebase Storage Error: $error');
                    widget.onFilePicked(null);
                  });
                } else {
                  // User canceled the picker
                  widget.onFilePicked(null);
                  print('User canceled the file picking');
                }
              } catch (e) {
                print('File picking error: $e');
                widget.onFilePicked(null);
              }
            }
          },
          child: widget.imageUrl == null
              ? Container(
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
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/add_icon.svg',
                      height: 8.h,
                      width: 8.h,
                    ),
                  ),
                )
              : Container(
                  padding: EdgeInsets.all(5.h),
                  child: Column(
                    children: [
                      Image.network(widget.imageUrl!,fit: BoxFit.fill),
                      SizedBox(height: 10),
                      Text(
                        '${widget.type} Uploaded!',
                        style: TextStyle(color: Colors.green),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
