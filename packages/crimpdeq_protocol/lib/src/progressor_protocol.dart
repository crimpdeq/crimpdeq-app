import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'constants.dart';
import 'events.dart';
import 'models.dart';
import 'transport.dart';

/// Core Tindeq Progressor protocol handler.
///
/// Receives raw BLE notification bytes via [handleNotification], reassembles
/// framed packets, parses them, and emits typed [ProgressorEvent]s on [events].
/// Outgoing commands are sent through the supplied [BleTransport].
class ProgressorProtocol {
  final BleTransport _transport;
  final _eventController = StreamController<ProgressorEvent>.broadcast();
  final List<int> _rxBuffer = [];

  ProgressorProtocol(this._transport);

  /// Typed event stream — subscribe to receive parsed protocol events.
  Stream<ProgressorEvent> get events => _eventController.stream;

  // ── Incoming notifications ───────────────────────────────────────

  /// Push a raw BLE notification chunk for reassembly and parsing.
  void handleNotification(List<int> chunk) {
    if (chunk.isEmpty) return;

    _rxBuffer.addAll(chunk);

    while (_rxBuffer.isNotEmpty) {
      final messageType = _rxBuffer.first;

      // Low battery can be a single-byte message on some firmware variants.
      if (messageType == ProgressorConstants.lowBatteryWarning &&
          _rxBuffer.length == 1) {
        _parseReceivedData(List<int>.from(_rxBuffer));
        _rxBuffer.clear();
        return;
      }

      if (_rxBuffer.length < 2) return;

      final payloadLength = _rxBuffer[1];
      final expectedFrameLength = payloadLength + 2;

      // Legacy 5-byte battery frame: [0, v0, v1, v2, v3] (no length byte).
      if (messageType == ProgressorConstants.commandResponse &&
          _rxBuffer.length >= 5) {
        final legacyBatteryFrame = List<int>.from(_rxBuffer.take(5));
        if (_looksLikeLegacyBatteryFrame(legacyBatteryFrame)) {
          _parseReceivedData(legacyBatteryFrame);
          _rxBuffer.removeRange(0, 5);
          continue;
        }
      }

      if (expectedFrameLength <= 1 || expectedFrameLength > 512) {
        _rxBuffer.removeAt(0);
        continue;
      }

      // Legacy calibration frames without payload-length byte.
      if (messageType == 5 && _rxBuffer.length == 5) {
        _parseReceivedData(List<int>.from(_rxBuffer));
        _rxBuffer.clear();
        return;
      }
      if (messageType == 6 && _rxBuffer.length == 9) {
        _parseReceivedData(List<int>.from(_rxBuffer));
        _rxBuffer.clear();
        return;
      }

      if (_rxBuffer.length < expectedFrameLength) return;

      final frame = List<int>.from(_rxBuffer.take(expectedFrameLength));
      _rxBuffer.removeRange(0, expectedFrameLength);
      _parseReceivedData(frame);
    }
  }

  /// Discard any partially-received data in the reassembly buffer.
  void resetBuffer() => _rxBuffer.clear();

  // ── Outgoing commands ────────────────────────────────────────────

  Future<void> startMeasurement() => _sendCommand('e');
  Future<void> stopMeasurement() => _sendCommand('f');
  Future<void> tareScale() => _sendCommand('d');
  Future<void> getFirmwareVersion() => _sendCommand('k');
  Future<void> getBatteryVoltage() => _sendCommand('o');

  Future<void> getCalibration() =>
      _sendControlOpCode(ControlOpCode.getCalibration.value);

  Future<void> addCalibrationPoint(double weightKg) {
    final payload = ByteData(4)..setFloat32(0, weightKg, Endian.little);
    return _sendControlOpCode(
      ControlOpCode.addCalibrationPoint.value,
      payload.buffer.asUint8List(),
    );
  }

  Future<void> defaultCalibration() =>
      _sendControlOpCode(ControlOpCode.defaultCalibration.value);

  /// Release resources. No further events will be emitted after this.
  void dispose() => _eventController.close();

  // ── Private: parsing ─────────────────────────────────────────────

  void _parseReceivedData(List<int> rawData) {
    if (rawData.isEmpty) return;

    final messageType = rawData[0];

    switch (messageType) {
      case ProgressorConstants.weightMeasure:
        _handleWeightMeasurement(rawData);
      case ProgressorConstants.commandResponse:
        _handleCommandResponse(rawData);
      case 5: // calibration factor
        _handleCalibrationResponse(rawData);
      case 6: // calibration point
        _handleCalibrationPointResponse(rawData);
      case ProgressorConstants.lowBatteryWarning:
        _eventController.add(const LowBatteryEvent());
    }
  }

