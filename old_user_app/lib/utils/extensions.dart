extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension DoubleExtension on double {
  double roundOff(){
    return (this*100).roundToDouble()/100;
  }
}