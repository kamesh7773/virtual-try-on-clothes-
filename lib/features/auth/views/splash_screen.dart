import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routes/routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/theme/app_colors.dart';
import '../view_models/auth_state.dart';
import '../view_models/auth_view_model.dart';

/// Initial route. Runs [AuthViewModel.bootstrap] then hands off to the
/// login or home screen via [NavigationService] — every transition is an
/// explicit named-route navigation.
class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigated = useRef(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authViewModelProvider.notifier).bootstrap();
      });
      return null;
    }, const []);

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (prev?.status == next.status) return;
      if (navigated.value) return;
      final nav = ref.read(navigationServiceProvider.notifier);
      switch (next.status) {
        case AuthStatus.authenticated:
          navigated.value = true;
          nav.pushNamedAndRemoveUntil(Routes.home);
          break;
        case AuthStatus.unauthenticated:
          navigated.value = true;
          nav.pushNamedAndRemoveUntil(Routes.login);
          break;
        case AuthStatus.unknown:
        case AuthStatus.authenticating:
          break;
      }
    });

    return const Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Preparing your session...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
