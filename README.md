# LiveLook — Virtual Try-On

Flutter app for real-time virtual try-on, built on a **Riverpod + Flutter Hooks + flavors** base. Ported from the `next_js_project` web app; the try-on stream is powered by the Decart API.

If you're starting a project with this stack, use this repo as your starting point instead of setting things up from scratch.

## What's set up

- **State management** — `hooks_riverpod` + `flutter_hooks` + `riverpod_annotation` (with `riverpod_generator` via `build_runner`)
- **Flavors** — `development`, `staging`, `production` with separate entry points (`main_development.dart`, `main_staging.dart`, `main.dart`) and `.env.*` files loaded via `flutter_dotenv`
- **Networking** — `dio` + `pretty_dio_logger`
- **Storage** — `flutter_secure_storage`, `shared_preferences`
- **UI** — `flutter_screenutil`, `flutter_svg`, `toastification`, `loading_animation_widget`
- **Notifications** — `awesome_notifications`
- **Utilities** — `connectivity_plus`, `permission_handler`, `package_info_plus`
- **Assets / icons / splash** — `flutter_gen_runner`, `flutter_launcher_icons`, `flutter_native_splash`
- **iOS configs** — per-flavor `.xcconfig` files already in place

## MVVM architecture — VS Code task

A VS Code task is included to scaffold a new feature with the MVVM folder structure so you don't have to create the folders by hand every time.

**To run it:**

1. Open the Command Palette → **Tasks: Run Task**
2. Select **Flutter: Create MVVM Feature**
3. Pick the base folder (`lib/features`)
4. Enter the feature name (e.g. `auth`, `home`, `profile`)

This creates:

```
lib/features/<feature_name>/
├── model/
├── view/
├── viewmodel/
└── repository/
```

The task is defined in [.vscode/tasks.json](.vscode/tasks.json).

## Running a flavor

Use the launch configs in [.vscode/launch.json](.vscode/launch.json), or run from the CLI:

```bash
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor staging     -t lib/main_staging.dart
flutter run --flavor production  -t lib/main.dart
```

A helper script for iOS dev is also available: [run_ios_dev.sh](run_ios_dev.sh).

## Code generation

After changing any Riverpod-annotated providers, run `build_runner`. After adding/removing files in `assets/` (images, svgs, icons, fonts), run `flutter_gen` to regenerate the typed `AppAssets` class in [lib/core/constants/](lib/core/constants/).

```bash
# Riverpod providers + any other build_runner-based generators
dart run build_runner build --delete-conflicting-outputs

# Watch mode (regenerates on file changes)
dart run build_runner watch --delete-conflicting-outputs

# Asset class (AppAssets) — flutter_gen
dart run flutter_gen_runner
# or simply:
fluttergen -c pubspec.yaml
```

### App icon & splash screen

```bash
# Regenerate launcher icons from assets/icons/app_logo.png
dart run flutter_launcher_icons

# Regenerate native splash from assets/icons/app_splash.png
dart run flutter_native_splash:create

# Remove the native splash
dart run flutter_native_splash:remove
```
