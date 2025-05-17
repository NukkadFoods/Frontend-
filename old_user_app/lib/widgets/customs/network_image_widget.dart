import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';
// import 'package:user_app/widgets/constants/colors.dart';

enum ImageStatus {
  loading,
  success,
  error,
}

class NetworkImageWidget extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 100,
    this.height = 100,
  });

  @override
  _NetworkImageWidgetState createState() => _NetworkImageWidgetState();
}

class _NetworkImageWidgetState extends State<NetworkImageWidget> {
  // late ImageStatus _status;
  String finalUrl = '';

  @override
  void initState() {
    super.initState();
    finalUrl = widget.imageUrl;
  }

  void getFirebaseUrl() async {
    if (widget.imageUrl.contains('firebasestorage')) {
      finalUrl = await FirebaseStorage.instance
          .refFromURL(widget.imageUrl)
          .getDownloadURL();
    } else {
      finalUrl = widget.imageUrl;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: finalUrl,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildError(),
      errorWidget: (context, url, error) {
        if (url.isNotEmpty) {
          getFirebaseUrl();
        }
        return _buildError();
      },
    );
  }

  // Widget _buildLoading() {
  //   return const Center(
  //     child: CircularProgressIndicator(
  //       color: primaryColor,
  //     ),
  //   );
  // }

  // Widget _buildSuccess(ImageProvider imageProvider) {
  //   return Container(
  //     width: widget.width,
  //     height: widget.height,
  //     decoration: BoxDecoration(
  //       image: DecorationImage(
  //         image: imageProvider,
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(0.2.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/images/restaurantImage.png',
            fit: BoxFit.cover,
            height: widget.height,
            width: widget.width,
          ),
        ),
      ),
    );
  }
}
