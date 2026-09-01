// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Function-style provider — returns a fully configured Dio instance.
/// Consumers read `ref.watch(apiClientProvider)` to get the Dio directly.

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// Function-style provider — returns a fully configured Dio instance.
/// Consumers read `ref.watch(apiClientProvider)` to get the Dio directly.

final class ApiClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Function-style provider — returns a fully configured Dio instance.
  /// Consumers read `ref.watch(apiClientProvider)` to get the Dio directly.
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$apiClientHash() => r'ba6d59ca10dec4fb2fe549219c8e044c838973ad';
