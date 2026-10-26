# Crimpdeq App

A Flutter app for calibrating, testing and communicating with [Crimpdeq](https://crimpdeq.com). Use it in the browser at [app.crimpdeq.com](https://app.crimpdeq.com).

## Features

- Bluetooth Low Energy (BLE) device scanning and connection
- Calibration support, with a check of each point's error against the device calibration
- Real-time weight measurement with min, peak force and peak rate of force development (RFD)
- Measurement reset, tare and selectable sample rate
- Battery voltage and estimated state of charge, with a low battery warning
- Data visualization with charts
- [OpenGrips](https://opengrips.xyz) training with the Crimpdeq as the weight: 5-second-max benchmarks,
  suggested workout types with their target and force curve graphs, the energy-system configuration,
  a timer whose hangs follow the measured force, and a workout history stored on the device
- Compatible with Tindeq Progressor API
- Cross-platform support (Android, macOS, Windows, Linux, Web)

## Released Apps

The web app at [app.crimpdeq.com](https://app.crimpdeq.com) needs no installation. [GitHub Releases](https://github.com/crimpdeq/crimpdeq-app/releases) also include Android, Windows, Linux and macOS builds, so you don't need to build the app yourself.

## App Development
This section is for app developers; you don't need it to use the app.

### Prerequisites

- Flutter SDK (3.47.0 or higher, CI uses 3.47.7)
- Dart SDK (3.13.0 or higher, bundled with Flutter)
- Android Studio or Xcode (for mobile development)
- A physical device with Bluetooth capability

### Setup & Installation

#### 1. Clone the Repository

```bash
git clone https://github.com/crimpdeq/crimpdeq-app.git
cd crimpdeq-app
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Generate Code (after changing models or providers)

```bash
dart run build_runner build --delete-conflicting-outputs
```

#### 4. Platform-specific Setup

##### Android

- Minimum SDK version: 24
- Target SDK version: 36
- Compile SDK version: 37 (Android SDK Platform 37 must be installed)
- Required permissions are automatically handled

##### Web

- Modern web browser with WebBluetooth support (Chrome, Edge)
- HTTPS connection required for Bluetooth access
- Some browsers may have limited BLE support

#### 5. Run the App

```bash
flutter run
```

For specific target:

```bash
flutter run -t lib/main.dart
```

For web:

```bash
flutter run -d web-server --web-port 8080
```

or

```bash
flutter run -d chrome
```

#### Project Structure

```
lib/
├── main.dart          # App entry point
├── app.dart           # MaterialApp
├── theme.dart         # Light and dark themes, bundled fonts
├── protocol/          # Progressor BLE protocol: frames, messages, commands
├── analysis/          # Force stats and RFD, steady load, calibration check, battery, OpenGrips
│                      # force curve and hang timing
├── constants/         # App constants
├── models/            # State models
├── providers/         # State management (Riverpod)
├── screens/           # Main screen and app bar
└── widgets/           # Connection, measurement, calibration, training and chart widgets
test/                  # Unit and widget tests
```

#### Key Dependencies

- `flutter_blue_plus`: BLE communication and permission requests
- `flutter_riverpod`: State management
- `fl_chart`: Data visualization
- `permission_handler`: Opening the app settings
- `shared_preferences`: Storing the training benchmarks and workouts
- `freezed`: Code generation for immutable classes

The Inter and Space Grotesk fonts are bundled in `assets/fonts/` (SIL Open Font License), so the
app renders the same offline.

#### Checks

CI runs these on every pull request:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

#### Update App Icon

To change the app/launcher icons (including web favicons):

1. Replace the source image at `assets/Logo_app_512x512.png` (recommended: 512×512 PNG with transparency).
2. Regenerate icons for all platforms using the configured tool:

```bash
flutter pub get
dart run flutter_launcher_icons
```

This uses the `flutter_launcher_icons` configuration in `pubspec.yaml` to update Android, iOS, macOS, Windows, Linux, and Web assets.

## Web Deployment

Creating a GitHub Release runs `.github/workflows/release.yml`, which builds the native apps
and publishes the web app to [app.crimpdeq.com](https://app.crimpdeq.com) on Cloudflare Pages
(project `crimpdeq-app`). Web Bluetooth needs HTTPS, which Cloudflare Pages provides.

To build and serve the web app locally:

```bash
make install       # Install dependencies and generate code
make dev           # Run in Chrome
make serve-local   # Build into dist/ and serve it on http://localhost:8000
```

## Troubleshooting

### Common Issues

1. **Bluetooth not working**: Ensure Bluetooth is enabled and necessary permissions are granted
2. **Device not found**: Make sure the Crimpdeq device is powered on and advertising (blue status LED), and verify that the service UUID in the app matches the Crimpdeq firmware configuration
   - ServiceUUID: `7e4e1701-1ea6-40c9-9dcc-13d34ffead57`
3. **Connection issues**: Try restarting both the app and the device

### Permissions

- **Android 12+**: Nearby devices permission (Bluetooth scan and connect), requested on the first scan
- **Android 11 and older**: Location permission is required for BLE scanning
- **iOS**: Bluetooth permission is automatically requested
- **Web**: Browser must support WebBluetooth API (requires HTTPS)

## Contributing

Contributions are welcome. Feel free to:

- Report bugs and issues
- Suggest improvements
- Submit pull requests

## Related Projects

- [Crimpdeq Firmware](https://github.com/crimpdeq/crimpdeq-firmware) - Rust firmware for the device
- [Crimpdeq Book](https://book.crimpdeq.com) - Complete documentation

## License

Licensed under either of [Apache License, Version 2.0](LICENSE-APACHE2) or [MIT license](LICENSE-MIT), at your option.
