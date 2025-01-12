import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInformation {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static String sdkVersion = "";
  static String phoneModel = "";
  static String appVersion = "";
  static String imeiNumber = "";
  static AndroidDeviceInfo? androidDeviceInfo;
  static IosDeviceInfo? iosDeviceInfo;
  static WindowsDeviceInfo? windowsDeviceInfo;

  init() async {
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      sdkVersion = androidDeviceInfo?.version.sdkInt.toString() ?? "";
      phoneModel = androidDeviceInfo?.device ?? "";
      appVersion = androidDeviceInfo?.version.release ?? "";
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      phoneModel = iosDeviceInfo?.model ?? "";
      appVersion = iosDeviceInfo?.systemVersion ?? "";
    } else if (Platform.isWindows) {
      windowsDeviceInfo = await deviceInfoPlugin.windowsInfo;
      sdkVersion = windowsDeviceInfo?.buildNumber.toString() ?? "";
      phoneModel = windowsDeviceInfo?.productName ?? "";
    }
  }
}
