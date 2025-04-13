import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';

class OrderTypeSelector extends StatefulWidget {
  final Function(bool) onOrderTypeChanged;
  const OrderTypeSelector({super.key, required this.onOrderTypeChanged});

  @override
  State<OrderTypeSelector> createState() => _OrderTypeSelectorState();
}

class _OrderTypeSelectorState extends State<OrderTypeSelector> {
  bool _isDelivery = true;

  @override
  Widget build(BuildContext context) {
     bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 6.h,
            width: 40.w,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isDelivery = true;
                });
                widget.onOrderTypeChanged(_isDelivery);
              },
              icon: SvgPicture.asset(
                'assets/icons/delivering_icon.svg',
                height: 3.h,
                color: _isDelivery ? Colors.white :isdarkmode ? primaryColor : primaryColor,
              ),
              label: Text(
                'Delivery',
                style: h6TextStyle.copyWith(
                    color: _isDelivery ? Colors.white :isdarkmode ?primaryColor: primaryColor),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: _isDelivery ?  Colors.white  : primaryColor ,
                backgroundColor: _isDelivery ? primaryColor :isdarkmode ? const Color.fromARGB(149, 37, 36, 36): Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 1.5.w,
          ),
          SizedBox(
            height: 6.h,
            width: 40.w,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isDelivery = false;
                });
                widget.onOrderTypeChanged(_isDelivery);
              },
              icon: SvgPicture.asset(
                'assets/icons/takeaway_icon.svg',
                height: 3.h,
                color: _isDelivery ? isdarkmode ? primaryColor: primaryColor : Colors.white,
              ),
              label: Text(
                'Take Away',
                style: h6TextStyle.copyWith(
                    color: _isDelivery ?isdarkmode ? primaryColor: primaryColor : Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: _isDelivery ?isdarkmode ? textBlack: Colors.white : primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
