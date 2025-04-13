import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';

import '../../provider/earnings_provider.dart';

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class EarningScreen extends StatelessWidget {
  const EarningScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ChangeNotifierProvider(
        create: (context) => EarningProvider(context),
        builder: (context, child) => Column(
          children: [
            Consumer<EarningProvider>(
              builder: (context, value, child) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${value.showAll ? "All Earnings" : "Earnings on ${DateFormat('E, dd/MM/yyyy').format(value.date)}"}  ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => value.showAll
                        ? context.read<EarningProvider>().pickDate(context)
                        : value.toggleShowAll(true),
                    icon: Icon(value.showAll
                        ? Icons.filter_alt_outlined
                        : Icons.filter_alt_off_outlined),
                  )
                ],
              ),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: Color(0xffd6d6d6), width: 1)),
                child: Consumer<EarningProvider>(
                  builder: (context, value, child) => value.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : value.earnings.isEmpty
                          ? Center(
                              child: Text(
                              "No Earnings Found\nComplete Some orders to Earn",
                              textAlign: TextAlign.center,
                            ))
                          : Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black26, width: 1),
                                  )),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          '₹ ${value.showAll ? value.allEarningsTotal.toStringAsFixed(2) : value.total.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: ListView.builder(
                                    itemCount: value.displayedEarnings.length,
                                    itemBuilder: (context, index) =>
                                        earningsWidget(
                                            data:
                                                value.displayedEarnings[index]),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget earningsWidget({required Map data}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: Container(
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(color: Colors.black26, width: 1),
      )),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              data['orderId'],
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '  ${data['status'].toString().capitalize()}  ',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '₹ ${data['amount'].toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


/*
Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.watch_later_outlined,
                      color: colorGreen,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '11:11 AM',
                      style: TextStyle(color: colorGray, fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 25),
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/greenlocationicon.png',
                      height: 18,
                    ),
                    SizedBox(width: 10),
                    Text(
                      '4.5 KM',
                      style: TextStyle(color: colorGray, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '₹ 235',
                style: TextStyle(fontWeight: w600, fontSize: 15),
              ),
            ],
          ),
 */