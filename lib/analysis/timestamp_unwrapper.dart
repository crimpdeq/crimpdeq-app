/// Extends the firmware's u32 microsecond timestamps, which wrap every
/// ~71.6 minutes, into a continuous timeline.
class TimestampUnwrapper {
  static const _range = 0x100000000;

  int _offset = 0;
  int? _lastRaw;

  int unwrap(int rawUs) {
    final lastRaw = _lastRaw;
    // Only a jump back of more than half the range is a wrap.
    if (lastRaw != null && lastRaw - rawUs > _range ~/ 2) _offset += _range;
    _lastRaw = rawUs;
    return rawUs + _offset;
  }
}
