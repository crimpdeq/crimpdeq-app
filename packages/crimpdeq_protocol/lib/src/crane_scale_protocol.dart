/// Stateless parser for WH-C06 crane scale BLE advertisement data.
///
/// The crane scale broadcasts weight in manufacturer-specific advertisement
/// data (manufacturer ID 0x0100 / 256). No GATT connection required.
class CraneScaleData {
  const CraneScaleData({
    required this.weightKg,
    required this.isStable,
    required this.unitCode,
  });

  /// Weight in kilograms.
  final double weightKg;

  /// Whether the reading has stabilised.
  final bool isStable;

  /// Raw unit nibble: 1=kg, 2=lb, 3=st, 4=jin.
  final int unitCode;
}

class CraneScaleProtocol {
  const CraneScaleProtocol._();

  /// BLE manufacturer ID used by WH-C06 crane scales.
  static const int manufacturerId = 256; // 0x0100

  /// Minimum manufacturer data length required for a valid reading.
  static const int _minDataLength = 15;

  /// Parse manufacturer data [data] (value bytes, excluding the 2-byte ID
  /// prefix that `flutter_blue_plus` already strips).
  ///
  /// Returns `null` when the payload is too short to contain a valid reading.
  static CraneScaleData? parse(List<int> data) {
    if (data.length < _minDataLength) return null;

    // Bytes 10-11: uint16 big-endian weight, ×0.01 for kg.
    final rawWeight = (data[10] << 8) | data[11];
    final weightKg = rawWeight * 0.01;

    // Byte 14 upper nibble: stability (0 = unstable, non-zero = stable).
    final isStable = (data[14] >> 4) != 0;

    // Byte 14 lower nibble: unit code.
    final unitCode = data[14] & 0x0F;

    return CraneScaleData(
      weightKg: weightKg,
      isStable: isStable,
      unitCode: unitCode,
    );
  }
}
