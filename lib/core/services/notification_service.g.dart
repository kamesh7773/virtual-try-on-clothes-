// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Async-init notification service. `build()` initializes the
/// `AwesomeNotifications` plugin and returns it. Callers do:
///
/// ```dart
/// await ref.read(notificationServiceProvider.future);   // ensure ready
/// await ref.read(notificationServiceProvider.notifier).show(...);
/// ```

@ProviderFor(NotificationService)
final notificationServiceProvider = NotificationServiceProvider._();

/// Async-init notification service. `build()` initializes the
/// `AwesomeNotifications` plugin and returns it. Callers do:
///
/// ```dart
/// await ref.read(notificationServiceProvider.future);   // ensure ready
/// await ref.read(notificationServiceProvider.notifier).show(...);
/// ```
final class NotificationServiceProvider
    extends $AsyncNotifierProvider<NotificationService, AwesomeNotifications> {
  /// Async-init notification service. `build()` initializes the
  /// `AwesomeNotifications` plugin and returns it. Callers do:
  ///
  /// ```dart
  /// await ref.read(notificationServiceProvider.future);   // ensure ready
  /// await ref.read(notificationServiceProvider.notifier).show(...);
  /// ```
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  NotificationService create() => NotificationService();
}

String _$notificationServiceHash() =>
    r'2c94660b010dff0cd688f1036ff9f584c4fbf5af';

/// Async-init notification service. `build()` initializes the
/// `AwesomeNotifications` plugin and returns it. Callers do:
///
/// ```dart
/// await ref.read(notificationServiceProvider.future);   // ensure ready
/// await ref.read(notificationServiceProvider.notifier).show(...);
/// ```

abstract class _$NotificationService
    extends $AsyncNotifier<AwesomeNotifications> {
  FutureOr<AwesomeNotifications> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<AwesomeNotifications>, AwesomeNotifications>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AwesomeNotifications>,
                AwesomeNotifications
              >,
              AsyncValue<AwesomeNotifications>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
