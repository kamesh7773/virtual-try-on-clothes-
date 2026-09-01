---
description: Guidelines for implementing views in the Indikosh app
globs: lib/**/views/**/*.dart
alwaysApply: false
---
# UI Implementation

## Views

- Use HookConsumerWidget
- Watch state with ref.watch
- Handle loading/errors
- Validate inputs
- Use custom hooks for screen lifecycle
- Example:

```dart
class UserProfileScreen extends HookConsumerWidget {
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProviderProvider(userId));
    
    // Use custom hook for initial data loading
    useEffect(() {
      ref.read(userProviderProvider(userId).notifier).fetchUser();
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: userState.when(
        data: (user) => _buildUserProfile(context, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: ${user.name}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${user.status.name}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
```

## Widgets

- Create reusable widgets
- Keep widgets small and focused
- Use proper widget composition
- Handle state appropriately
- Example:

```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonType type;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.type = ButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine button style based on type
    final backgroundColor = switch (type) {
      ButtonType.primary => theme.colorScheme.primary,
      ButtonType.secondary => theme.colorScheme.secondary,
      ButtonType.danger => Colors.red,
    };
    
    final foregroundColor = switch (type) {
      ButtonType.primary => Colors.white,
      ButtonType.secondary => Colors.white,
      ButtonType.danger => Colors.white,
    };

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Text(text),
      ),
    );
  }
}

enum ButtonType {
  primary,
  secondary,
  danger,
}
```

## Responsive Design

- Use ScreenUtil for responsive sizing
- Create adaptive layouts
- Handle different screen sizes
- Example:

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    // If width is more than 1100 and desktop is provided, show desktop
    if (size.width >= 1100 && desktop != null) {
      return desktop!;
    }
    
    // If width is between 650 and 1100 and tablet is provided, show tablet
    if (size.width >= 650 && size.width < 1100 && tablet != null) {
      return tablet!;
    }
    
    // Otherwise show mobile
    return mobile;
  }
}

// Usage example
class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      children: [
        // Mobile layout widgets
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildSidebar(),
        ),
        Expanded(
          flex: 2,
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildSidebar(),
        ),
        Expanded(
          flex: 3,
          child: _buildContent(),
        ),
        Expanded(
          flex: 1,
          child: _buildRightPanel(),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(/* Sidebar content */);
  }

  Widget _buildContent() {
    return Container(/* Main content */);
  }

  Widget _buildRightPanel() {
    return Container(/* Right panel content */);
  }
}
``` 