// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// View model for the home (products) screen.
///
/// API outcomes are surfaced via [DialogService] (toasts) and
/// [NotificationService] (system notifications). State holds only data
/// and in-flight flags — messaging is side-effectful.

@ProviderFor(HomeViewModel)
final homeViewModelProvider = HomeViewModelProvider._();

/// View model for the home (products) screen.
///
/// API outcomes are surfaced via [DialogService] (toasts) and
/// [NotificationService] (system notifications). State holds only data
/// and in-flight flags — messaging is side-effectful.
final class HomeViewModelProvider
    extends $NotifierProvider<HomeViewModel, HomeState> {
  /// View model for the home (products) screen.
  ///
  /// API outcomes are surfaced via [DialogService] (toasts) and
  /// [NotificationService] (system notifications). State holds only data
  /// and in-flight flags — messaging is side-effectful.
  HomeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeViewModelHash();

  @$internal
  @override
  HomeViewModel create() => HomeViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeState>(value),
    );
  }
}

String _$homeViewModelHash() => r'f90149957a60a3c3a7132ab9fc96eb5f3d868a76';

/// View model for the home (products) screen.
///
/// API outcomes are surfaced via [DialogService] (toasts) and
/// [NotificationService] (system notifications). State holds only data
/// and in-flight flags — messaging is side-effectful.

abstract class _$HomeViewModel extends $Notifier<HomeState> {
  HomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HomeState, HomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeState, HomeState>,
              HomeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
