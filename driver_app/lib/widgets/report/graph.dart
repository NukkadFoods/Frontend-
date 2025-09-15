import 'package:driver_app/utils/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample4 extends StatefulWidget {
  const BarChartSample4({
    super.key,
    required this.onToggle,
    required this.monthlyData,
    required this.weeklyData,
    required this.todayData,
  });
  final GestureTapCallback onToggle;
  final List<double> monthlyData;
  final List<double> weeklyData;
  final List<double> todayData;

  // final Color dark = colorRed;
  // final Color normal = colorBrightRed;
  // final Color light = colorOrange;

  @override
  State<StatefulWidget> createState() => BarChartSample4State();
}

class BarChartSample4State extends State<BarChartSample4> {
  // List<int> values = [100, 300, 200, 600, 400, 0, 500];

  List<double> displayData = [];
  @override
  void initState() {
    super.initState();
    displayData = widget.monthlyData;
  }

  double maxT = 0, maxW = 0, maxM = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print(maxT);
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10, color: Color(0xff9C9BA6));
    String text;
    switch (value.toInt()) {
      case 0:
        text = dropDownValue == "Monthly" ? "Week 1" : 'Mon';
        break;
      case 1:
        text = dropDownValue == "Monthly" ? "Week 2" : 'Tue';
        break;
      case 2:
        text = dropDownValue == "Monthly" ? "Week 3" : 'Wed';
        break;
      case 3:
        text = dropDownValue == "Monthly" ? "Week 4" : 'Thu';
        break;
      case 4:
        text = dropDownValue == "Monthly" ? "Week 5" : 'Fri';
        break;
      case 5:
        text = 'Sat';
        break;
      case 6:
        text = 'Sun';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(text, style: style),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    const style = TextStyle(
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: style,
      ),
    );
  }

  String dropDownValue = 'Monthly';
  @override
  Widget build(BuildContext context) {
    switch (dropDownValue) {
      case "Daily":
        for (double item in widget.todayData) {
          if (item > maxT) {
            maxT = item;
          }
        }
        break;
      case "Monthly":
        for (double item in widget.monthlyData) {
          if (item > maxM) {
            maxM = item;
          }
        }
        break;
      case "Weekly":
        for (double item in widget.weeklyData) {
          if (item > maxW) {
            maxW = item;
          }
        }
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.all(color: colorGray)),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('No. of Orders'),
                Container(
                  padding: EdgeInsets.only(left: 8),
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border.all(color: colorGray),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: DropdownButton(
                    style: TextStyle(color: Colors.black54),
                    underline: SizedBox.shrink(),
                    icon: Icon(Icons.keyboard_arrow_down),
                    value: dropDownValue,
                    onChanged: (value) {
                      switch (value) {
                        case "Daily":
                          displayData = widget.todayData;
                          break;
                        case "Weekly":
                          displayData = widget.weeklyData;
                          break;
                        case "Monthly":
                          displayData = widget.monthlyData;
                          break;
                      }
                      setState(() {
                        dropDownValue = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'Daily',
                        child: Text('Daily'),
                      ),
                      DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'Monthly', child: Text('Monthly'))
                    ],
                  ),
                ),
                InkWell(
                  onTap: widget.onToggle,
                  child: Text(
                    'See Details',
                    style: TextStyle(
                        decorationColor: Color(0xffFB6D3A),
                        color: Color(0xffFB6D3A),
                        decoration: TextDecoration.underline),
                  ),
                )
              ],
            ),
            displayData.isEmpty
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * .2155,
                    child: Center(child: Text("No Orders Found")),
                  )
                : AspectRatio(
                    aspectRatio: 1.66,
                    child: LineChart(LineChartData(
                        lineTouchData: LineTouchData(touchTooltipData:
                            LineTouchTooltipData(
                                getTooltipItems: (touchedSpots) {
                          return touchedSpots.map(
                            (LineBarSpot touchedSpot) {
                              return LineTooltipItem(
                                  '₹ ${displayData[touchedSpot.spotIndex].toStringAsFixed(2)}',
                                  TextStyle(color: Colors.white));
                            },
                          ).toList();
                        }), getTouchedSpotIndicator:
                            (LineChartBarData barData, List<int> indicators) {
                          return indicators.map(
                            (int index) {
                              final line = FlLine(
                                  strokeWidth: 5,
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: const [
                                        Color.fromRGBO(112, 212, 255, 1),
                                        Color.fromRGBO(112, 212, 255, .11)
                                      ]));
                              return TouchedSpotIndicatorData(
                                line,
                                FlDotData(show: true),
                              );
                            },
                          ).toList();
                        }),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        minY: 0,
                        maxY: (dropDownValue == "Daily"
                                ? maxT
                                : dropDownValue == "Weekly"
                                    ? maxW
                                    : maxM) *
                            1.2,
                        lineBarsData: [
                          LineChartBarData(
                              belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: const [
                                        Color.fromRGBO(112, 212, 255, 1),
                                        Color.fromRGBO(112, 212, 255, .11)
                                      ])),
                              isCurved: true,
                              spots: [
                                for (int i = 0; i < displayData.length; i++)
                                  FlSpot(i.toDouble(), displayData[i])
                              ],
                              dotData: FlDotData(show: false)),
                        ],
                        titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                              interval: 1,
                              showTitles: !(dropDownValue == 'Daily'),
                              reservedSize: 28,
                              getTitlesWidget: bottomTitles,
                            ))))),
                  ),
          ],
        ),
      ),
    );
  }

