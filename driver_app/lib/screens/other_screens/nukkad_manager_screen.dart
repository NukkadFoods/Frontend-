import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NukkadManagerScreen extends StatelessWidget {
  const NukkadManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_new)),
        title: Text(
          'Nukkad Manager',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: medium),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Please find contact details of your nukkad manager below. Feel free to contact in any case of doubt, Training and help needed.',
              style: TextStyle(
                color: colorGray,
                fontSize: small,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: colorGray,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 3,
                              color: colorGreen,
                            ),
                            shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage('assets/images/ajay.jpeg'),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ajay Tiwari',
                            style: TextStyle(
                              color: colorGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: medium,
                            ),
                          ),
                          Text('Speaks Hindi and English',
                              style: TextStyle(
                                color: colorGray,
                                fontWeight: FontWeight.bold,
                                fontSize: mediumSmall,
                              ))
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/svgs/phone.svg'),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '9399250600',
                        style: TextStyle(fontSize: mediumSmall),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/svgs/mail.svg'),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Ajay@nukkadfoods.com',
                        style: TextStyle(fontSize: mediumSmall),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
