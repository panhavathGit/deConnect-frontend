# Development Flavor App Icons

Place your **development** app icon files in the respective mipmap folders.

## Required Icon Sizes

Add an `ic_launcher.png` file in each folder with these dimensions:

- **mipmap-mdpi**: 48x48 px
- **mipmap-hdpi**: 72x72 px
- **mipmap-xhdpi**: 96x96 px
- **mipmap-xxhdpi**: 144x144 px
- **mipmap-xxxhdpi**: 192x192 px

## Design Tips for Dev Icons

- Add a "DEV" badge or label overlay
- Use a different color scheme (e.g., blue tint)
- Add a border or ribbon to distinguish from production

## Quick Setup

You can use tools like:
- **Android Asset Studio**: https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html
- **App Icon Generator**: https://appicon.co/
- **flutter_launcher_icons** package (configure per flavor)

Example with flutter_launcher_icons in pubspec.yaml:
```yaml
flutter_icons:
  android: true
  image_path_android: "assets/icons/dev_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icons/dev_icon_foreground.png"
```
