# Fashion Wallpaper App - Requirements Document

## 1. Product Overview

### 1.1 Basic Information
- **App Name**: Fashion Wallpaper
- **Description**: An AI-powered fashion beauty wallpaper app where users can input or select keywords to generate wallpapers featuring beautiful women with various fashion outfit matching scenes.
- **Core Values**: Beauty + Fashion + Personality
- **Target Users**: Fashion enthusiasts, wallpaper collectors, style inspiration seekers
- **Platform**: iOS (Flutter)

### 1.2 Market Positioning
- **Target Market**: iOS App Store (Global Market)
- **Competitive Advantage**: AI-generated personalized fashion wallpapers
- **Monetization**: Token-based system with in-app purchases

## 2. Functional Requirements

### 2.1 Overall Architecture
- **Navigation**: Bottom Tab Navigation with 4 main pages
  - Home: Featured wallpapers and trending styles
  - Gallery: User's saved and generated wallpapers
  - Generate: AI wallpaper generation interface
  - Profile: User settings and token management

### 2.2 Core Feature Modules

#### 2.2.1 AI Wallpaper Generation
- **Features**:
  - Input custom keywords (e.g., "elegant evening dress", "casual street style")
  - Select from predefined style tags (vintage, modern, bohemian, minimalist, etc.)
  - Choose outfit types (dress, casual, business, sportswear, etc.)
  - Select scene settings (urban, beach, garden, indoor, etc.)
  - Generate high-quality fashion wallpapers
  - Each generation costs 1 token

- **User Flow**:
  - Enter generation page
  - Input/select keywords and preferences
  - Tap generate button
  - System checks token balance
  - Call AI API to generate image
  - Display result and save to gallery
  - Deduct 1 token

- **UI Requirements**:
  - Clean, modern interface
  - Tag selection with visual icons
  - Real-time preview placeholder
  - Loading animation during generation
  - Error handling with clear messages

#### 2.2.2 Token & In-App Purchase System
- **Features**:
  - Token balance display
  - Purchase tokens through IAP
  - New users receive 100 free tokens
  - Transaction history

- **IAP Products** (Fixed configuration):
  - Product 1: $2.99 → 500 tokens
  - Product 2: $4.99 → 1000 tokens
  - Product 3: $9.99 → 2500 tokens
  - Product 4: $19.99 → 6000 tokens
  - Product 5: $49.99 → 18000 tokens

- **User Flow**:
  - Tap token balance or "Get Tokens" button
  - View available packages
  - Select package
  - Complete Apple Pay transaction
  - Tokens credited to account

#### 2.2.3 Wallpaper Gallery
- **Features**:
  - Grid view of generated wallpapers
  - Full-screen preview
  - Save to device photo library
  - Share to social media
  - Delete unwanted wallpapers
  - Filter by date, style, or favorites

- **User Actions**:
  - View: Tap to open full-screen preview
  - Save: Download to device
  - Share: Share via iOS share sheet
  - Favorite: Mark as favorite for quick access
  - Delete: Remove from gallery

#### 2.2.4 Style Categories & Inspiration
- **Features**:
  - Curated style collections
  - Trending fashion keywords
  - Popular outfit combinations
  - Quick generate from templates

- **Categories**:
  - Elegant & Formal
  - Casual & Street
  - Vintage & Retro
  - Minimalist & Modern
  - Bohemian & Free
  - Athletic & Sporty

#### 2.2.5 User Profile & Settings
- **Features**:
  - Token balance display
  - Generation history
  - Favorite styles
  - Privacy settings
  - About page
  - Terms & Privacy Policy

## 3. Data Models

### 3.1 User Model
```dart
class User {
  String id;
  int tokenBalance;
  DateTime createdAt;
  int totalGenerations;
  List<String> favoriteStyles;
}
```

### 3.2 Wallpaper Model
```dart
class Wallpaper {
  String id;
  String imageUrl;
  String localPath;
  String prompt;
  List<String> tags;
  DateTime createdAt;
  bool isFavorite;
}
```

### 3.3 Generation Request Model
```dart
class GenerationRequest {
  String prompt;
  String style;
  String outfitType;
  String scene;
  String aspectRatio; // 9:16 for phone wallpaper
}
```

