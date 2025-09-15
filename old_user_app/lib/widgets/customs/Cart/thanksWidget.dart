import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';

class ThanksWidget extends StatefulWidget {
  final Function(int)? onTipSelected; // Callback function

  const ThanksWidget({super.key, this.onTipSelected});

  @override
  _ThanksWidgetState createState() => _ThanksWidgetState();
}

class _ThanksWidgetState extends State<ThanksWidget> {
  double height = 9.h;
  GlobalKey key = GlobalKey();
  int? selectedTip;
  final TextEditingController _customTipController = TextEditingController();
  bool isCustomTipSelected = false; // To track if custom tip is selected
  bool show = false;

  void animate() {
    show = !show;
    if (show) {
      height = key.currentContext!.size!.height + 17;
    } else {
      height = 9.h;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        color: isdarkmode ? textBlack : textWhite,
        elevation: 3,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                key: key,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: animate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          direction: Axis.vertical,
                          children: [
                            Text('Give Thanks',
                                style: h5TextStyle.copyWith(
                                    color: isdarkmode ? textGrey2 : textBlack)),
                            const SizedBox(height: 5),
                            Text(
                              'TIP YOUR DELIVERY DRIVER',
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                        Icon(
                            show
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: primaryColor,
                            size: 30)
                      ],
                    ),
                  ),
                  SizedBox(height: show ? 5 : 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTipButton(20, isdarkmode),
                      _buildTipButton(50, isdarkmode),
                      _buildTipButton(100, isdarkmode),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      height: 6.h,
                      width: 60.w,
                      child: TextField(
                        style: TextStyle(
                            color: isdarkmode ? textGrey2 : textBlack),
                        controller: _customTipController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Enter Custom Tip',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor)),
                        ),
                        onTap: () {
                          setState(() {
                            selectedTip = null;
                            isCustomTipSelected = true;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 25.w,
                        decoration: const BoxDecoration(),
                        child: OutlinedButton(
                          onPressed: () {
                            selectedTip = null;
                            isCustomTipSelected = false;
                            _customTipController.clear();
                            if (widget.onTipSelected != null) {
                              widget.onTipSelected!(0);
                            }
                            animate();
                          },
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: primaryColor,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text(
                            'No Thanks!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 25.w,
                        child: ElevatedButton(
                          onPressed: selectedTip != null || isCustomTipSelected
                              ? () {
                                  int tipAmount = selectedTip ??
                                      int.tryParse(_customTipController.text) ??
                                      0;
                                  // Tip selected

                                  // Trigger callback with the selected or custom tip
                                  if (widget.onTipSelected != null) {
                                    widget.onTipSelected!(tipAmount);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: textWhite,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: primaryColor),
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text('Pay Tip'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipButton(int amount, bool isdarkmode) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTip = amount;
          isCustomTipSelected = false; // Clear custom selection
          _customTipController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selectedTip == amount
              ? primaryColor
              : isdarkmode
                  ? textBlack
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor,
            width: 1,
          ),
        ),
        child: Text(
          '₹$amount',
          style: TextStyle(
            color: selectedTip == amount
                ? Colors.white
                : isdarkmode
                    ? textWhite
                    : textBlack,
            fontSize: 10.sp,
          ),
        ),
      ),
    );
  }
}
