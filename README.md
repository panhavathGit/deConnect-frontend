# onboarding_project

A new Flutter project.

## Getting Started

### Environment Setup

This project uses Flutter flavors to manage different environments (Development, Staging, Production).

#### Environment Files

Each environment has its own `.env` file:
- `.env.dev` - Development environment
- `.env.staging` - Staging environment
- `.env.prod` - Production environment

**Important**: These files are gitignored. Use `.env.example` as a template to create your own environment files.

### Running the App

#### Using VS Code

Launch configurations are already set up in `.vscode/launch.json`:
1. Open the Run and Debug panel (Cmd+Shift+D)
2. Select the desired configuration:
   - **Launch Dev** - Runs the dev flavor
   - **Launch Staging** - Runs the staging flavor
   - **Launch Prod** - Runs the prod flavor
3. Click the play button or press F5

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
  - Dev: `com.example.onboarding_project.dev`
  - Staging: `com.example.onboarding_project.stg`
  - Production: `com.example.onboarding_project`
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

**Configuration files:**
- [flutter_launcher_icons-dev.yaml](flutter_launcher_icons-dev.yaml)
- [flutter_launcher_icons-staging.yaml](flutter_launcher_icons-staging.yaml)
- [flutter_launcher_icons-prod.yaml](flutter_launcher_icons-prod.yaml)
### Adding Environment Variables

1. Add the variable to all `.env.*` files
2. Add a getter in `lib/core/config/env_config.dart`:
```dart
static String get myNewVariable => dotenv.env['MY_NEW_VARIABLE'] ?? '';
```
