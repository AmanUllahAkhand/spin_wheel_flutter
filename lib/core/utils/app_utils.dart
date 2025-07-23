import 'dart:math';

class AppUtils {
  static String appName = "Tutorial";

  static const double radianFor360 = 2 * pi;
  static const double radianFor270 = 3 * pi / 2;
  static const double radianFor180 = pi;
  static const double radianFor90 = pi / 2;

  // Converts radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * (180 / pi);
  }

  // Converts degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
