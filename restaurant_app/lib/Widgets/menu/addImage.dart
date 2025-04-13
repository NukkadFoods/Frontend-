import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/User/uploadwidgets.dart';
import 'package:sizer/sizer.dart';

class AddImage extends StatefulWidget {
   AddImage(
      {Key? key,
      required this.onFilePicked,
      required this.context,
      this.isImageUploaded = false,
      this.isOptional = true,
      this.imagePath})
      : super(key: key ?? const Key('default'));
  final OnFilePicked onFilePicked;
  final BuildContext context;
 bool? isImageUploaded;
  final String? imagePath;
  final bool isOptional;

  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  String _base64Image = '';

  void _handleFilePicked(bool isPicked, String? base64File) {
    if (isPicked && base64File != null) {
      setState(() {
        _base64Image = base64File;
      });
      // You can now send _base64Image to your backend or use it as needed
    }
  }

  void _deleteImage() {
    setState(() {
      widget.isImageUploaded = false; 
      print('uai;sqon  :${widget.imagePath}');// Assuming this is how you're managing uploaded images
      // Reset any relevant variables here if needed
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFCACACA))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isOptional ? 'Add Image (optional)' : 'Add Image',
            style: h5TextStyle,
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child:  widget.isImageUploaded!
                ? Column(
                    children: [
                      // Display the selected image from the URL
                      Image.network(
                        widget.imagePath!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text('Image failed to load'),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Image selected!',
                            style: body4TextStyle.copyWith(color: colorSuccess),
                          ),
                          SizedBox(width: 5.w),
                          IconButton(
                            onPressed: _deleteImage,
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  )
                : uploadWidget(
              onFilePicked: widget.onFilePicked, context: widget.context,
              // onTap: () async {
              //   // Use uploadWidget to pick a file
              //   uploadWidget(
              //       onFilePicked: widget.onFilePicked, context: widget.context);
              // },
              child: DottedBorder(
                strokeWidth: 2,
                dashPattern: [6, 3],
                borderType: BorderType.RRect,
                radius: Radius.circular(10),
                color: Color(0xFFB8B8B8),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    // border: Border.all(color: Color(0xFFB8B8B8)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
         
        ],
      ),
    );
  }
}