/*
BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                barTouchData: BarTouchData(
                  enabled: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: bottomTitles,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: leftTitles,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % 10 == 0,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: borderColor,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                groupsSpace: barsSpace,
                barGroups: getData(barsWidth, barsSpace),
              ),
            )
*/

  // List<BarChartGroupData> getData(double barsWidth, double barsSpace) {
  //   return [
  //     BarChartGroupData(
  //       x: 0,
  //       barsSpace: barsSpace,
  //       barRods: [
  //         BarChartRodData(
  //           toY: 17000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 2000000000, widget.dark),
  //             BarChartRodStackItem(2000000000, 12000000000, widget.normal),
  //             BarChartRodStackItem(12000000000, 17000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 24000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 13000000000, widget.dark),
  //             BarChartRodStackItem(13000000000, 14000000000, widget.normal),
  //             BarChartRodStackItem(14000000000, 24000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 23000000000.5,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 6000000000.5, widget.dark),
  //             BarChartRodStackItem(6000000000.5, 18000000000, widget.normal),
  //             BarChartRodStackItem(18000000000, 23000000000.5, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 29000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 9000000000, widget.dark),
  //             BarChartRodStackItem(9000000000, 15000000000, widget.normal),
  //             BarChartRodStackItem(15000000000, 29000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 32000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 2000000000.5, widget.dark),
  //             BarChartRodStackItem(2000000000.5, 17000000000.5, widget.normal),
  //             BarChartRodStackItem(17000000000.5, 32000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //       ],
  //     ),
  //     BarChartGroupData(
  //       x: 1,
  //       barsSpace: barsSpace,
  //       barRods: [
  //         BarChartRodData(
  //           toY: 31000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 11000000000, widget.dark),
  //             BarChartRodStackItem(11000000000, 18000000000, widget.normal),
  //             BarChartRodStackItem(18000000000, 31000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 35000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 14000000000, widget.dark),
  //             BarChartRodStackItem(14000000000, 27000000000, widget.normal),
  //             BarChartRodStackItem(27000000000, 35000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 31000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 8000000000, widget.dark),
  //             BarChartRodStackItem(8000000000, 24000000000, widget.normal),
  //             BarChartRodStackItem(24000000000, 31000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 15000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 6000000000.5, widget.dark),
  //             BarChartRodStackItem(6000000000.5, 12000000000.5, widget.normal),
  //             BarChartRodStackItem(12000000000.5, 15000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 17000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 9000000000, widget.dark),
  //             BarChartRodStackItem(9000000000, 15000000000, widget.normal),
  //             BarChartRodStackItem(15000000000, 17000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //       ],
  //     ),
  //     BarChartGroupData(
  //       x: 2,
  //       barsSpace: barsSpace,
  //       barRods: [
  //         BarChartRodData(
  //           toY: 34000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 6000000000, widget.dark),
  //             BarChartRodStackItem(6000000000, 23000000000, widget.normal),
  //             BarChartRodStackItem(23000000000, 34000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 32000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 7000000000, widget.dark),
  //             BarChartRodStackItem(7000000000, 24000000000, widget.normal),
  //             BarChartRodStackItem(24000000000, 32000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 14000000000.5,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 1000000000.5, widget.dark),
  //             BarChartRodStackItem(1000000000.5, 12000000000, widget.normal),
  //             BarChartRodStackItem(12000000000, 14000000000.5, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 20000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 4000000000, widget.dark),
  //             BarChartRodStackItem(4000000000, 15000000000, widget.normal),
  //             BarChartRodStackItem(15000000000, 20000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 24000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 4000000000, widget.dark),
  //             BarChartRodStackItem(4000000000, 15000000000, widget.normal),
  //             BarChartRodStackItem(15000000000, 24000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //       ],
  //     ),
  //     BarChartGroupData(
  //       x: 3,
  //       barsSpace: barsSpace,
  //       barRods: [
  //         BarChartRodData(
  //           toY: 14000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 1000000000.5, widget.dark),
  //             BarChartRodStackItem(1000000000.5, 12000000000, widget.normal),
  //             BarChartRodStackItem(12000000000, 14000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 27000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 7000000000, widget.dark),
  //             BarChartRodStackItem(7000000000, 25000000000, widget.normal),
  //             BarChartRodStackItem(25000000000, 27000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 29000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 6000000000, widget.dark),
  //             BarChartRodStackItem(6000000000, 23000000000, widget.normal),
  //             BarChartRodStackItem(23000000000, 29000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 16000000000.5,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 9000000000, widget.dark),
  //             BarChartRodStackItem(9000000000, 15000000000, widget.normal),
  //             BarChartRodStackItem(15000000000, 16000000000.5, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //         BarChartRodData(
  //           toY: 15000000000,
  //           rodStackItems: [
  //             BarChartRodStackItem(0, 7000000000, widget.dark),
  //             BarChartRodStackItem(7000000000, 12000000000.5, widget.normal),
  //             BarChartRodStackItem(12000000000.5, 15000000000, widget.light),
  //           ],
  //           borderRadius: BorderRadius.zero,
  //           width: barsWidth,
  //         ),
  //       ],
  //     ),
  // ];
  // }
}
