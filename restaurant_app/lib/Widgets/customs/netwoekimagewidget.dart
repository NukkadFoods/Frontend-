import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:sizer/sizer.dart';


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
    Key? key,
    required this.imageUrl,
    this.width = 100,
    this.height = 100,
  }) : super(key: key);

  @override
  _NetworkImageWidgetState createState() => _NetworkImageWidgetState();
}

class _NetworkImageWidgetState extends State<NetworkImageWidget> {
  late ImageStatus _status;

  @override
  void initState() {
    super.initState();
    _status = ImageStatus.loading;
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildError(),
      errorWidget: (context, url, error) => _buildError(),
      imageBuilder: (context, imageProvider) => _buildSuccess(imageProvider),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: primaryColor,
      ),
    );
  }

  Widget _buildSuccess(ImageProvider imageProvider) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

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