## 4. UI/UX Design Requirements

### 4.1 Visual Design
- **Color Scheme**: 
  - Primary: Elegant pink/rose gold (#FF6B9D)
  - Secondary: Soft purple (#9B59B6)
  - Accent: Gold (#FFD700)
  - Background: White/Light gray gradient
  - Text: Dark gray (#2C3E50)

- **Typography**:
  - Headings: Poppins Bold
  - Body: Poppins Regular
  - Captions: Poppins Light

- **Design Style**: 
  - Modern, clean, elegant
  - Card-based layout
  - Smooth animations
  - Glass morphism effects

### 4.2 Key Screens
1. **Home Screen**: Featured wallpapers carousel, trending styles, quick generate
2. **Gallery Screen**: Grid view with filters and search
3. **Generate Screen**: Input form with visual style selectors
4. **Profile Screen**: Stats, settings, token balance

### 4.3 Interactions
- **Animations**: Smooth page transitions, card hover effects, loading animations
- **Gestures**: Swipe between images, pinch to zoom, pull to refresh
- **Feedback**: Haptic feedback on important actions

## 5. Technical Implementation

### 5.1 Tech Stack
- **Framework**: Flutter
- **State Management**: GetX
- **Local Storage**: GetStorage
- **Image Caching**: cached_network_image
- **Image Generation**: Integration with AI API (e.g., Stable Diffusion, DALL-E, or custom API)

### 5.2 Project Structure
```
lib/
├── app/
│   ├── data/
│   │   ├── models/
│   │   ├── providers/
│   │   └── services/
│   ├── modules/
│   │   ├── home/
│   │   ├── gallery/
│   │   ├── generate/
│   │   └── profile/
│   ├── routes/
│   └── widgets/
├── core/
│   ├── theme/
│   ├── utils/
│   └── values/
└── main.dart
```

### 5.3 Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  get_storage: ^2.1.1
  http: ^1.2.0
  cached_network_image: ^3.3.1
  image_gallery_saver: ^2.0.3
  share_plus: ^7.2.2
  in_app_purchase: ^3.1.13
  permission_handler: ^11.3.0
  flutter_staggered_grid_view: ^0.7.0
  shimmer: ^3.0.0
  app_tracking_transparency: ^2.0.5
```

### 5.4 Core Services
- **TokenService**: Manage token balance and transactions
- **GenerationService**: Handle AI API calls and image generation
- **StorageService**: Manage local data with GetStorage
- **GalleryService**: Manage wallpaper collection
- **IAPService**: Handle in-app purchases

## 6. Development Phases

### Phase 1: Foundation (MVP)
- ✅ Project setup and dependencies
- ✅ Basic UI structure with GetX routing
- ✅ Token management system
- ✅ AI generation API integration
- ✅ Local storage setup

### Phase 2: Core Features
- Gallery management
- Image save and share functionality
- Style categories and templates
- User profile

### Phase 3: Enhancement
- In-app purchase implementation
- Advanced filtering and search
- Favorites and collections
- Performance optimization

### Phase 4: Polish & Compliance
- App Store compliance
- Privacy policy integration
- ATT (App Tracking Transparency)
- Bug fixes and testing

## 7. Privacy & Compliance

### 7.1 Privacy Requirements
- ATT permission dialog
- Privacy Policy page
- Terms of Service page
- Data collection transparency

### 7.2 App Store Guidelines
- No explicit or inappropriate content
- Clear IAP descriptions
- Proper content moderation
- Age rating: 12+ (due to fashion imagery)

## 8. Success Metrics

### 8.1 KPIs
- Daily active users
- Wallpaper generation rate
- Token purchase conversion rate
- User retention rate
- Average session duration

### 8.2 User Engagement
- Number of wallpapers generated
- Sharing frequency
- Favorite/save rate
- Return user rate

---

## Next Steps

1. ✅ Setup Flutter project with GetX architecture
2. Configure pubspec.yaml with all dependencies
3. Create folder structure
4. Implement core services
5. Build UI screens
6. Integrate AI image generation API
7. Test and refine

**Note**: All text in the app will be in English. No multi-theme support needed for MVP.

