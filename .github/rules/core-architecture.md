---
description: Core architectural principles and project structure guidelines for the SendMePls Customer app
globs: lib/**/*.dart
alwaysApply: false
---
 You are an expert in Flutter, Dart, Riverpod, Flutter Hooks, and API integration.

# Indikosh - Knowledge Repository App Architecture Rules

## Core Architecture

- Feature-First: Each feature module is self-contained and independent.
- Clean Architecture: Implement MVVM pattern with clear layer separation.
- Type Safety: Use strong typing, avoid dynamic types.
- Single Responsibility: Each class and file serves one clear purpose.
- Dependency Injection: Use Riverpod for state management and DI.
- UI/UX Consistency: Follow standardized component patterns.

## Project Structure

```
lib/
├── core/            # Shared code and utilities
│   ├── config/      # App configuration
│   ├── constants/   # Configuration constants
│   ├── extensions/  # Extension methods
│   ├── formatters/  # Text formatters
│   ├── hooks/       # Custom Flutter hooks
│   ├── models/      # Core data models
│   ├── repositories/# Data repositories
│   ├── routes/      # Navigation routes
│   ├── rules/       # Validation rules
│   ├── services/    # Core services (API, Auth)
│   ├── theme/       # App styling
│   ├── utils/       # Helper functions
│   └── widgets/     # Shared widgets
└── features/        # Feature modules
    └── feature_name/
        ├── models/       # Data models
        ├── providers/    # State management
        ├── repositories/ # Data access
        ├── services/     # Feature services
        ├── views/        # UI screens
        └── widgets/      # Feature widgets
```

## Navigation System

- Define routes in Routes class
- Use RouteGenerator for route handling
- Pass arguments using typed classes
- Use NavigationService for navigation
- Example:

```dart
// Routes class
class Routes {
  Routes._();

  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyOtp = '/verify-otp';

  // Main routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
}

// Route arguments
class OtpScreenArgs {
  final String contactInfo;
  final bool isEmail;
  final bool fromProfile;
  final String? otpToken;
  final String? sessionId;

  const OtpScreenArgs({
    required this.contactInfo,
    this.isEmail = false,
    this.fromProfile = false,
    this.otpToken,
    this.sessionId,
  });
}

// Route generator
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case Routes.verifyOtp:
        final otpArgs = args as OtpScreenArgs;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VerifyOtpScreen(args: otpArgs),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
```

## Theming

- Use AppColors for color constants
- Use ThemeData for app theme
- Use TextTheme for text styles
- Use ScreenUtil for responsive design
- Example:

```dart
// App colors
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  // Secondary colors
  static const Color secondary = Color(0xFF03A9F4);
  static const Color secondaryLight = Color(0xFF4FC3F7);
  static const Color secondaryDark = Color(0xFF0288D1);

  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
}

// Theme configuration
ThemeData appTheme(BuildContext context) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    ),
    useMaterial3: true,
    textTheme: GoogleFonts.poppinsTextTheme(
      Theme.of(context).textTheme,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 12.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
    ),
  );
}
```