class AppConstants {
  static const int maxHistorySize = 100;
  static const int maxIntervalHistorySize = 100;
  static const int maxReceivedDataSize = 10;
  static const Duration scanTimeout = Duration(seconds: 10);
  // ADS1220 normal-mode data rates supported by the firmware, with their use
  // case. Lower rates filter more noise in the ADC; higher rates resolve
  // faster force changes.
  static const Map<int, String> sampleRateUseCases = {
    20: 'Precision',
    45: 'Precision',
    90: 'Precision',
    175: 'Balanced',
    330: 'Balanced',
    600: 'Balanced',
    1000: 'RFD',
  };
}
