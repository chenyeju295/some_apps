# DiveExplorer - Diving & Marine Culture App Requirements

## 1. Product Overview

### 1.1 Basic Information
- **App Name**: DiveExplorer
- **Description**: A comprehensive diving and marine culture app for diving enthusiasts and ocean lovers. Users can learn diving knowledge and generate underwater world images through AI, creating an "online diving" experience.
- **Target Users**: Diving enthusiasts, marine culture lovers, beginners interested in diving
- **Core Value**: Educational diving content + AI-powered underwater image generation

### 1.2 Market Positioning
- Primary Market: iOS App Store (Global)
- Competitive Advantage: Combines educational diving content with AI image generation
- Monetization: Token-based in-app purchase system

## 2. Core Features

### 2.1 App Architecture
- **Navigation**: Tab-based navigation with 4 main sections
- **Language**: English throughout the app
- **State Management**: Provider pattern
- **Data Persistence**: SharedPreferences
- **Design Theme**: Ocean/underwater aesthetic with blue-green color scheme

### 2.2 Main Features

#### 2.2.1 Diving Knowledge Hub
**Functionality**:
- Comprehensive diving education content
- Topics include: safety procedures, equipment guides, marine life identification, diving techniques
- Interactive learning modules with progress tracking
- Diving certification information and preparation guides

**User Experience**:
- Categorized content (Beginner, Intermediate, Advanced)
- Search functionality for specific topics
- Bookmark favorite articles
- Progress tracking for learning modules

#### 2.2.2 AI Underwater Image Generation
**Functionality**:
- AI-powered generation of underwater scenes and marine life
- Users can describe desired underwater scenarios
- High-quality images suitable for wallpapers or sharing
- Token-based usage (1 token per generation)

**User Experience**:
- Text prompt input for image descriptions
- Style options (realistic, artistic, vintage)
- Gallery to save generated images
- Share generated images to social media

#### 2.2.3 Virtual Dive Experiences
**Functionality**:
- Pre-designed virtual dive scenarios
- 360-degree underwater environment descriptions
- Marine life encounter simulations
- Dive site information from around the world

**User Experience**:
- Immersive text-based dive narratives
- Beautiful underwater scene illustrations
- Educational facts about marine ecosystems
- Dive site recommendations with real-world information

#### 2.2.4 Token System & In-App Purchases
**Functionality**:
- Token-based system for AI image generation
- New users receive 50 free tokens
- Multiple purchase options for token packages

**Purchase Options**:
- Starter Pack: $2.99 - 100 tokens
- Explorer Pack: $4.99 - 200 tokens  
- Adventurer Pack: $9.99 - 450 tokens
- Pro Diver Pack: $19.99 - 1000 tokens
- Master Pack: $49.99 - 2500 tokens

## 3. Technical Implementation

### 3.1 Architecture Design
```
lib/
├── main.dart
├── providers/
│   ├── token_provider.dart
│   ├── content_provider.dart
│   ├── image_provider.dart
│   └── user_provider.dart
├── models/
│   ├── diving_content.dart
│   ├── generated_image.dart
│   └── user_progress.dart
├── services/
│   ├── ai_service.dart
│   ├── storage_service.dart
│   └── purchase_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── learn_screen.dart
│   ├── generate_screen.dart
│   └── profile_screen.dart
└── widgets/
    ├── common/
    └── specialized/
```

### 3.2 Required Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  in_app_purchase: ^3.1.11
  http: ^1.1.0
  app_tracking_transparency: ^2.0.4
  cached_network_image: ^3.3.0
  share_plus: ^7.2.1
  path_provider: ^2.1.1
```

### 3.3 Data Models

#### Diving Content Model
```dart
class DivingContent {
  final String id;
  final String title;
  final String content;
  final String category;
  final String difficulty;
  final List<String> tags;
  final String imageUrl;
  final int readTime;
}
```

#### Generated Image Model
```dart
class GeneratedImage {
  final String id;
  final String prompt;
  final String imageUrl;
  final DateTime createdAt;
  final String style;
  final bool isFavorite;
}
```

## 4. User Interface Design

### 4.1 Color Scheme
- Primary: Ocean Blue (#0077BE)
- Secondary: Deep Sea Green (#1B4D3E)
- Accent: Coral (#FF6B6B)
- Background: Light Aqua (#F0F8FF)
- Text: Deep Navy (#2C3E50)

### 4.2 Screen Layout

#### Home Screen
- Welcome section with daily diving tip
- Quick access to learning modules
- Recent AI-generated images gallery
- Token balance display

#### Learn Screen
- Category tabs (Safety, Equipment, Marine Life, Techniques)
- Search bar for content discovery
- Progress indicators for completed modules
- Featured articles carousel

#### Generate Screen
- Text input for image prompts
- Style selection options
- Generation history
- Token usage indicator

#### Profile Screen
- User statistics (learning progress, images generated)
- Settings and preferences
- Token purchase options
- About and privacy policy

## 5. Development Phases

### Phase 1: Core Framework (Week 1-2)
1. Set up Flutter project with Provider
2. Implement basic navigation structure
3. Create data models and providers
4. Set up SharedPreferences for data persistence

### Phase 2: Content System (Week 3-4)
1. Implement diving knowledge content system
2. Create content browsing and search functionality
3. Add bookmark and progress tracking features
4. Design and implement UI components

### Phase 3: AI Integration (Week 5-6)
1. Integrate AI image generation API
2. Implement token system and usage tracking
3. Create image gallery and management features
4. Add sharing capabilities

### Phase 4: Monetization & Polish (Week 7-8)
1. Implement in-app purchase system
2. Add App Tracking Transparency
3. Create privacy policy and terms of service
4. Final UI polish and testing

## 6. Success Metrics

### 6.1 User Engagement
- Daily active users
- Time spent in learning modules
- Number of AI images generated per user
- Content bookmark rates

### 6.2 Monetization
- Token purchase conversion rate
- Average revenue per user
- User retention after first purchase

### 6.3 Educational Impact
- Learning module completion rates
- User progress through difficulty levels
- Community sharing of educational content

## 7. Privacy & Compliance

### 7.1 Data Collection
- Learning progress data (stored locally)
- Generated image prompts and results
- Purchase history
- User preferences

### 7.2 Privacy Features
- App Tracking Transparency implementation
- Clear privacy policy explaining data usage
- Option to delete all user data
- No personal information required for basic app usage

This requirements document provides a comprehensive foundation for developing the DiveExplorer app with the specified Provider + SharedPreferences architecture and English language interface.
