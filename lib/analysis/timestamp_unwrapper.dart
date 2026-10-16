/// Extends the firmware's u32 microsecond timestamps, which wrap every
/// ~71.6 minutes, into a continuous timeline.
class TimestampUnwrapper {
  static const _range = 0x100000000;

  int _offset = 0;
  int? _lastRawUs;

  int? get lastRawUs => _lastRawUs;

  int unwrap(int rawUs) {
    final lastRawUs = _lastRawUs;
    // Only a jump back of more than half the range is a wrap.
    if (lastRawUs != null && lastRawUs - rawUs > _range ~/ 2) {
      _offset += _range;
    }
    _lastRawUs = rawUs;
    return rawUs + _offset;
  }
}
