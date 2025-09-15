import 'package:driver_app/utils/colors.dart';
import 'package:flutter/material.dart';

class ChipRow extends StatelessWidget {
  const ChipRow(
      {super.key, required this.activeChipIndex, required this.toggleChip});
  final int activeChipIndex;
  final ValueChanged toggleChip;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildChip('Today', 0, context),
        // SizedBox(width: 8),
        _buildChip('This week', 1, context),
        // SizedBox(width: 8),
        _buildChip('This month', 2, context),
      ],
    );
  }

  Widget _buildChip(String label, int index, BuildContext context) {
    bool isActive = activeChipIndex == index;

    return ChoiceChip(
      labelPadding: EdgeInsets.all(0),
      showCheckmark: false,
      label: SizedBox(
        width: MediaQuery.of(context).size.width / 4.5,
        // margin: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : colorGreen,
          ),
        ),
      ),
      selected: isActive,
      onSelected: (_) => toggleChip(index),
      selectedColor: colorGreen,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: colorGreen,
        ),
      ),
    );
  }
}
