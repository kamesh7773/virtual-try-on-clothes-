import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:toastification/toastification.dart';

import '../theme/app_colors.dart';
import 'navigation_service.dart';

part 'dialog_service.g.dart';

/// In-app messaging service.
///
/// - Toasts (`showError`, `showSuccess`, `showWarning`, `showInfo`) are
///   driven by the `toastification` package. The app must be wrapped with
///   `ToastificationWrapper` once at the root for these to render.
/// - `showConfirmation` and `showLoading`/`hideLoading` use the global
///   `NavigationService.currentContext` so they can be called from anywhere
///   (view models, services) without passing a `BuildContext`.
@Riverpod(keepAlive: true)
class DialogService extends _$DialogService {
  bool _loadingShown = false;

  @override
  void build() {}

  BuildContext? get _context =>
      ref.read(navigationServiceProvider.notifier).currentContext;

  // -----------------
  // Toasts
  // -----------------
  void showError(
    String message, {
    String title = 'Error',
    Duration duration = const Duration(seconds: 4),
  }) =>
      _showToast(
        title: title,
        message: message,
        type: ToastificationType.error,
        primaryColor: AppColors.error,
        duration: duration,
      );

  void showSuccess(
    String message, {
    String title = 'Success',
    Duration duration = const Duration(seconds: 4),
  }) =>
      _showToast(
        title: title,
        message: message,
        type: ToastificationType.success,
        primaryColor: AppColors.success,
        duration: duration,
      );

  void showWarning(
    String message, {
    String title = 'Warning',
    Duration duration = const Duration(seconds: 4),
  }) =>
      _showToast(
        title: title,
        message: message,
        type: ToastificationType.warning,
        primaryColor: AppColors.warning,
        duration: duration,
      );

  void showInfo(
    String message, {
    String title = 'Info',
    Duration duration = const Duration(seconds: 4),
  }) =>
      _showToast(
        title: title,
        message: message,
        type: ToastificationType.info,
        primaryColor: AppColors.info,
        duration: duration,
      );

  void _showToast({
    required String title,
    required String message,
    required ToastificationType type,
    required Color primaryColor,
    required Duration duration,
  }) {
    toastification.show(
      type: type,
      style: ToastificationStyle.flatColored,
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      showProgressBar: true,
      title: Text(title),
      description: Text(message),
      primaryColor: primaryColor,
      borderRadius: BorderRadius.circular(12),
      dragToClose: true,
      pauseOnHover: true,
      closeOnClick: true,
      applyBlurEffect: false,
    );
  }

  /// Dismiss every visible toast.
  void dismissAllToasts() => toastification.dismissAll();

  // -----------------
  // Confirmation dialog
  // -----------------
  Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final context = _context;
    if (context == null) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // -----------------
  // Loading dialog
  // -----------------
  void showLoading() {
    final context = _context;
    if (context == null || _loadingShown) return;
    _loadingShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void hideLoading() {
    final context = _context;
    if (context == null || !_loadingShown) return;
    Navigator.of(context, rootNavigator: true).pop();
    _loadingShown = false;
  }
}
