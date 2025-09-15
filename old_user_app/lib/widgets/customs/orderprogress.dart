import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/widgets/constants/colors.dart';

class OrderPreparingCard extends StatefulWidget {
  final DateTime estimatedTime; // Estimated delivery time in seconds
  final String status;
  final String orderid;
  final DateTime orderedAt;

  const OrderPreparingCard({
    super.key,
    required this.estimatedTime,
    required this.status,
    required this.orderid,
    required this.orderedAt,
  });

  @override
  _OrderPreparingCardState createState() => _OrderPreparingCardState();
}

class _OrderPreparingCardState extends State<OrderPreparingCard> {
  // late Timer _timer;
  late int elapsedSeconds;
  late int _timeRemaining;
  late int _totalTime;
  late Stream<double> stream;

  @override
  void initState() {
    super.initState();
    calculateTime();
    initStream();
  }

  void calculateTime() {
    final totalTime = widget.estimatedTime.difference(widget.orderedAt);
    _totalTime = totalTime.inSeconds;
    final now = DateTime.now();
    final difference = widget.estimatedTime.difference(now);
    elapsedSeconds = (totalTime - difference).inSeconds;
    _timeRemaining = difference.inSeconds;
  }

  // void initTimer() {
  //   _timer = Timer.periodic(const Duration(seconds: 1), (_) {
  //     _timeRemaining--;
  //     _progress = (_totalTime - _timeRemaining) / _totalTime;
  //   });
  // }

  void initStream() {
    stream = Stream.periodic(const Duration(seconds: 1), (_) {
      _timeRemaining--;
      return (_totalTime - _timeRemaining) / _totalTime;
    });
  }

  // @override
  // void didUpdateWidget(OrderPreparingCard oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.estimatedTime != widget.estimatedTime) {
  //     _resetTimer(); // Reset the timer if estimatedTime changes
  //   }
  // }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    // Calculate hours and minutes
    return Container(
      height: 8.6.h,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: primaryColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.3.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/preparing_icon.svg', // your saved icon
                    height: 4.h,
                    width: 2.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Order ${widget.status}....',
                    style: TextStyle(
                      color: isdarkmode ? textBlack : textWhite,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              StreamBuilder(
                stream: stream,
                builder: (context, snapshot) {
                  int hours =
                      (_timeRemaining ~/ 3600); // Divide by 3600 to get hours
                  int minutes = (_timeRemaining % 3600) ~/
                      60; // Get the remaining minutes
                  int seconds =
                      _timeRemaining % 60; // Get the remaining seconds

                  String timeDisplay;
                  if (_timeRemaining.isNegative) {
                    timeDisplay =
                        '${(_timeRemaining ~/ 60).abs().toString()} mins late';
                  } else {
                    if (hours > 0) {
                      timeDisplay =
                          '$hours hr ${minutes.toString().padLeft(2, '0')} min';
                    } else {
                      timeDisplay =
                          '$minutes min ${seconds.toString().padLeft(2, '0')} sec';
                    }
                  }
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: snapshot.data,
                        backgroundColor: isdarkmode ? textGrey1 : textWhite,
                        color: Colors.green,
                        minHeight: 0.6.h,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      Text(
                        '${_timeRemaining.isNegative ? "" : 'Estimated delivery time:'} $timeDisplay',
                        style: TextStyle(
                          color: isdarkmode ? textBlack : Colors.white,
                          fontSize: 8.sp,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
