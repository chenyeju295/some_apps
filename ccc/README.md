# Fashion Wallpaper 🎨

AI-powered fashion beauty wallpaper app built with Flutter, GetX, and GetStorage.

> 一款基于 AI 生成的"时尚美女壁纸"App，用户可通过输入或选择关键词，让 AI 生成不同风格的美女与服装搭配场景壁纸。

## ✨ Features

- 🎨 **AI-Powered Generation**: Create unique fashion wallpapers
- 📱 **3-Tab Navigation**: Home, Create (floating button), Profile
- 💎 **Token System**: Built-in token management
- 🖼️ **Gallery Management**: Save, organize, and favorite wallpapers
- 🎭 **Style Options**: 6 styles, 8 outfit types, 8 scenes
- 💾 **Local Storage**: Persistent data with GetStorage
- 🎯 **Modern UI**: Beautiful Material Design 3 with animations
- ✨ **Enhanced Effects**: Glassmorphism, smooth animations

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.9.2+)
- Xcode (for iOS)
- CocoaPods

### Installation

```bash
# Clone repository
cd /path/to/ccc

# Accept Xcode license
sudo xcodebuild -license

# Install dependencies
flutter pub get
cd ios && pod install && cd ..

# Run
flutter run
```

## 🏗️ Architecture

**GetX Pattern** for clean, scalable code:
- State Management: GetX Controllers
- Routing: GetX Navigation
- Storage: GetStorage
- API: Ready for integration

## 📁 Project Structure

```
lib/
├── app/
│   ├── data/           # Models, Services
│   ├── modules/        # Home, Gallery+Generate, Profile
│   ├── routes/         # Navigation
│   └── widgets/        # Shared components
├── core/
│   ├── theme/          # App theme
│   └── values/         # Constants, colors
└── main.dart
```

## 🛠️ Tech Stack

- **Flutter**: Cross-platform framework
- **GetX**: State management & routing
- **GetStorage**: Local storage
- **Google Fonts**: Poppins typography
- **Font Awesome**: Icon library
- **Animations**: flutter_animate, glassmorphism
- **Images**: cached_network_image

## ⚙️ Configuration

### 1. AI API (Required)

Edit `lib/core/values/app_constants.dart`:

```dart
static const String apiBaseUrl = 'YOUR_API_URL';
static const String apiKey = 'YOUR_API_KEY';
```

See [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md) for details.

### 2. In-App Purchase

Update product IDs in `app_constants.dart` to match App Store Connect.

### 3. iOS Permissions

Already configured in `ios/Runner/Info.plist`:
- Photo library access
- App Tracking Transparency

## 🎯 Current Status

✅ **Complete**: Architecture, UI, Navigation, Storage  
⏳ **Pending**: AI API integration, IAP implementation

## 📱 App Structure

### 3-Tab Navigation
- **Home**: Featured wallpapers, quick actions
- **Create** (Center Button): Gallery + Generate (tabs)
- **Profile**: Settings, tokens, stats

### Features
- Token system (100 free tokens)
- Style categories and filters
- Favorites collection
- Save to device & share
- Glassmorphism effects
- Smooth animations

## 🧪 Testing

```bash
flutter test
flutter analyze
```

## 📦 Build

```bash
# Debug
flutter run

# Release (iOS)
flutter build ios --release
```

## 📚 Documentation

- [REQUIREMENTS.md](REQUIREMENTS.md) - Product requirements
- [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md) - API setup

## 🎨 Design

- **Colors**: Pink (#FF6B9D), Purple (#9B59B6), Gold (#FFD700)
- **Typography**: Poppins (Google Fonts)
- **Style**: Material Design 3, iOS-inspired

## 📄 License

MIT License

---

**Status**: 🚀 Ready for AI API integration  
**Version**: 1.0.0  
**Last Updated**: October 9, 2025
