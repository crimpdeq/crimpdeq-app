export 'package:crimpdeq_protocol/crimpdeq_protocol.dart'
    show ProgressorConstants, ControlOpCode;

class AppConstants {
  static const int maxHistorySize = 100;
  static const int maxIntervalHistorySize = 100;
  static const int maxReceivedDataSize = 10;
  static const Duration scanTimeout = Duration(seconds: 10);
  static const Duration scanExtendedTimeout = Duration(seconds: 12);
}