  void _handleWeightMeasurement(List<int> data) {
    if (data.length < 2) return;

    final now = DateTime.now();
    final payload = data.sublist(2);
    if (payload.length % 8 != 0) return;

    final samplesPerPacket = payload.length ~/ 8;
    final bytes = Uint8List.fromList(payload);
    final byteData = ByteData.view(bytes.buffer);

    final measurements = <WeightMeasurement>[];
    for (int i = 0; i < samplesPerPacket; i++) {
      final offset = i * 8;
      measurements.add(WeightMeasurement(
        weight: byteData.getFloat32(offset, Endian.little),
        timestampUs: byteData.getUint32(offset + 4, Endian.little),
        receivedAt: now,
      ));
    }

    if (measurements.isNotEmpty) {
      _eventController.add(WeightEvent(measurements));
    }
  }

  void _handleCommandResponse(List<int> rawData) {
    if (rawData.length < 2) return;

    try {
      final framedPayload = _payloadFromDataMessage(rawData);
      final responseData =
          framedPayload ??
          Uint8List.fromList(
            rawData.length > 1 ? rawData.sublist(1) : const <int>[],
          );
      if (responseData.isEmpty) return;

      // Try firmware version (printable ASCII string).
      try {
        final str =
            String.fromCharCodes(responseData).replaceAll('\x00', '').trim();
        final printable = str.isNotEmpty &&
            str.runes.every(
              (r) => r == 9 || r == 10 || r == 13 || (r >= 32 && r <= 126),
            );
        if (printable) {
          _eventController.add(FirmwareVersionEvent(str));
          return;
        }
      } catch (_) {}

      // Try battery voltage (uint32 LE, millivolts).
      if (responseData.length >= 4) {
        final voltage =
            ByteData.view(responseData.buffer).getUint32(0, Endian.little);
        _eventController.add(BatteryVoltageEvent(voltage));
      }
    } catch (_) {}
  }

  void _handleCalibrationResponse(List<int> rawData) {
    if (rawData.length < 5) return;

    try {
      final responseData = _payloadFromCalibrationMessage(rawData, 4);
      if (responseData == null) return;

      final factor = ByteData.view(responseData.buffer, responseData.offsetInBytes)
          .getFloat32(0, Endian.little);
      _eventController.add(CalibrationFactorEvent(factor));
    } catch (_) {}
  }

  void _handleCalibrationPointResponse(List<int> rawData) {
    if (rawData.length < 9) return;

    try {
      final responseData = _payloadFromCalibrationMessage(rawData, 8);
      if (responseData == null) return;

      final bd =
          ByteData.view(responseData.buffer, responseData.offsetInBytes);
      _eventController.add(CalibrationPointEvent(
        bd.getFloat32(0, Endian.little),
        bd.getFloat32(4, Endian.little),
      ));
    } catch (_) {}
  }

  // ── Private: helpers ─────────────────────────────────────────────

  bool _looksLikeLegacyBatteryFrame(List<int> frame) {
    if (frame.length != 5 ||
        frame.first != ProgressorConstants.commandResponse) {
      return false;
    }
    final voltage =
        frame[1] | (frame[2] << 8) | (frame[3] << 16) | (frame[4] << 24);
    return voltage >= 1000 && voltage <= 10000;
  }

  Uint8List? _payloadFromDataMessage(List<int> rawData) {
    if (rawData.length < 2) return null;
    final payloadSize = rawData[1];
    if (rawData.length < payloadSize + 2) return null;
    return Uint8List.fromList(rawData.sublist(2, payloadSize + 2));
  }

  Uint8List? _payloadFromCalibrationMessage(List<int> rawData, int minBytes) {
    final payloadWithLength = _payloadFromDataMessage(rawData);
    if (payloadWithLength != null && payloadWithLength.length >= minBytes) {
      return payloadWithLength;
    }
    if (rawData.length - 1 < minBytes) return null;
    return Uint8List.fromList(rawData.sublist(1));
  }

  Future<void> _sendCommand(String command) =>
      _transport.write(utf8.encode(command));

  Future<void> _sendControlOpCode(int opCode,
      [List<int> payload = const []]) {
    final data = Uint8List(1 + payload.length);
    data[0] = opCode;
    if (payload.isNotEmpty) data.setRange(1, data.length, payload);
    return _transport.write(data);
  }
}
