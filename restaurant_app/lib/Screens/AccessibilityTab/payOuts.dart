// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/Screens/Wallet/viewEarningsScreen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/provider/payouts_provider.dart';
import 'package:sizer/sizer.dart';

class PayOutsWidget extends StatelessWidget {
  const PayOutsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = PayoutsProvider();
    return Scaffold(
        appBar: AppBar(
          title: Text('Payouts', style: h4TextStyle),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 19.sp,
              color: Colors.black,
            ),
          ),
        ),
        body: Stack(children: [
          Image.asset(
            'assets/images/otpbg.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: ChangeNotifierProvider<PayoutsProvider>(
              create: (context) => provider,
              builder: (context, child) => SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'REQUEST A PAYOUT',
                          style: titleTextStyle,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      mainButton('Request Payout', textWhite, () {
                        context.read<PayoutsProvider>().requestPayout(context);
                      }),
                      SizedBox(
                        height: 2.h,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Pending payouts'.toUpperCase(),
                          style: titleTextStyle,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        'Payout of this week will be settled by the end of this week',
                        style: body3TextStyle.copyWith(
                          fontSize: 12,
                          color: textGrey2,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Consumer<PayoutsProvider>(
                          builder: (context, value, child) => value.isLoading
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                                  ),
                                )
                              : value.pendingPayouts.isEmpty
                                  ? Center(
                                      child: Text('No Pending Payouts'),
                                    )
                                  : Column(
                                      children: [
                                        for (Map payout in value.pendingPayouts)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: PayoutTileWidget(
                                                payout: payout['totalAmount']
                                                    .toStringAsFixed(2),
                                                timePeriod: payout['createdAt']
                                                    .toString()
                                                    .substring(0, 10),
                                                dateOfReceival:
                                                    payout['updatedAt']
                                                        .toString()
                                                        .substring(0, 10),
                                                ordersCompleted:
                                                    payout['earningsID'].length,
                                                status: payout['status'],
                                                isPayout: false),
                                          ),
                                      ],
                                    )),
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        'Past payouts'.toUpperCase(),
                        style: titleTextStyle,
                        textAlign: TextAlign.start,
                      ),
                      // SizedBox(
                      //   height: 2.h,
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Container(
                      //       padding: EdgeInsets.symmetric(
                      //           horizontal: 2.w, vertical: 1.5.h),
                      //       decoration: BoxDecoration(
                      //         // color: colorwarnig.withOpacity(0.3),
                      //         border:
                      //             Border.all(width: 0.2.h, color: primaryColor),
                      //         borderRadius: BorderRadius.circular(7),
                      //       ),
                      //       child: Text('Download Invoice',
                      //           textAlign: TextAlign.center,
                      //           style: body4TextStyle.copyWith(
                      //               color: primaryColor)),
                      //     ),
                      //     Container(
                      //       padding: EdgeInsets.symmetric(
                      //           horizontal: 2.w, vertical: 1.5.h),
                      //       decoration: BoxDecoration(
                      //         color: primaryColor,
                      //         border:
                      //             Border.all(width: 0.2.h, color: primaryColor),
                      //         borderRadius: BorderRadius.circular(7),
                      //       ),
                      //       child: Text(
                      //         '10 Feb - 10 Mar 2024',
                      //         textAlign: TextAlign.center,
                      //         style: body4TextStyle.copyWith(color: textWhite),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Consumer<PayoutsProvider>(
                          builder: (context, value, child) => value.isLoading
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                                  ),
                                )
                              : value.paidPayouts.isEmpty
                                  ? Center(
                                      child: Text('No Past Payouts'),
                                    )
                                  : Column(
                                      children: [
                                        for (Map payout in value.paidPayouts)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: PayoutTileWidget(
                                                payout: payout['totalAmount']
                                                    .toStringAsFixed(2),
                                                timePeriod: payout['createdAt']
                                                    .toString()
                                                    .substring(0, 10),
                                                dateOfReceival:
                                                    payout['updatedAt']
                                                        .toString()
                                                        .substring(0, 10),
                                                ordersCompleted:
                                                    payout['earningsID'].length,
                                                status: payout['status'],
                                                isPayout: true),
                                          ),
                                      ],
                                    )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]));
  }
}

class PayoutTileWidget extends StatelessWidget {
  final String payout;
  final String timePeriod;
  final String dateOfReceival;
  final int ordersCompleted;
  final String status;
  final bool isPayout;
  const PayoutTileWidget(
      {super.key,
      required this.payout,
      required this.timePeriod,
      required this.dateOfReceival,
      required this.ordersCompleted,
      required this.status,
      required this.isPayout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: isPayout ? 'Payout' : 'Estimated payout',
                    style: TextStyle(fontSize: 12, color: Colors.black)),
                TextSpan(
                    text: '\n₹ $payout',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        height: 1.7))
              ])),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      status == "completed" ? Colors.black : Color(0xffff0000),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(status.capitalize(),
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            color: primaryColor,
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Time period:'),
              Text(' $timePeriod',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date of receival:'),
              Text(dateOfReceival,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total orders completed:'),
              Text(
                '$ordersCompleted',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
