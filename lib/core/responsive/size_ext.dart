// lib/core/utils/size_ext.dart
import 'scale_config.dart';

extension SizeExt on num {
  /// Safe width (clamped)
  double get sW => ScaleConfig.sw(toDouble());

  /// Safe height (clamped)
  double get sH => ScaleConfig.sh(toDouble());

  /// Safe sp (clamped)
  double get sSp => ScaleConfig.ssp(toDouble());
}
