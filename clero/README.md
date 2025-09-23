# AI Wallpaper Generator

An AI-powered iOS application that generates beautiful wallpapers using custom prompts and predefined themes. Users can create stunning backgrounds for their devices with themes like nature, city, space, and more.

## Features

### 🎨 AI-Powered Generation
- Generate wallpapers using OpenAI's DALL-E 3 API
- **NEW**: Dedicated generation page with advanced features
- **NEW**: 12 enhanced categories including Portrait & Beauty, Fashion, Anime, Gaming
- Custom prompt input with 500 character limit
- Multiple preset prompts per category (8+ prompts each)
- **NEW**: Batch generation capability (up to 5 wallpapers)
- **NEW**: Advanced settings: Image size, Art style, Quality selection

### 📱 User-Friendly Interface
- **NEW**: Redesigned home page with clean navigation
- **NEW**: Dedicated generation workspace with advanced controls
- Modern Material Design 3 UI
- Dark and light theme support
- **NEW**: Enhanced category selection with visual previews
- Beautiful gradient backgrounds and animations
- **NEW**: Bottom navigation bar for easy access

### ⭐ Wallpaper Management
- Save favorite wallpapers locally
- View generation history
- Share wallpapers with friends
- Download wallpapers to device gallery

### 🔧 Technical Features
- GetX state management for reactive UI
- GetStorage for local data persistence
- Cached network images for better performance
- Proper error handling and loading states

## Installation

### Prerequisites
- Flutter SDK (>=3.6.2)
- Xcode (for iOS development)
- OpenAI API key

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd clero
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   - Get your OpenAI API key from [platform.openai.com](https://platform.openai.com)
   - Open the app and go to Settings
   - Enter your API key in the "OpenAI API Key" section

4. **Run the app**
   ```bash
   flutter run
   ```

## Architecture

This app follows the GetX pattern for clean architecture:

```
lib/
├── app/
│   ├── bindings/          # GetX bindings
│   ├── constants/         # App constants
│   ├── controllers/       # GetX controllers
│   ├── models/           # Data models
│   ├── routes/           # Navigation routes
│   ├── services/         # Business logic services
│   ├── theme/            # App themes
│   ├── views/            # UI screens
│   └── widgets/          # Reusable widgets
└── main.dart
```

### Key Components

- **HomeController**: Manages wallpaper generation and theme selection
- **FavoritesController**: Handles favorite wallpapers management
- **SettingsController**: Manages app settings and preferences
- **StorageService**: Local data persistence using GetStorage
- **AIService**: Integration with OpenAI DALL-E API

## Usage

### Generating Wallpapers (NEW Enhanced Workflow)

1. **Access Generation**: Tap "Create Wallpaper" on home page or use bottom navigation
2. **Configure Settings**: 
   - Choose image size (Portrait/Square/Landscape)
   - Select art style (Realistic/Artistic/Anime/Fantasy/Vintage/Modern)
   - Pick quality (Standard/HD)
3. **Select Category**: Choose from 12 categories including new Portrait, Fashion, Anime, Gaming
4. **Choose Prompts**: 
   - Select multiple preset prompts (8+ per category)
   - Use "Select All" or customize your selection
   - Or write custom prompts (up to 500 characters)
5. **Generate**: 
   - Single generation with custom prompt
   - Generate with selected prompts
   - Random generation from category
   - **NEW**: Batch generate up to 5 wallpapers

### Managing Wallpapers

- **Favorites**: Tap the heart icon to save wallpapers to favorites
- **Download**: Save wallpapers to your device gallery
- **Share**: Share wallpapers with friends via social media
- **History**: View all your previously generated wallpapers

### Settings

- **Dark Mode**: Toggle between light and dark themes
- **API Key**: Configure your OpenAI API key
- **Data Management**: Clear favorites, history, or all app data

## Dependencies

### Core Dependencies
- `get: ^4.6.6` - State management and dependency injection
- `get_storage: ^2.1.1` - Local storage solution
- `dio: ^5.4.0` - HTTP client for API calls
- `cached_network_image: ^3.3.1` - Image caching

### UI Dependencies
- `flutter_staggered_grid_view: ^0.7.0` - Grid layouts
- `shimmer: ^3.0.0` - Loading animations

### Utility Dependencies
- `share_plus: ^7.2.2` - Sharing functionality
- `image_gallery_saver: ^2.0.3` - Save images to gallery
- `permission_handler: ^11.3.0` - Handle device permissions
- `path_provider: ^2.1.2` - File system paths

## API Configuration

This app uses OpenAI's DALL-E 3 API for image generation. You'll need:

1. An OpenAI account
2. API access with billing setup
3. A valid API key

### API Endpoints Used
- `POST /v1/images/generations` - Generate images with DALL-E 3

### Image Parameters
- **Model**: dall-e-3
- **Size**: 1024x1792 (optimized for phone wallpapers)
- **Quality**: HD
- **Response Format**: URL

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions:
- Create an issue in the repository
- Check the documentation
- Review the code comments

## Screenshots

*Add screenshots of your app here*

## Roadmap

- [ ] Add more image size options
- [ ] Implement image editing features
- [ ] Add wallpaper categories filtering
- [ ] Implement user accounts and cloud sync
- [ ] Add batch generation features
- [ ] Support for different AI models

---

Built with ❤️ using Flutter and OpenAI DALL-E