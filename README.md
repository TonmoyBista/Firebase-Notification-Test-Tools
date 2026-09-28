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

## 📦 macOS Apple Silicon DMG Installer

A standalone compressed DMG installer for Mac Silicon is located in:
```
dist/Firebase_Notification_Tester_macOS_Silicon.dmg
```
To install:
1. Double click `dist/Firebase_Notification_Tester_macOS_Silicon.dmg`.
2. Drag `Firebase Notification Tester` into your `Applications` folder.

---

## 🚀 Running from Source

```bash
# Get dependencies
flutter pub get

# Run all unit and widget tests
flutter test

# Run on macOS desktop
flutter run -d macos

# Run on Android emulator/device
flutter run -d android

# Run on iOS simulator/device
flutter run -d ios

# Build release macOS application
flutter build macos --release
```
