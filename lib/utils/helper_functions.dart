import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

import 'device_utility.dart';
import 'enum.dart';

class HelperFunctions {
  static Color? getColor(int value) {
    // define your product specific colors here and it will match the attribute colors and show specific

    switch (value) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.red;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.pink;
      case 4:
        return Colors.grey;
      case 5:
        return Colors.purple;
      case 6:
        return Colors.black;
      case 7:
        return Colors.amber;
      case 8:
        return Colors.yellow;
      case 9:
        return Colors.orange;
      case 10:
        return Colors.brown;
      case 11:
        return Colors.teal;
      case 12:
        return Colors.indigo;

      default:
        return null;
    }
  }

  static void showSnackBar(
      String message, Color backgroundColor, BuildContext context) {
    final double screenWidth = DeviceUtils.getScreenWidth(context);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: TextStyle(fontSize: screenWidth * 0.02),
        )));
  }

  static void showToast(BuildContext context,
      {required String title, TextStyle? titleStyle, required toastType type}) {
    toastification.show(
        context: context,
        title: Text(title),
        style: ToastificationStyle.fillColored,
        type: _toastType(type),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 3));
  }

  static _toastType(toastType type) {
    switch (type) {
      case toastType.error:
        return ToastificationType.error;

      case toastType.warning:
        return ToastificationType.warning;

      case toastType.success:
        return ToastificationType.success;

      default:
        return ToastificationType.info;
    }
  }

  static void showAlert(String title, String message, BuildContext context) {
    final screenWidth = HelperFunctions.screenWidth(context);
    final screenHeight = HelperFunctions.screenHeight(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(fontSize: screenWidth * 0.03),
            ),
            content:
                Text(message, style: TextStyle(fontSize: screenWidth * 0.02)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK',
                      style: TextStyle(fontSize: screenWidth * 0.02)))
            ],
          );
        });
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static String getFormattedDate(DateTime date,
      {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final wrappedList = <Widget>[];

    for (int i = 0; i < widgets.length; i += rowSize) {
      final rowChildren = widgets.sublist(
          i, i + rowSize > widgets.length ? widgets.length : i + rowSize);
      wrappedList.add(Row(
        children: rowChildren,
      ));
    }
    return wrappedList;
  }

  static hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  static showLoading(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
              canPop: false,
              child: Dialog(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20,
                      ),
                      Text("Please Wait....")
                    ],
                  ),
                ),
              ),
            ));
  }

  static showConfirmDialog(BuildContext context, void Function()? onPressed,
      {String? title, bool hideLoading = false}) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return LayoutBuilder(
              builder: (context, constraints) => AlertDialog(
                    title: Text(
                      "Alert",
                      style: TextStyle(
                          fontSize: constraints.maxWidth * 0.022,
                          fontWeight: FontWeight.w600),
                    ),
                    content: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 600,
                      ),
                      child: Text(
                        title ?? "Are You Sure!",
                        style: TextStyle(
                            fontSize: constraints.maxWidth * 0.017,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: onPressed,
                          child: Text('Yes',
                              style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.018,
                                  fontWeight: FontWeight.w400))),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (hideLoading == true) {
                              HelperFunctions.hideLoading(context);
                            }
                          },
                          child: Text('No',
                              style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.018,
                                  fontWeight: FontWeight.w400))),
                    ],
                  ));
        });
  }
}
