import 'package:driver_app/controller/orders/order_controller.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/providers/report_provider.dart';
import 'package:driver_app/screens/support_screens/help_center_screen.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:driver_app/widgets/report/chips.dart';
import 'package:driver_app/widgets/report/graph.dart';
import 'package:driver_app/widgets/report/stats.dart';
import 'package:driver_app/widgets/wallet/earning_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool showContainer = false;

  @override
  void initState() {
    super.initState();
  }

  bool getMounted() {
    return mounted;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReportProvider>(
      create: (context) => ReportProvider(getMounted: getMounted),
      builder: (context, child) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200, // Set the width of the button
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DutyController.isOnDuty
                            ? Colors.grey
                            : colorBrightGreen,
                      ),
                      onPressed: () async {
                        DutyController.isOnDuty =
                            !DutyController.isOnDuty; // Toggle the duty status
                        if (DutyController.isOnDuty) {
                          if ((await OrderController.streamRef.get())
                              .get('orders')
                              .isEmpty) {
                            Toast.showToast(message: "Starting Duty...");
                            await DutyController.startDuty(
                                 context);
                          }
                        } else {
                          DutyController.endDuty();
                        }
                        setState(() {});
                      },
                      child: Text(
                        DutyController.isOnDuty ? 'END DUTY' : 'START DUTY',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  // SvgPicture.asset(
                  //   'assets/svgs/bell.svg',
                  //   height: 30,
                  // ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                          transitionToNextScreen(const HelpCentreScreen()));
                    },
                    child: const Text(
                      'Help',
                      style: TextStyle(
                        color: colorGreen,
                        fontSize: mediumLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF47D3FF), Color(0xFF5A00CF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        width: 2,
                        color: const Color(
                          0xFF5CC7FA,
                        ))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<ReportProvider>(
                      builder: (context, value, child) => Text(
                        '${value.getBannerString()}’s Earnings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: mediumLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Consumer<ReportProvider>(
                      builder: (context, value, child) => Text(
                        '₹ ${value.getBannerAmount()}',
                        style: TextStyle(
                          color: yellowTextColor,
                          fontSize: 35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Consumer<ReportProvider>(
                      builder: (context, value, child) => Text(
                        'This Week Earnings : ₹ ${value.totalWeek.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: medium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Earning Report',
                style: TextStyle(
                  fontSize: veryLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Consumer<ReportProvider>(
                builder: (context, value, child) => ChipRow(
                  activeChipIndex: value.activeChipIndex,
                  toggleChip: (index) => value.toggleChip(index),
                ),
              ),
              showContainer
                  ? StatsCards(
                      onToggle: () {
                        setState(() {
                          showContainer = !showContainer;
                        });
                      },
                    )
                  : Consumer<ReportProvider>(
                      builder: (context, value, child) => BarChartSample4(
                        todayData: value.todayData,
                        weeklyData: value.weeklyData,
                        monthlyData: value.monthlyData,
                        onToggle: () {
                          // setState(() {
                          //   showContainer = !showContainer;
                          // });
                          Navigator.of(context).push(
                              transitionToNextScreen(const EarningScreen()));
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatsCards extends StatelessWidget {
  const StatsCards({super.key, required this.onToggle});
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onToggle,
            child: Text(
              'Show Graph',
              style: TextStyle(
                  color: Color(0xffFB6D3A),
                  height: 1.5,
                  decorationColor: Color(0xffFB6D3A),
                  decoration: TextDecoration.underline),
            ),
          ),
        ),
        // SizedBox(
        //   height: 30,
        // ),
        Stats(),
        SizedBox(
          height: 20,
        ),
        Stats(),
        SizedBox(
          height: 20,
        ),
        Stats()
      ],
    );
  }
}
