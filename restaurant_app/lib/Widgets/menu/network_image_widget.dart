import 'package:flutter/material.dart';

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
    _loadImage();
  }

  void _loadImage() {
    final image = NetworkImage(widget.imageUrl);
    final ImageStream stream = image.resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (mounted) {
            setState(() {
              _status = ImageStatus.success;
            });
          }
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          if (mounted) {
            setState(() {
              _status = ImageStatus.error;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case ImageStatus.loading:
        return _buildLoading();
      case ImageStatus.success:
        return _buildImage();
      case ImageStatus.error:
        return _buildError();
    }
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildImage() {
    return Image.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover, // Adjust as per your needs
    );
  }

  Widget _buildError() {
    return Center(
      child: Icon(
        Icons.image,
        size: widget.width / 2,
        color: Colors.grey,
      ),
    );
  }
}
