import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:user_app/widgets/constants/colors.dart';

class CustomAnimatedIcon extends StatefulWidget {
  final Animation<double> animation;

  const CustomAnimatedIcon({super.key, required this.animation});

  @override
  _CustomAnimatedIconState createState() => _CustomAnimatedIconState();
}

class _CustomAnimatedIconState extends State<CustomAnimatedIcon> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1),
      child: widget.animation.value == 1
          ? const Icon(Icons.close, key: ValueKey('close'),color: textWhite,)
          : SvgPicture.asset('assets/icons/fab.svg', key: const ValueKey('open'),color: textWhite,),
    );
  }
}
