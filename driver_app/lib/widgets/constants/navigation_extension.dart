import 'package:flutter/material.dart';

extension NavigationExtension on BuildContext {
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) async {
    return await Navigator.of(this)
        .pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?> replaceWith<T>(String routeName, {Object? arguments}) async {
    return await Navigator.of(this)
        .pushReplacementNamed<T, dynamic>(routeName, arguments: arguments);
  }

  Future<T?> navigateAndRemoveUntil<T>(String routeName,
      {Object? arguments}) async {
    return await Navigator.of(this).pushNamedAndRemoveUntil<T>(
        routeName, (route) => false,
        arguments: arguments);
  }

  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  void goBackWithData<T extends Object?>(T? result) {
    Navigator.of(this).pop<T>(result);
  }

  void goBackUntilFirst() {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }

  void push(Widget widget) {
    Navigator.of(this).push(MaterialPageRoute(builder: (context) => widget));
  }

  Future<T?> replaceWithWidget<T>(Widget page) async {
    return await Navigator.of(this).pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
