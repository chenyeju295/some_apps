# Assets Folder

This folder contains static assets for the Fashion Wallpaper app.

## Structure

```
assets/
├── images/          # App images, placeholders, onboarding images
│   ├── logo.png
│   ├── placeholder.png
│   └── onboarding/
└── icons/           # Custom icons (if not using Font Awesome)
    └── custom_icon.png
```

## Image Guidelines

### App Icon
- **Size**: Multiple sizes required (see iOS guidelines)
- **Format**: PNG with transparency
- **Design**: Should represent fashion/wallpaper theme
- **Colors**: Use brand colors (pink, purple, gold)

### Placeholder Images
- **Size**: Same as wallpaper dimensions (1080x1920)
- **Format**: PNG or JPG
- **Usage**: Loading states, empty states

### Onboarding Images
- **Size**: Device width friendly
- **Format**: PNG for illustrations, JPG for photos
- **Count**: 3-4 screens recommended

## Adding Assets

1. Add your image files to the appropriate folder
2. Make sure they're referenced in `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/images/
       - assets/icons/
   ```

3. Use in code:
   ```dart
   Image.asset('assets/images/logo.png')
   ```

## Optimization

Before adding images:
- Optimize file sizes (use tools like TinyPNG)
- Use appropriate formats (PNG for transparency, JPG for photos)
- Consider multiple resolutions (@2x, @3x)

## Current Status

⚠️ **This folder is currently empty.**

Please add:
- [ ] App logo
- [ ] Placeholder images
- [ ] Onboarding illustrations
- [ ] Empty state images
- [ ] Error state images

