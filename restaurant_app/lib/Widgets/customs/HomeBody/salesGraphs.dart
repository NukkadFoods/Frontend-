import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

class SalesGraph extends StatefulWidget {

  const SalesGraph({super.key,
   required this. Selectedtime});
   final String Selectedtime;

  @override
  State<SalesGraph> createState() => _SalesGraphState();
}

class _SalesGraphState extends State<SalesGraph> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      width: 95.w,
      decoration: BoxDecoration(
        color: const Color(0xFFfeefe8),
        border: Border.all(color: textGrey3, width: 0.2.h),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: widget.Selectedtime =="Today" ? Image.asset('assets/images/today_graph.png') : widget.Selectedtime == 'This Week' ? Image.asset('assets/images/weekgraph.png') : Image.asset('assets/images/monthgraph.png') 
      
      ),
    );
  }
}
