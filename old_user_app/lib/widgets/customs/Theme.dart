import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: textBlack),
      useMaterial3: true,
      appBarTheme: AppBarTheme(color:Colors.transparent),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
      ),
      timePickerTheme: const TimePickerThemeData(
        dialHandColor: primaryColor,
        backgroundColor: textWhite,
        dayPeriodColor: textGrey3,
        dialBackgroundColor: textGrey2,
        hourMinuteColor: bgColor,
        entryModeIconColor: textBlack,
      ),
      textTheme: GoogleFonts.poppinsTextTheme());

  static final ThemeData dark = ThemeData(
      brightness: Brightness.dark,
      cardColor: textBlack,
      iconTheme: IconThemeData(color: textWhite),
      useMaterial3: true,
      appBarTheme: AppBarTheme(color: Colors.transparent),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
      ),
      primaryTextTheme: TextTheme(
        titleLarge: titleTextStyle,
        bodyLarge: body1TextStyle,
        bodyMedium: body2TextStyle,
        bodySmall: body3TextStyle,
        displayLarge: titleTextStyle,
        headlineLarge: h1TextStyle,
        headlineMedium: h2TextStyle,
        headlineSmall: h3TextStyle,
        labelLarge: body4TextStyle,
        labelMedium: body5TextStyle,
        labelSmall: body6TextStyle,
        titleMedium:h4TextStyle, 
        displayMedium: h5TextStyle,
        displaySmall: h6TextStyle,
        titleSmall: h6TextStyle
      ),
      timePickerTheme: const TimePickerThemeData(
          dialHandColor: primaryColor,
          backgroundColor: textGrey1,
          dayPeriodColor: textGrey3,
          dialBackgroundColor: textGrey2,
          hourMinuteColor: textGrey3,
          entryModeIconColor: textBlack,
          dialTextColor: primaryColor),
      textTheme: GoogleFonts.poppinsTextTheme());
}

class Themes extends ChangeNotifier{
  ThemeData _currenttheme = ThemeData.light();
  ThemeData get currenttheme => _currenttheme;
Themes(bool isdarkmode){
  if(isdarkmode){
    _currenttheme=ThemeData.dark();
  }else{
    _currenttheme= ThemeData.light();
  }
}
  void toggleTheme ()async{
    SharedPreferences prefs =await SharedPreferences.getInstance();
    if(_currenttheme == ThemeData.light()){
      prefs.setBool('isDarkTheme' ,true);
      _currenttheme=ThemeData.dark();
    }else{
        prefs.setBool('isDarkTheme' ,false);
      _currenttheme = ThemeData.light();
    }
    notifyListeners();
  }
}