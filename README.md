# Crimpdeq App

A Flutter development app for calibrating, testing and communicating with [Crimpdeq](https://crimpdeq.com).

## Features

- Bluetooth Low Energy (BLE) device scanning and connection
- Calibration support, with a check of each point's error against the device calibration
- Real-time weight measurement with min, peak force and peak rate of force development (RFD)
- Measurement reset, tare and selectable sample rate
- Battery voltage and estimated state of charge, with a low battery warning
- Data visualization with charts
- Compatible with Tindeq Progressor API
- Cross-platform support (Android, macOS, Windows, Linux, Web)

## Released Apps

The app is also available via [GitHub Releases](https://github.com/crimpdeq/crimpdeq-app/releases), there you can find Android, Windows, Linux and macOS versions of the app withough building it yourself.

## App Development
As a normal user, you wont need any of this section, this is just meant for the app developers.

### Prerequisites

- Flutter SDK (3.41.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio or Xcode (for mobile development)
- A physical device with Bluetooth capability

### Setup & Installation

#### 1. Clone the Repository

```bash
git clone https://github.com/frez-dong/crimpdeq-app.git
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

- Minimum SDK version: 21
- Target SDK version: 34
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
├── analysis/          # Force stats and RFD, steady load, calibration check, battery
├── constants/         # App constants
├── models/            # State models
├── providers/         # State management (Riverpod)
├── screens/           # Main screen and app bar
└── widgets/           # Connection, measurement, calibration and chart widgets
test/                  # Unit and widget tests
```

#### Key Dependencies

- `flutter_blue_plus`: BLE communication and permission requests
- `flutter_riverpod`: State management
- `fl_chart`: Data visualization
- `permission_handler`: Opening the app settings
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

## GitHub Pages Deployment

This project uses a Makefile for easy building and deployment to GitHub Pages.

### Initial Setup (One-time)

1. **Setup GitHub Pages**:

   ```bash
   make setup-pages
   ```

   Follow the instructions displayed to configure GitHub Pages in your repository settings.

2. **Install Dependencies**:
   ```bash
   make install
   ```

### Deploy

Deploy to GitHub Pages with a single command:

```bash
make deploy
```

This will:

- Clean and build the web app
- Switch to `gh-pages` branch
- Copy build files to the branch root
- Commit and push to GitHub
- Switch back to `main` branch
- Show your app URL

### Available Commands

```bash
make help          # Show all available commands
make install       # Install Flutter dependencies
make build         # Build for production (GitHub Pages)
make build-local   # Build for local testing
make dev           # Run development server (Chrome)
make dev-server    # Run development server (web-server)
make serve-local   # Serve built app locally
make clean         # Clean build files
make clean-pages   # Clean and reset gh-pages branch
make check         # Check Flutter/Dart versions
make deploy        # Build and deploy to GitHub Pages
```

### HTTPS Requirement

- GitHub Pages provides HTTPS by default
- This is required for Web Bluetooth functionality

## Troubleshooting

### Common Issues

1. **Bluetooth not working**: Ensure Bluetooth is enabled and necessary permissions are granted
2. **Device not found**: Make sure the Crimpdeq device is powered on and in pairing mode and also verify that the service UUID in the app matches the Crimpdeq firmware configuration
   - ServiceUUID: `7e4e1701-1ea6-40c9-9dcc-13d34ffead57`
3. **Connection issues**: Try restarting both the app and the device

### Permissions

- **Android 12+**: Nearby devices permission (Bluetooth scan and connect), requested on the first scan
- **Android 11 and older**: Location permission is required for BLE scanning
- **iOS**: Bluetooth permission is automatically requested
- **Web**: Browser must support WebBluetooth API (requires HTTPS)

## Contributing

This is a development tool for the Crimpdeq project. Feel free to:

- Report bugs and issues
- Suggest improvements
- Submit pull requests

## Related Projects

- [Crimpdeq Firmware](https://github.com/crimpdeq/crimpdeq-firmware) - Rust firmware for the device
- [Crimpdeq Book](https://crimpdeq.github.io/book/) - Complete documentation

## License

This project follows the same licensing as the main Crimpdeq project.
