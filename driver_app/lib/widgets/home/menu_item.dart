import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuItem extends StatelessWidget {
  const MenuItem(
      {super.key,
      required this.iconPath,
      required this.label,
      required this.screen});

  final String iconPath;
  final String label;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(transitionToNextScreen(screen));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7.5),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                    border: Border.all(
                      width: 2,
                      color: colorLightGray,
                    )),
                padding: EdgeInsets.all(12),
                child: SvgPicture.asset(iconPath)),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          textAlign: TextAlign.center,
          label,
          style: TextStyle(
            fontSize: small,
          ),
        ),
      ],
    );
  }
}
