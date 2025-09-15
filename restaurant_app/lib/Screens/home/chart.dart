import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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
            border: Border.all(color: Color(0xff9C9BA6))),
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
                      border: Border.all(color: Color(0xff9C9BA6)),
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
                      DropdownMenuItem(value: 'Daily', child: Text('Daily')),
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
            (dropDownValue == "Daily" && displayData.length < 3) ||
                    displayData.isEmpty
                ? SizedBox(
                    height: 21.h,
                    child: const Center(child: Text("No Orders Found")),
                  )
                : Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Transform.rotate(
                          angle: -3.147 / 2,
                          alignment: Alignment.centerLeft,
                          child: Text("Earning in ₹",
                              style: TextStyle(
                                  fontSize: 10, color: Color(0xff9C9BA6)))),
                      AspectRatio(
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
                                (LineChartBarData barData,
                                    List<int> indicators) {
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
          ],
        ),
      ),
    );
  }
}
