# DeConnect APP

Lastest working branch is #refactor/logger

#### How to run?
1. Set up env : using the template from .env.example and replace it with the real credential (contact the project owner for the credential)

2. Package Installation : flutter pub get

3. Final run : flutter build apk --flavor dev -t lib/main_dev.dart

#### Environment Files

Each environment has its own `.env` file:
- `.env.dev` - Development environment
- `.env.staging` - Staging environment
- `.env.prod` - Production environment

#### Using Command Line

**Development:**
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

**Staging:**
```bash
flutter run --flavor staging -t lib/main_staging.dart
```

**Production:**
```bash
flutter run --flavor prod -t lib/main_prod.dart
```

### Building for Release (Android)

**Development:**
```bash
flutter build apk --flavor dev -t lib/main_dev.dart
```

**Staging:**
```bash
flutter build apk --flavor staging -t lib/main_staging.dart
```

**Production:**
```bash
flutter build apk --flavor prod -t lib/main_prod.dart
```

### Flavor Configuration

Each flavor has:
- **Different package name** (via applicationIdSuffix)
  - Dev: `com.dlt.deconnect.dev`
  - Staging: `com.dlt.deconnect.stg`
  - Production: `com.dlt.deconnect`
- **Different app name**
  - Dev: "App Dev"
  - Staging: "App Staging"
  - Production: "My App"
- **Different environment variables** (loaded from respective .env files)
- **Debug banner** (shown in dev and staging, hidden in production)

### App Icons (Android)

Each flavor has its own app icon configured and generated from:
- **Dev**: `assets/app_icons/deconnect_dev.png`
- **Staging**: `assets/app_icons/deconnect_stage.png`
- **Production**: `assets/app_icons/deconnect_production.png`

Icons have been automatically generated in all required sizes and placed in:
```
android/app/src/
├── dev/res/mipmap-*/      # Dev flavor icons ✓
├── staging/res/mipmap-*/   # Staging flavor icons ✓
└── prod/res/mipmap-*/      # Production flavor icons ✓
```

**To update icons:**

1. Replace the PNG files in `assets/app_icons/`
2. Run the icon generation commands:
```bash
dart run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
dart run flutter_launcher_icons -f flutter_launcher_icons-staging.yaml
dart run flutter_launcher_icons -f flutter_launcher_icons-prod.yaml
```