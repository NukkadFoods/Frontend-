import 'package:driver_app/widgets/common/grey_borderd_container.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/font-styles.dart';

class WorkAreaContainer extends StatefulWidget {
  final String area;
  final String description;
  final String? selectedArea;
  final ValueChanged<Map<String, String>> onAreaSelected;

  const WorkAreaContainer({
    Key? key,
    required this.area,
    required this.description,
    required this.selectedArea,
    required this.onAreaSelected,
  }) : super(key: key);

  @override
  State<WorkAreaContainer> createState() => _WorkAreaContainerState();
}

class _WorkAreaContainerState extends State<WorkAreaContainer> {
  // String? selectedArea;

  @override
  Widget build(BuildContext context) {
    return GreyBorderdContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Radio<String>(
                    activeColor: colorGreen,
                    value: widget.area,
                    groupValue: widget.selectedArea,
                    onChanged: (value) => widget.onAreaSelected({
                      'area': widget.area,
                      'description': widget.description,
                    }),
                  ),
                  Text(
                    widget.area,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: medium,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              // Row(
              //   children: [
              //     Image.asset('assets/images/locationicon.png'),
              //     Text(
              //       ' 3.2 KM',
              //       style: TextStyle(
              //         color: colorDarkGray,
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, right: 4),
                      child: Image.asset('assets/images/moneylogo.png'),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Text(
                          maxLines: 2,
                          widget.description,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ],
                ),
              )
            ],
          ),
          Image.asset('assets/images/navigation.png', height: 100)
        ],
      ),
    );
  }
}
