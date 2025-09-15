import 'package:flutter/material.dart';

//Primary Colors
const primaryColor = Color(0xFFf95116);

//Text Colors
const textBlack = Color(0xff000000);
const textGrey1 = Color(0xff505050);
const textGrey2 = Color(0xFFB8B8B8);
const textGrey3 = Color(0xffD6D6D6);
const textGray4 = Color(0xffF7F7F7);
const textWhite = Color(0xFFFFFFFF);

//Indicator Colors
const colorSuccess = Color(0xff35BA2A);
const colorSuccess1 = Color(0xffD9D9D9);
const colorSuccess2 = Color(0xff5EE848);
const colorSuccess3 = Color(0xff008D0C);
const colorBlue1 = Color(0xffD9D9D9);
const colorBlue2 = Color(0xff67DBFF);
const colorBlue3 = Color(0xff915DD4);
const colorPink1 = Color(0xffFFABD3);
const colorPink2 = Color(0xffFF005C);

const colorFailure = Color(0xffFB0000);
const colordenger = Color(0xffFF0000);
const colorwarnig = Color(0xffFFED47);
const colorwarnig2 = Color(0xffFFC000);

//Background Color
const bgColor = Color(0xFFF7F7F7);


extension DoubleExtension on double {
  double roundOff(){
    return (this*100).roundToDouble()/100;
  }
}