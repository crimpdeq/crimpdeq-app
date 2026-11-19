# Crimpdeq App

A Flutter app for calibrating, testing and communicating with [Crimpdeq](https://crimpdeq.com). Use it in the browser at [app.crimpdeq.com](https://app.crimpdeq.com).

## Features

- Bluetooth Low Energy (BLE) device scanning and connection, reconnecting to the last device
  at the start and on each scan until you disconnect it
- Calibration support, with a check of each point's calibration-fit residual against the device calibration
- Selectable linear, quadratic or two-segment piecewise linear calibration, fitted by the firmware
  (see [Calibration models](#calibration-models)), with the calibrated range and readings outside
  it flagged
- Real-time weight measurement with min, peak force and peak rate of force development (RFD)
- Measurement reset, tare and selectable sample rate
- Battery voltage and estimated state of charge, with a low battery warning
- Data visualization with charts
- Training, following [OpenGrips](https://opengrips.xyz) with the Crimpdeq as the weight, on the
  navigation bar:
  - Warm-up: before climbing (Spark, then Photon) or before gripper training (a ramp on one
    tool, with a short 85% hold for heavy sessions, on by itself before a Power/Strength or
    Power workout), both hands alternating at fractions of the
    benchmarks. Each hand rests at least 15 s between its holds, usually during the other hand's
    hold, so the next hold starts when you pull. Each hold ends at its target, never at failure, with the same timer and live
    graph as a workout, and a warning with a low double beep when the force overshoots. A training warm-up ends with a
    2 min rest countdown before the workout, which the Workout page keeps counting. After a
    climbing warm-up, an optional readiness
    check pulls Photon as hard as possible with each hand; its best 5 s against the benchmark is
    stored as a readiness history, apart from benchmarks and workouts. The Readiness card also
    runs one on its own, such as after warming up on the wall
  - Workout: the suggested workout type with its targets, a Start button above the fold, and a
    full-screen timer with sound cues and the screen kept on. Each hold waits for a pull above a
    threshold (2 kg by default, set in Settings), even once its rest is over, and a live graph
    shows the last 15 s of force with the current reading and a Tare button. A workout trains one
    hand or both, each at its own benchmark: in turn (every rep of one hand, then the other) or
    alternating after each rep, where the other hand holds during each rest. Alternating needs a
    rest between reps longer than the longest hold plus 5 s to change hands each way, so each hand
    still rests as planned. Each hand saves its own workout. A rep more than 3 s short of its
    target, such as a pull ended by accident, can be redone during the rest after it, so a
    short first hold does not scale down the later targets. Stopping a workout saves or
    discards the reps done, and results not saved yet are still there when the app reopens
  - Benchmarks: 5-second-max pulls, with the same live graph, or held weights; each tool shows the
    personal best of each hand, their progress over time and the history
  - History: workouts on each tool's force curve, and a log like Frez's: each workout with both
    hands together, its time, time under load, effort, workload (force × time held) and place in
    its month; each hand's force, holds and change since its previous workout of the same type;
    and in its details,
    every rep's target, time held and force, stored on the device
- Schedule, in the app bar menu: the rest between gripper workouts (1 h by default, as HoG
  Academy sets for the first 30 sessions on each gripper), which the Workout page counts down
  before a workout with the other gripper, optionally with a notification when it is over; and
  weekly reminders per gripper, such as Spark at 10:00 and Photon at 15:00 on Monday, Wednesday
  and Friday (Android, iOS and macOS)
- Body weight, in the app bar menu: an optional log, one weight per day, stored on the device.
  Benchmarks and workout details show their force as a share of the latest body weight on or
  before their day, such as 64% BW
- Settings, in the app bar menu: the theme (system, light or dark) and the hold threshold
- Device tools, in the app bar menu: calibration and measurements
- Compatible with Tindeq Progressor API
- Cross-platform support (Android, macOS, Windows, Linux, Web)

## Calibration models

The firmware fits and applies the calibration; the app selects the model, waits for the device to
confirm it, and shows what the device reports: the model in use, the calibrated range, each point's
fitted load and residual, and the RMS and largest residual. Residuals show how well the curve
follows the calibration points, not the accuracy at other loads.

| Model            | Use                                      | Needs                                        |
| ---------------- | ---------------------------------------- | -------------------------------------------- |
| Linear           | Same sensitivity at every load (default) | 2 loads; a third checks the fit              |
| Quadratic        | Sensitivity that changes gradually       | 4 loads, one in the middle half of the range |
| Piecewise linear | Sensitivity that changes around one load | 6 loads, 3 on each side of the break         |

Points that the selected model cannot fit yet are stored on the device, which keeps the previous
calibration and reports why. **Tare** subtracts an attached load; **Set Unloaded Zero** re-anchors
the curve at the unloaded reading to follow drift, and the device rejects it when a load is
attached. Readings whose absolute load, the reading plus the load at the tare, lies outside the
calibrated range are flagged as extrapolated in the Measurements tab.

The app reads the calibration from the device on each connection. Firmware without calibration
models does not answer the details request, so the app falls back to the linear factor and offers
only the linear model. The BLE commands are documented in the firmware's
[`calibration/README.md`](https://github.com/crimpdeq/crimpdeq-firmware/blob/main/calibration/README.md).

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
- Required permissions are automatically handled. Notifications, and exact alarms so they
  arrive on time, are requested when you add a reminder or turn on the rest notification

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
│                      # force curve, hold timing and the live force trace
├── constants/         # App constants
├── models/            # State models
├── providers/         # State management (Riverpod)
├── screens/           # Training pages with the app bar, and the device tools
└── widgets/           # Connection, measurement, calibration, training and chart widgets
test/                  # Unit and widget tests
```

#### Key Dependencies

- `flutter_blue_plus`: BLE communication and permission requests
- `flutter_riverpod`: State management
- `fl_chart`: Data visualization
- `permission_handler`: Opening the app settings
- `shared_preferences`: Storing the training benchmarks, workouts, readiness checks and body
  weights
- `audioplayers`: Workout sound cues (needs GStreamer to build for Linux)
- `wakelock_plus`: Keeping the screen on during a workout
- `flutter_local_notifications`, `timezone`, `flutter_timezone`: Training reminders and the end
  of the rest between grippers, at local time
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

`integration_test/board_test.dart` runs the app against a device in range: it connects, measures,
records a benchmark, and runs workouts, including tares, a disconnect and the 1000 SPS sample rate,
which it restores. The macOS build migrates the project files in `macos/`; do not commit them. It expects the simulated pulls of the
[firmware](https://github.com/crimpdeq/crimpdeq-firmware) built with `--features esp-rust-board`:

```bash
flutter test integration_test/board_test.dart -d macos --dart-define=DEVICE_NAME=Progressor_7125
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
