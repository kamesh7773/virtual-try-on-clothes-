// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decart_session_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(decartSessionService)
final decartSessionServiceProvider = DecartSessionServiceProvider._();

final class DecartSessionServiceProvider
    extends
        $FunctionalProvider<
          DecartSessionService,
          DecartSessionService,
          DecartSessionService
        >
    with $Provider<DecartSessionService> {
  DecartSessionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'decartSessionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$decartSessionServiceHash();

  @$internal
  @override
  $ProviderElement<DecartSessionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DecartSessionService create(Ref ref) {
    return decartSessionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DecartSessionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DecartSessionService>(value),
    );
  }
}

String _$decartSessionServiceHash() =>
    r'bbcdf936d8024fc7f9b3f2f52af078345e8a14fc';
