# Crimpdeq App

A Flutter development app for testing and communicating with [Crimpdeq](https://github.com/crimpdeq/crimpdeq-firmware) - a Bluetooth Low Energy dynamometer designed for finger strength training.

## About

Crimpdeq is a dynamometer device powered by ESP32-C3 and WH-C100 crane scale with firmware written in Rust. This Flutter app serves as a development tool to test BLE communication and supports the Tindeq Progressor API.

## Features

- Bluetooth Low Energy (BLE) device scanning and connection
- Real-time weight measurement display
- Data visualization with charts
- Compatible with Tindeq Progressor API
- Cross-platform support (Android, iOS, macOS, Windows, Linux, Web)

## Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio or Xcode (for mobile development)
- A physical device with Bluetooth capability

## Setup & Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd crimpdeq
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code (if needed)

```bash
flutter packages pub run build_runner build
```

### 4. Platform-specific Setup

#### Android

- Minimum SDK version: 21
- Target SDK version: 34
- Required permissions are automatically handled

#### iOS

- Minimum iOS version: 12.0
- Bluetooth permissions are automatically requested

#### Web

- Modern web browser with WebBluetooth support (Chrome, Edge)
- HTTPS connection required for Bluetooth access
- Some browsers may have limited BLE support

### 5. Run the App

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

## Usage

1. **Launch the app** - The app will request necessary permissions (location for Android, Bluetooth for iOS)
2. **Scan for devices** - Tap "Scan" to search for available Crimpdeq devices
3. **Connect** - Select and connect to your Crimpdeq device
4. **Start measuring** - Use the measurement controls to start/stop data collection
5. **View data** - Monitor real-time weight data and charts

## Development

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── progressor_app.dart      # Main app widget
├── constants/               # App constants
├── models/                  # Data models
├── providers/               # State management (Riverpod)
└── widgets/                 # UI components
    ├── chart_widgets.dart
    ├── connection_widgets.dart
    ├── data_widgets.dart
    ├── device_widgets.dart
    ├── measurement_widgets.dart
    └── progressor_widgets.dart
```

### Key Dependencies

- `flutter_blue_plus`: BLE communication
- `hooks_riverpod`: State management
- `fl_chart`: Data visualization
- `permission_handler`: Runtime permissions
- `freezed`: Code generation for immutable classes

### Building for Release

#### Android APK

```bash
flutter build apk --release
```

#### iOS

```bash
flutter build ios --release
```

#### Web

```bash
flutter build web --release
```

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

### Deployment

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

- **Android**: Location permission is required for BLE scanning
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
