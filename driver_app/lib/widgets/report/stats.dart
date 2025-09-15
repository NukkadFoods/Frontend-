import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:flutter/material.dart';

class Stats extends StatelessWidget {
  const Stats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 2, color: colorLightGray)),
          child: Column(
            children: [
              Text(
                'Earnings',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 140,
                height: 1,
                color: colorLightGray,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                '₹410',
                style: TextStyle(
                  color: colorGreen,
                  fontSize: large,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: colorGreen,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 2 - 57),
                    child: Text(
                      '13% increase in sales from yesterday',
                      style: TextStyle(
                        color: colorGreen,
                        fontSize: small,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 2, color: colorLightGray)),
          child: Column(
            children: [
              Text(
                'Earnings',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 140,
                height: 1,
                color: colorLightGray,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                '₹410',
                style: TextStyle(
                  color: colorGreen,
                  fontSize: large,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: colorGreen,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 2 - 57),
                    child: Text(
                      '13% increase in sales from yesterday',
                      style: TextStyle(
                        color: colorGreen,
                        fontSize: small,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
