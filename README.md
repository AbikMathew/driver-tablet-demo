# Driver Tablet Demo - Flutter Project

This is a comprehensive Flutter project designed for iPad tablets, implementing a driver management system with advanced features including offline support, maps integration, calendar scheduling, and real-time tracking.

## 🏗️ Project Architecture

This project follows a **Clean Architecture** pattern with **Riverpod** for state management:

```
lib/
├── core/                      # Core application logic
│   ├── constants/            # App constants and themes
│   ├── network/              # HTTP clients and interceptors  
│   ├── services/             # App-wide services
│   ├── storage/              # Local storage implementations
│   └── utils/                # Utility functions
├── features/                 # Feature-based modules
│   ├── auth/                 # Authentication feature
│   │   ├── data/            # Data sources & repositories
│   │   ├── domain/          # Business logic & entities
│   │   └── presentation/    # UI & state management
│   ├── calendar/            # Calendar & scheduling
│   ├── dashboard/           # Main dashboard
│   ├── jobs/                # Job management
│   ├── maps/                # Maps & navigation
│   └── settings/            # App settings
└── shared/                  # Shared across features
    ├── models/              # Common data models
    ├── providers/           # Global Riverpod providers
    └── widgets/             # Reusable UI components
```

## 📦 Key Features

### ✅ Completed Setup
- [x] Project structure with Clean Architecture
- [x] iPad-responsive UI design  
- [x] Theme configuration with tablet considerations
- [x] Basic navigation structure
- [x] Core screen layouts (Login, Dashboard, Calendar, Maps, Jobs, Settings)

### 🚧 To Be Implemented
- [ ] **Authentication**: Phone + OTP login with JWT
- [ ] **Calendar Integration**: Syncfusion calendar with availability management  
- [ ] **Maps & Routing**: Flutter Map with offline tile caching
- [ ] **Offline Support**: Hive storage with auto-sync capabilities
- [ ] **Notifications**: Local and push notifications with deep linking
- [ ] **Text-to-Speech**: Turn-by-turn navigation and accessibility
- [ ] **Background Services**: Location tracking and data sync

## 🛠️ Installation & Setup

### 1. Install Dependencies

Run the following command to install all required packages:

```bash
flutter pub get
```

### 2. Generate Code

Some packages require code generation. Run:

```bash
flutter packages pub run build_runner build
```

### 3. Platform-Specific Setup

#### iOS Setup
1. **Permissions**: Add location permissions to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access for navigation.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs location access for background tracking.</string>
```

2. **Firebase** (when implementing notifications):
   - Add `GoogleService-Info.plist` to `ios/Runner/`

#### Android Setup
1. **Permissions**: Already configured in `android/app/src/main/AndroidManifest.xml`
2. **Firebase** (when implementing notifications):
   - Add `google-services.json` to `android/app/`

### 4. Run the Project

```bash
flutter run
```

## 📱 Target Devices

- **Primary**: iPad (10"-13") in portrait and landscape
- **Screen Sizes**: Optimized for 768px+ width
- **Touch Targets**: Minimum 44pt following Apple HIG

## 🔧 Development Workflow

### Implementing New Features

1. **Create Feature Structure**:
```
features/new_feature/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

2. **Use Riverpod Providers**:
```dart
@riverpod
class FeatureNotifier extends _$FeatureNotifier {
  @override
  Future<FeatureState> build() async {
    // Implementation
  }
}
```

3. **Follow Naming Conventions**:
   - Files: `snake_case.dart`
   - Classes: `PascalCase`
   - Variables/Functions: `camelCase`
   - Constants: `SCREAMING_SNAKE_CASE`

### Code Generation Commands

```bash
# Generate once
flutter packages pub run build_runner build

# Watch for changes (recommended during development)
flutter packages pub run build_runner watch

# Clean and regenerate
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 🏆 Learning Objectives

This project is designed to learn and master:

1. **Riverpod**: Advanced state management patterns
2. **Flutter Map**: Interactive maps with custom tiles and overlays
3. **Offline-First**: Data synchronization and caching strategies  
4. **Calendar Integration**: Complex scheduling UI with Syncfusion
5. **Background Services**: Location tracking and data sync
6. **Responsive Design**: iPad-optimized layouts and navigation
7. **Clean Architecture**: Scalable project organization
8. **Performance**: Efficient rendering and memory management

## 🚀 Next Steps

1. **Install packages**: Run `flutter pub get`
2. **Implement Authentication**: Start with login screen and OTP verification
3. **Set up Riverpod**: Configure providers and state management
4. **Add Maps**: Integrate Flutter Map with basic functionality
5. **Implement Calendar**: Add Syncfusion calendar with scheduling
6. **Offline Support**: Set up Hive storage and sync mechanisms

## 📚 Package Documentation

Key packages and their documentation:
- [Riverpod](https://riverpod.dev/) - State management
- [Flutter Map](https://docs.fleaflet.dev/) - Interactive maps
- [Syncfusion Calendar](https://help.syncfusion.com/flutter/calendar/overview) - Calendar widget
- [Hive](https://docs.hivedb.dev/) - Local storage
- [Go Router](https://pub.dev/packages/go_router) - Navigation

---

**Ready to start building?** Run `flutter pub get` and begin with the authentication feature!
