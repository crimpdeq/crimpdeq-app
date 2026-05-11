import 'package:crimpdeq_protocol/crimpdeq_protocol.dart';
import 'package:test/test.dart';

/// Build a 15-byte manufacturer data payload with the given weight, stability
/// flag, and unit code at the expected offsets.
List<int> _buildPayload({
  required int rawWeight,
  bool stable = false,
  int unitCode = 1,
}) {
  final data = List<int>.filled(15, 0);
  // Bytes 10-11: uint16 big-endian weight.
  data[10] = (rawWeight >> 8) & 0xFF;
  data[11] = rawWeight & 0xFF;
  // Byte 14: upper nibble = stability, lower nibble = unit.
  data[14] = ((stable ? 1 : 0) << 4) | (unitCode & 0x0F);
  return data;
}

void main() {
  group('CraneScaleProtocol.parse', () {
    test('valid data returns correct weight, stability, and unit', () {
      // 1234 * 0.01 = 12.34 kg, stable, kg unit
      final result = CraneScaleProtocol.parse(
        _buildPayload(rawWeight: 1234, stable: true, unitCode: 1),
      );
      expect(result, isNotNull);
      expect(result!.weightKg, closeTo(12.34, 0.001));
      expect(result.isStable, isTrue);
      expect(result.unitCode, 1);
    });

    test('short data returns null', () {
      expect(CraneScaleProtocol.parse([]), isNull);
      expect(CraneScaleProtocol.parse(List.filled(14, 0)), isNull);
    });

    test('zero weight', () {
      final result = CraneScaleProtocol.parse(
        _buildPayload(rawWeight: 0, stable: true),
      );
      expect(result, isNotNull);
      expect(result!.weightKg, 0.0);
    });

    test('max uint16 weight', () {
      final result = CraneScaleProtocol.parse(
        _buildPayload(rawWeight: 0xFFFF),
      );
      expect(result, isNotNull);
      expect(result!.weightKg, closeTo(655.35, 0.01));
    });

    test('unstable reading', () {
      final result = CraneScaleProtocol.parse(
        _buildPayload(rawWeight: 500, stable: false, unitCode: 1),
      );
      expect(result, isNotNull);
      expect(result!.isStable, isFalse);
    });

    test('various unit codes', () {
      for (final code in [1, 2, 3, 4]) {
        final result = CraneScaleProtocol.parse(
          _buildPayload(rawWeight: 100, unitCode: code),
        );
        expect(result, isNotNull);
        expect(result!.unitCode, code);
      }
    });

    test('extra trailing bytes are ignored', () {
      final data = [
        ..._buildPayload(rawWeight: 500, stable: true, unitCode: 2),
        0xDE, 0xAD, 0xBE, 0xEF,
      ];
      final result = CraneScaleProtocol.parse(data);
      expect(result, isNotNull);
      expect(result!.weightKg, closeTo(5.0, 0.001));
      expect(result.isStable, isTrue);
      expect(result.unitCode, 2);
    });
  });
}
