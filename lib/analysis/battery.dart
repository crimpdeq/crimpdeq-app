/// Single-cell LiPo resting voltage (mV) to state of charge (%). 0 % is the
/// firmware's 3300 mV shutdown threshold.
const _chargeCurve = [
  (3300, 0),
  (3610, 5),
  (3690, 10),
  (3710, 15),
  (3730, 20),
  (3750, 25),
  (3770, 30),
  (3790, 35),
  (3800, 40),
  (3820, 45),
  (3840, 50),
  (3850, 55),
  (3870, 60),
  (3910, 65),
  (3950, 70),
  (3980, 75),
  (4020, 80),
  (4080, 85),
  (4110, 90),
  (4150, 95),
  (4200, 100),
];

/// Estimates the state of charge from the voltage the firmware reports. Load
/// lowers and charging raises the voltage, so the result is approximate.
int batteryStateOfCharge(int millivolts) {
  if (millivolts <= _chargeCurve.first.$1) return 0;
  for (var i = 1; i < _chargeCurve.length; i++) {
    final (highMv, highPercent) = _chargeCurve[i];
    if (millivolts > highMv) continue;
    final (lowMv, lowPercent) = _chargeCurve[i - 1];
    final fraction = (millivolts - lowMv) / (highMv - lowMv);
    return (lowPercent + fraction * (highPercent - lowPercent)).round();
  }
  return 100;
}
