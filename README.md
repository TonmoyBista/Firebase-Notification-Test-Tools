# FCM v1 Mobile App Notification Tester 🚀

A cross-platform Flutter application built with **Clean Architecture + Domain-Driven Design (DDD) + MVVM** for testing Firebase Cloud Messaging (FCM) v1 notifications directly to mobile devices.

---

## ✨ Features

- **Service Account Private Key Selection**:
  - Load your Firebase Service Account JSON (`private_key.json`) via native file picker or paste the raw JSON text.
  - Automatically extracts `project_id`, `client_email`, and signs a JWT to retrieve an OAuth 2.0 Bearer token (`https://www.googleapis.com/auth/firebase.messaging` scope).
  - Inspect, copy, and refresh the active Bearer token at any time.

- **FCM HTTP v1 API Send Integration**:
  - Direct calls to `https://fcm.googleapis.com/v1/projects/{project_id}/messages:send`.
  - Supports targeting via:
    - **Device Registration Token** (single device testing)
    - **Topic** (e.g., `news`, `all`)
    - **Condition** (e.g., `'sports' in topics || 'tech' in topics`)

- **Flexible Payload Builder & Two-Way Sync**:
  - **Visual Form Mode**: Edit Title, Body, Image URL, Android Priority (`high`/`normal`), iOS APNs badge, and custom key-value data fields.
  - **Raw JSON Mode**: Directly modify the full JSON payload with live JSON syntax validation and a 1-click **Prettify** formatter.
  - Real-time two-way synchronization between visual form fields and the raw JSON payload.

- **Raw Server Response Viewer**:
  - Displays the exact raw HTTP response body returned from Firebase servers.
  - Displays HTTP status code (`200 OK`, `400 BAD_REQUEST`, `401 UNAUTHENTICATED`, `404 NOT_FOUND`), network latency in milliseconds (`⚡ ms`), and full HTTP response headers.
  - Extracted FCM message ID or formatted error banner.
  - 1-Click Copy for Raw Response, Formatted JSON, and generated `cURL` command for CLI debugging.

- **Preset Templates & History**:
  - Quick presets: *Standard Alert*, *Data-Only (Silent)*, *Rich Image*, *iOS Badge*.
  - Persistent test execution history drawer to review past tests, latencies, status codes, and reload previous payloads in 1 click.

---

## 🏛️ Architecture: MVVM + DDD + Clean Code

```
lib/
├── core/
│   ├── constants/             # API URLs, scopes, storage keys
│   ├── errors/                # Failures and exceptions
│   ├── theme/                 # AppTheme (Dark & Light Material 3)
│   └── utils/                 # JsonUtils (prettify, validate, cURL builder)
└── features/notification_tester/
    ├── domain/                # Enterprise & Business Logic (DDD)
    │   ├── entities/          # ServiceAccount, FcmMessage, FcmResponse, AuthToken, History
    │   ├── repositories/      # IFcmRepository, IStorageRepository
    │   └── usecases/          # ParseServiceAccount, GetAccessToken, SendFcmNotification, ManageHistory
    ├── data/                  # Data Layer
    │   ├── models/            # ServiceAccountModel, FcmResponseModel, HistoryItemModel
    │   ├── datasources/       # FcmRemoteDataSource (googleapis_auth + HTTP), LocalStorageDataSource
    │   └── repositories/      # FcmRepositoryImpl, StorageRepositoryImpl
    └── presentation/          # Presentation Layer (MVVM)
        ├── viewmodels/        # NotificationTesterViewModel (ChangeNotifier)
        └── views/
            ├── home_screen.dart # Responsive desktop/mobile screen
            └── widgets/       # ServiceAccountCard, VisualPayloadEditor, RawJsonEditor,
                               # RawResponseView, TargetTypeSelector, HistoryDrawer
```

---

## 🖥️ Platform Support

The application supports all major platforms:
- **macOS** (Apple Silicon `arm64` & Intel `x86_64`)
- **iOS**
- **Android**
- **Linux**
- **Windows**

---

## 📦 Installation Packages

### macOS (Universal: Intel `x86_64` & Apple Silicon `arm64`)
The macOS release is a Universal binary that natively runs on both Intel processors (`x86_64`) and Apple Silicon (`arm64`):
* `Firebase_Notification_Test_Tools_macOS_Universal.dmg`
* `Firebase_Notification_Test_Tools_macOS_Intel_x86_64.dmg`
* `Firebase_Notification_Test_Tools_macOS_Silicon.dmg`

To install:
1. Double-click the DMG file.
2. Drag `Firebase Notification Test Tools` into your `Applications` folder.

### Linux (Ubuntu 22.04 LTS / 24.04 LTS, Debian, Intel/AMD `x86_64`)
Install runtime dependencies:
```bash
sudo apt update
sudo apt install -y libgtk-3-0 zenity xdg-utils
```
Install the Debian `.deb` package (Intel/AMD `x86_64` / `amd64`):
```bash
sudo dpkg -i Firebase_Notification_Test_Tools_Linux_amd64.deb
# If there are any missing dependencies:
sudo apt-get install -f
```
Or use the standalone portable archive (no root required):
```bash
tar -xvf Firebase_Notification_Test_Tools_Linux_x64.tar.gz
./firebase_notification_test_tools
```

### Windows (Intel/AMD `x86_64`)
* **Installer:** `Firebase_Notification_Test_Tools_Windows_Setup.exe`
* **Portable ZIP:** `Firebase_Notification_Test_Tools_Windows_x64.zip`

### Android (ARM64, ARMv7, and Intel `x86_64` Emulators)
* **Universal (All CPUs):** `Firebase_Notification_Test_Tools_Android_Universal.apk`
* **Intel x86_64 (Emulators / Intel tablets):** `Firebase_Notification_Test_Tools_Android_Intel_x86_64.apk`
* **ARM64 Mobile Devices:** `Firebase_Notification_Test_Tools_Android_arm64.apk`

---

## 🚀 Running from Source

### Prerequisites for Linux (Ubuntu / Debian)
```bash
sudo apt update
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev zenity
```

### Commands
```bash
# Get dependencies
flutter pub get

# Run all unit and widget tests
flutter test

# Run on Linux desktop
flutter run -d linux

# Run on macOS desktop
flutter run -d macos

# Run on Android emulator/device
flutter run -d android

# Run on iOS simulator/device
flutter run -d ios

# Build release Linux application
flutter build linux --release

# Build release macOS application
flutter build macos --release
```
