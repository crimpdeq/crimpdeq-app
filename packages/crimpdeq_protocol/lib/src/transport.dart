/// Minimal abstraction over the BLE write characteristic.
///
/// The app implements this with `flutter_blue_plus`; tests can supply a
/// simple in-memory stub.
abstract interface class BleTransport {
  Future<void> write(List<int> data);
}
