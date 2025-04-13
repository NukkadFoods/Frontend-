import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:sizer/sizer.dart';

typedef OnFilePicked = void Function(bool isPicked, String? imageUrl);

class CropImageWidget extends StatefulWidget {
  final BuildContext context;
  final String type;
  final String? imageUrl;
  final ValueChanged<String?> onFilePicked;
  final VoidCallback onDelete;

  CropImageWidget({
    required this.context,
    required this.type,
    this.imageUrl,
    required this.onFilePicked,
    required this.onDelete,
  });

  @override
  _CropImageWidgetState createState() => _CropImageWidgetState();
}

class _CropImageWidgetState extends State<CropImageWidget> {
  String? _uploadedImageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            if (_uploadedImageUrl == null) {
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'png'],
                );

                if (result != null) {
                  File file = File(result.files.single.path!);

                  // Crop the image
                  CroppedFile? croppedFile = await ImageCropper().cropImage(
                    sourcePath: file.path,
                    aspectRatio: CropAspectRatio(ratioX: 7, ratioY: 3),
                    uiSettings: [
                      AndroidUiSettings(
                        toolbarTitle: 'Crop Image',
                        toolbarColor: Colors.deepOrange,
                        toolbarWidgetColor: Colors.white,
                        lockAspectRatio: false,
                      ),
                      IOSUiSettings(
                        title: 'Crop Image',
                      ),
                    ],
                  );

                  if (croppedFile != null) {
                    File finalImageFile = File(croppedFile.path);
                    String fileName = finalImageFile.path.split('/').last;

                    // Show progress dialog
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

                    // Upload the cropped file to Firebase Storage
                    firebase_storage.Reference ref = firebase_storage
                        .FirebaseStorage.instance
                        .ref()
                        .child('images/$fileName');

                    firebase_storage.UploadTask uploadTask = ref.putFile(finalImageFile);

                    uploadTask.then((firebase_storage.TaskSnapshot snapshot) async {
                      Navigator.pop(context); // Close the dialog

                      String downloadUrl = await snapshot.ref.getDownloadURL();
                      setState(() {
                        _uploadedImageUrl = downloadUrl;
                      });
                      widget.onFilePicked(downloadUrl);
                    }).catchError((error) {
                      Navigator.pop(context); // Close the dialog
                      print('Firebase Storage Error: $error');
                      widget.onFilePicked(null);
                    });
                  } else {
                    widget.onFilePicked(null);
                    print('Cropping canceled');
                  }
                } else {
                  widget.onFilePicked(null);
                  print('User canceled the file picking');
                }
              } catch (e) {
                print('File picking error: $e');
                widget.onFilePicked(null);
              }
            }
          },
          child: _uploadedImageUrl == null
              ? Container(
                  height: 20.h,
                  width: 100.w,
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
                
                  child: Column(
                    children: [
                      Image.network(
                        _uploadedImageUrl!,
                        height: 20.h,
                        width: 100.w,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${widget.type} Uploaded!',
                        style: TextStyle(color: Colors.green),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _uploadedImageUrl = null;
                          });
                          widget.onDelete();
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
