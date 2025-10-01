import 'package:flutter/material.dart';

const num figmaDesignWidth = 744;
const num figmaDesignHeight = 932;
const num figmaDesignStatusBar = 0;

extension ResponsiveExtension on num {
  double get _width => SizeUtils.width;
  double get _height => SizeUtils.height;
  double get w => ((this * _width) / figmaDesignWidth);
  double get h => ((this * _height) / figmaDesignHeight);
  double get r => ((this * _width) / figmaDesignWidth);
  double get fSize => ((this * _width) / figmaDesignWidth);
}

extension FormatExtension on double {
  double toDoubleValue({int fractionDigits = 2}) =>
      double.parse(toStringAsFixed(fractionDigits));
  double isNonZero({num defaultValue = 0.0}) =>
      this > 0 ? this : defaultValue.toDouble();
}

enum DeviceType { mobile, tablet, desktop }

typedef ResponsiveBuild =
Widget Function(
    BuildContext context,
    Orientation orientation,
    DeviceType deviceType,
    );

class Sizer extends StatelessWidget {
  const Sizer({super.key, required this.builder});
  final ResponsiveBuild builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => OrientationBuilder(
        builder: (context, orientation) {
          SizeUtils.setScreenSize(constraints, orientation);
          return builder(context, orientation, SizeUtils.deviceType);
        },
      ),
    );
  }
}

class SizeUtils {
  static late BoxConstraints boxConstraints;
  static late Orientation orientation;
  static late DeviceType deviceType;
  static late double height;
  static late double width;

  static void setScreenSize(
      BoxConstraints constraints,
      Orientation currentOrientation,
      ) {
    boxConstraints = constraints;
    orientation = currentOrientation;
    if (orientation == Orientation.portrait) {
      width = boxConstraints.maxWidth.isNonZero(defaultValue: figmaDesignWidth);
      height = boxConstraints.maxHeight.isNonZero();
    } else {
      width = boxConstraints.maxHeight.isNonZero(
        defaultValue: figmaDesignWidth,
      );
      height = boxConstraints.maxWidth.isNonZero();
    }
    if (width < 450) {
      deviceType = DeviceType.mobile;
    } else if (width < 850) {
      deviceType = DeviceType.tablet;
    } else {
      deviceType = DeviceType.desktop;
    }
  }
}
