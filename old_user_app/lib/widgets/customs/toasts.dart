import 'package:fluttertoast/fluttertoast.dart' as ftoast;
import 'package:user_app/widgets/constants/colors.dart';

class Toast {
  static void showToast({required String message, bool isError = false}) {
    ftoast.Fluttertoast.showToast(
        msg: message,
        toastLength:
            isError ? ftoast.Toast.LENGTH_LONG : ftoast.Toast.LENGTH_SHORT,
        gravity: ftoast.ToastGravity.BOTTOM,
        backgroundColor: textWhite,
        textColor: isError ? primaryColor : colorSuccess,
        fontSize: 16.0);
  }
}
