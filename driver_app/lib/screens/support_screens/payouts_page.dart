import 'package:driver_app/main.dart';
import 'package:driver_app/providers/payouts_provider.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PayoutsPage extends StatelessWidget {
  const PayoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Payouts',
          style: TextStyle(fontSize: 18, fontWeight: w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ChangeNotifierProvider<PayoutsProvider>(
          create: (context) => PayoutsProvider(),
          builder: (context, child) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REQUEST A PAYOUT',
                  style: TextStyle(fontSize: mediumSmall),
                ),
                SizedBox(height: 8),
                FullWidthGreenButton(
                    label: "REQUEST PAYOUT",
                    onPressed: () {
                      context.read<PayoutsProvider>().requestPayout(context);
                    }),
                SizedBox(height: 12),
                Text(
                  'PENDING PAYOUTS',
                  style: TextStyle(fontSize: mediumSmall),
                ),
                SizedBox(height: 8),
                Text(
                  'Payout of this week will be settled by the end of this week',
                  style: TextStyle(fontSize: small, color: Colors.grey),
                ),
                SizedBox(height: 16),
                Consumer<PayoutsProvider>(
                    builder: (context, value, child) => value.isLoading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: colorGreen,
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
                                          payout:
                                              payout['totalAmount'].toString(),
                                          timePeriod: payout['createdAt']
                                              .toString()
                                              .substring(0, 10),
                                          dateOfReceival: payout['updatedAt']
                                              .toString()
                                              .substring(0, 10),
                                          ordersCompleted: payout['earningsID'].length,
                                          status: payout['status'],
                                          isPayout: false),
                                    ),
                                ],
                              )),
                // PayoutTileWidget(
                //     payout: '410',
                //     timePeriod: '11 mar - 18 mar 2024',
                //     dateOfReceival: '20 mar 2024',
                //     ordersCompleted: 9,
                //     status: 'pending',
                //     isPayout: false),
                SizedBox(height: 32),
                Text(
                  'PAST PAYOUTS',
                  style: TextStyle(fontSize: mediumSmall),
                ),
                SizedBox(height: 16),
                // GestureDetector(
                //   onTap: () {
                //     // Handle download invoice action
                //   },
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       ElevatedButton(
                //           onPressed: () {},
                //           style: ButtonStyle(
                //             padding: WidgetStatePropertyAll(
                //                 const EdgeInsets.all(10)),
                //             // minimumSize: WidgetStatePropertyAll(Size(80, 32)),
                //             side: WidgetStatePropertyAll(
                //                 BorderSide(color: colorBrightGreen)),
                //             backgroundColor:
                //                 WidgetStatePropertyAll(Colors.white),
                //             shape: WidgetStatePropertyAll(
                //                 RoundedRectangleBorder(
                //                     borderRadius:
                //                         BorderRadius.all(Radius.circular(7)))),
                //           ),
                //           child: Text('Download Invoice',
                //               style: TextStyle(
                //                   color: colorBrightGreen, fontSize: 12))),
                //       ElevatedButton(
                //           onPressed: () {},
                //           style: ButtonStyle(
                //             // minimumSize: WidgetStatePropertyAll(Size(80, 32)),

                //             padding: WidgetStatePropertyAll(
                //                 const EdgeInsets.all(10)),
                //             side: WidgetStatePropertyAll(
                //                 BorderSide(color: colorBrightGreen)),
                //             backgroundColor:
                //                 WidgetStatePropertyAll(colorBrightGreen),
                //             shape: WidgetStatePropertyAll(
                //                 RoundedRectangleBorder(
                //                     borderRadius:
                //                         BorderRadius.all(Radius.circular(7)))),
                //           ),
                //           child: Text('10 Feb - 10 Mar 2024',
                //               style: TextStyle(
                //                   color: Colors.white,
                //                   fontWeight: w600,
                //                   fontSize: 12))),
                //     ],
                //   ),
                // ),
                SizedBox(height: 16),
                Consumer<PayoutsProvider>(
                    builder: (context, value, child) => value.isLoading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: colorGreen,
                              ),
                            ),
                          )
                        : value.paidPayouts.isEmpty
                            ? Center(
                                child: Text('No Pending Payouts'),
                              )
                            : Column(
                                children: [
                                  for (Map payout in value.paidPayouts)
                                    PayoutTileWidget(
                                        payout: payout['totalAmount'].toString(),
                                        timePeriod: payout['createdAt']
                                            .toString()
                                            .substring(0, 10),
                                        dateOfReceival: payout['updatedAt'].toString()
                                            .substring(0, 10),
                                        ordersCompleted: 1,
                                        status: payout['status'],
                                        isPayout: true),
                                ],
                              )),
                // PayoutTileWidget(
                //   payout: "395",
                //   timePeriod: "3 mar - 10 mar 2024",
                //   dateOfReceival: "13 mar 2024",
                //   ordersCompleted: 7,
                //   status: "completed",
                //   isPayout: true,
                // )
              ],
            ),
          ),
        ),
      ),
    );
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
          border: Border.all(color: colorGray)),
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
                    style: TextStyle(fontSize: small, color: Colors.black)),
                TextSpan(
                    text: '\n₹ $payout',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorBrightGreen,
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
            color: colorBrightGreen,
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
