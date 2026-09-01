import 'package:flutter/material.dart';

import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/home/views/home_screen.dart';
import 'route_arguments.dart';
import 'routes.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case Routes.login:
        final args = settings.arguments as LoginScreenArgs?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LoginScreen(args: args ?? const LoginScreenArgs()),
        );
      case Routes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
