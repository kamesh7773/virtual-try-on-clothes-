// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dialog_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// In-app messaging service.
///
/// - Toasts (`showError`, `showSuccess`, `showWarning`, `showInfo`) are
///   driven by the `toastification` package. The app must be wrapped with
///   `ToastificationWrapper` once at the root for these to render.
/// - `showConfirmation` and `showLoading`/`hideLoading` use the global
///   `NavigationService.currentContext` so they can be called from anywhere
///   (view models, services) without passing a `BuildContext`.

@ProviderFor(DialogService)
final dialogServiceProvider = DialogServiceProvider._();

/// In-app messaging service.
///
/// - Toasts (`showError`, `showSuccess`, `showWarning`, `showInfo`) are
///   driven by the `toastification` package. The app must be wrapped with
///   `ToastificationWrapper` once at the root for these to render.
/// - `showConfirmation` and `showLoading`/`hideLoading` use the global
///   `NavigationService.currentContext` so they can be called from anywhere
///   (view models, services) without passing a `BuildContext`.
final class DialogServiceProvider
    extends $NotifierProvider<DialogService, void> {
  /// In-app messaging service.
  ///
  /// - Toasts (`showError`, `showSuccess`, `showWarning`, `showInfo`) are
  ///   driven by the `toastification` package. The app must be wrapped with
  ///   `ToastificationWrapper` once at the root for these to render.
  /// - `showConfirmation` and `showLoading`/`hideLoading` use the global
  ///   `NavigationService.currentContext` so they can be called from anywhere
  ///   (view models, services) without passing a `BuildContext`.
  DialogServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dialogServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dialogServiceHash();

  @$internal
  @override
  DialogService create() => DialogService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$dialogServiceHash() => r'f384f9eb70310ea8423a94da2366af9c9c6c43c6';

/// In-app messaging service.
///
/// - Toasts (`showError`, `showSuccess`, `showWarning`, `showInfo`) are
///   driven by the `toastification` package. The app must be wrapped with
///   `ToastificationWrapper` once at the root for these to render.
/// - `showConfirmation` and `showLoading`/`hideLoading` use the global
///   `NavigationService.currentContext` so they can be called from anywhere
///   (view models, services) without passing a `BuildContext`.

abstract class _$DialogService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
