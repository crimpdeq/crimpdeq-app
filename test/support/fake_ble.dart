import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';

/// Bluetooth platform with one Progressor that answers the device info reads
/// like the Crimpdeq firmware.
final class FakeBle extends FlutterBluePlusPlatform {
  static final _remoteId = DeviceIdentifier('00:00:00:00:00:01');
  static final _service = Guid(progressorServiceUuid);
  static final _notifyChar = Guid(progressorNotifyCharUuid);
  static final _writeChar = Guid(progressorWriteCharUuid);

  final _adapterState = StreamController<BmBluetoothAdapterState>.broadcast();
  final _connectionState =
      StreamController<BmConnectionStateResponse>.broadcast();
  final _discoveredServices =
      StreamController<BmDiscoverServicesResult>.broadcast();
  final _received = StreamController<BmCharacteristicData>.broadcast();
  final _written = StreamController<BmCharacteristicData>.broadcast();
  // Never emits: there is no CCCD to write.
  final _descriptorWritten = StreamController<BmDescriptorData>.broadcast();

  /// Every control point write, opcode first.
  final writes = <List<int>>[];

  /// Opcodes the device leaves unanswered.
  final unanswered = <ControlOpCode>{};

  DiscoveredDevice get device => DiscoveredDevice(
    id: _remoteId.str,
    name: 'Progressor',
    rssi: -50,
    device: BluetoothDevice(remoteId: _remoteId),
  );

  int writeCount(ControlOpCode opCode) =>
      writes.where((write) => write.first == opCode.value).length;

  void notify(List<int> value) => _received.add(_data(_notifyChar, value));

  void setConnected(bool connected) => _connectionState.add(
    BmConnectionStateResponse(
      remoteId: _remoteId,
      connectionState: connected
          ? BmConnectionStateEnum.connected
          : BmConnectionStateEnum.disconnected,
      disconnectReasonCode: null,
      disconnectReasonString: null,
    ),
  );

  List<int>? _reply(ControlOpCode opCode) => switch (opCode) {
    ControlOpCode.getAppVersion => [0, 5, ...utf8.encode('2.1.0')],
    ControlOpCode.sampleBattery => [
      0,
      4,
      ...(ByteData(4)..setUint32(0, 3900, Endian.little)).buffer.asUint8List(),
    ],
    ControlOpCode.getBatteryStatus => [8, 2, 80, 0],
    ControlOpCode.getCalibration => [5, 4, ...encodeFloat32(0.08)],
    ControlOpCode.getSampleRate => [7, 2, ...encodeUint16(80)],
    _ => null,
  };

  BmCharacteristicData _data(Guid characteristic, List<int> value) =>
      BmCharacteristicData(
        remoteId: _remoteId,
        primaryServiceUuid: null,
        serviceUuid: _service,
        characteristicUuid: characteristic,
        instanceId: 0,
        value: value,
        success: true,
        errorCode: 0,
        errorString: '',
      );

  BmBluetoothCharacteristic _characteristic(
    Guid uuid, {
    bool notify = false,
    bool write = false,
  }) => BmBluetoothCharacteristic(
    remoteId: _remoteId,
    primaryServiceUuid: null,
    serviceUuid: _service,
    characteristicUuid: uuid,
    instanceId: 0,
    descriptors: const [],
    properties: BmCharacteristicProperties(
      broadcast: false,
      read: false,
      writeWithoutResponse: false,
      write: write,
      notify: notify,
      indicate: false,
      authenticatedSignedWrites: false,
      extendedProperties: false,
      notifyEncryptionRequired: false,
      indicateEncryptionRequired: false,
    ),
  );

  @override
  Stream<BmBluetoothAdapterState> get onAdapterStateChanged =>
      _adapterState.stream;

  @override
  Stream<BmConnectionStateResponse> get onConnectionStateChanged =>
      _connectionState.stream;

  @override
  Stream<BmDiscoverServicesResult> get onDiscoveredServices =>
      _discoveredServices.stream;

  @override
  Stream<BmCharacteristicData> get onCharacteristicReceived => _received.stream;

  @override
  Stream<BmCharacteristicData> get onCharacteristicWritten => _written.stream;

  @override
  Stream<BmDescriptorData> get onDescriptorWritten => _descriptorWritten.stream;

  @override
  Future<bool> isSupported(BmIsSupportedRequest request) async => true;

  @override
  Future<BmBluetoothAdapterState> getAdapterState(
    BmBluetoothAdapterStateRequest request,
  ) async => BmBluetoothAdapterState(adapterState: BmAdapterStateEnum.on);

  @override
  Future<bool> connect(BmConnectRequest request) async {
    setConnected(true);
    return true;
  }

  @override
  Future<bool> disconnect(BmDisconnectRequest request) async {
    setConnected(false);
    return true;
  }

  @override
  Future<bool> discoverServices(BmDiscoverServicesRequest request) async {
    _discoveredServices.add(
      BmDiscoverServicesResult(
        remoteId: _remoteId,
        services: [
          BmBluetoothService(
            remoteId: _remoteId,
            primaryServiceUuid: null,
            serviceUuid: _service,
            characteristics: [
              _characteristic(_notifyChar, notify: true),
              _characteristic(_writeChar, write: true),
            ],
          ),
        ],
        success: true,
        errorCode: 0,
        errorString: '',
      ),
    );
    return true;
  }

  /// Without a CCCD, notifications are enabled at once.
  @override
  Future<bool> setNotifyValue(BmSetNotifyValueRequest request) async => false;

  @override
  Future<bool> writeCharacteristic(BmWriteCharacteristicRequest request) async {
    writes.add(request.value);
    _written.add(_data(_writeChar, request.value));
    final opCode = ControlOpCode.values
        .where((opCode) => opCode.value == request.value.first)
        .single;
    final reply = _reply(opCode);
    if (reply != null && !unanswered.contains(opCode)) notify(reply);
    return true;
  }
}
