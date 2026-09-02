import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:virtual_try_on/features/try_on/models/garment_model.dart';
import 'package:virtual_try_on/features/try_on/repositories/catalog_repository.dart';
import 'package:virtual_try_on/features/try_on/services/decart_session_service.dart';
import 'package:virtual_try_on/features/try_on/view_models/session_state.dart';
import 'package:virtual_try_on/features/try_on/view_models/session_view_model.dart';

import '../../support/fake_asset_bundle.dart';

const _garment = GarmentModel(
  id: 'g1',
  name: 'Test Polo',
  type: 'polo',
  description: 'A test garment',
  prompt: 'Substitute the upper body garment with a test polo',
  image: 'assets/garments/test.jpg',
);

class _FakeService extends DecartSessionService {
  _FakeService() : super();

  final events$ = StreamController<DecartEvent>.broadcast();

  int initializeCount = 0;
  int connectCount = 0;
  int disconnectCount = 0;
  final List<String> setGarmentPrompts = [];
  Uint8List? lastConnectImage;
  double? lastAutoDisconnect;
  Object? throwOnConnect;

  @override
  Stream<DecartEvent> get events => events$.stream;

  @override
  Future<void> initialize({
    required String apiKey,
    required String baseUrl,
    required String wsBaseUrl,
    required String model,
  }) async {
    initializeCount++;
  }

  @override
  Future<void> connect({
    required String prompt,
    Uint8List? image,
    required double autoDisconnectSeconds,
  }) async {
    if (throwOnConnect case final error?) throw error;
    connectCount++;
    lastConnectImage = image;
    lastAutoDisconnect = autoDisconnectSeconds;
  }

  @override
  Future<void> setGarment({required String prompt, Uint8List? image}) async {
    setGarmentPrompts.add(prompt);
  }

  @override
  Future<void> disconnect() async {
    disconnectCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeService service;
  late ProviderContainer container;

  setUp(() {
    dotenv.loadFromString(envString: '''
API_BASE_URL=https://api.decart.ai
DECART_API_KEY=test-key
DECART_REALTIME_MODEL=lucy-vton-latest
''');

    service = _FakeService();
    container = ProviderContainer(
      overrides: [
        decartSessionServiceProvider.overrideWithValue(service),
        assetBundleProvider.overrideWithValue(
          FakeAssetBundle({'assets/garments/test.jpg': 'fake-image-bytes'}),
        ),
      ],
    );
    container.listen(sessionViewModelProvider, (_, _) {}, fireImmediately: true);
  });

  tearDown(() {
    container.dispose();
    service.events$.close();
  });

  SessionViewModel viewModel() =>
      container.read(sessionViewModelProvider.notifier);
  SessionState state() => container.read(sessionViewModelProvider);

  test('starts uninitialized', () {
    expect(state().status, DecartStatus.uninitialized);
    expect(state().isLive, isFalse);
  });

  test('prepare initializes the SDK exactly once', () async {
    await viewModel().prepare();
    await viewModel().prepare();

    expect(service.initializeCount, 1);
  });

  test('start connects with the garment prompt, image and a billing cap',
      () async {
    await viewModel().prepare();
    service.events$.add(const DecartEvent('idle', null));
    await Future<void>.delayed(Duration.zero);

    await viewModel().start(_garment);

    expect(service.connectCount, 1);
    expect(service.lastConnectImage, isNotNull);
    // An uncapped session would bill until the app is killed.
    expect(service.lastAutoDisconnect, SessionViewModel.autoDisconnectSeconds);
    expect(state().isBusy, isFalse);
  });

  test('a failed connect surfaces the error and stays retryable', () async {
    service.throwOnConnect = Exception('boom');
    await viewModel().prepare();

    await viewModel().start(_garment);

    expect(state().status, DecartStatus.error);
    expect(state().canConnect, isTrue);
  });

  test('native state events drive the status', () async {
    await viewModel().prepare();

    service.events$.add(const DecartEvent('generating', null));
    await Future<void>.delayed(Duration.zero);

    expect(state().status, DecartStatus.generating);
    expect(state().isLive, isTrue);
  });

  test('the auto-disconnect notice reaches the user', () async {
    await viewModel().prepare();

    service.events$.add(
      const DecartEvent('disconnected', 'Session ended automatically'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(state().status, DecartStatus.disconnected);
    expect(state().message, 'Session ended automatically');
  });

  test('applyGarment is ignored while no session is live', () async {
    await viewModel().prepare();

    viewModel().applyGarment(_garment);
    await Future<void>.delayed(SessionViewModel.garmentDebounce * 2);

    expect(service.setGarmentPrompts, isEmpty);
  });

  test('applyGarment pushes the prompt once the session is live', () async {
    await viewModel().prepare();
    service.events$.add(const DecartEvent('generating', null));
    await Future<void>.delayed(Duration.zero);

    viewModel().applyGarment(_garment);
    await Future<void>.delayed(SessionViewModel.garmentDebounce * 2);

    expect(service.setGarmentPrompts, [_garment.prompt]);
  });

  test('rapid garment changes collapse into a single upload', () async {
    await viewModel().prepare();
    service.events$.add(const DecartEvent('generating', null));
    await Future<void>.delayed(Duration.zero);

    // Swiping the strip fires one call per step; only the last should ship.
    for (var i = 0; i < 5; i++) {
      viewModel().applyGarment(_garment);
    }
    await Future<void>.delayed(SessionViewModel.garmentDebounce * 2);

    expect(service.setGarmentPrompts, hasLength(1));
  });

  test('start is refused while a session is already live', () async {
    await viewModel().prepare();
    service.events$.add(const DecartEvent('generating', null));
    await Future<void>.delayed(Duration.zero);

    await viewModel().start(_garment);

    expect(service.connectCount, 0);
  });

  test('stop disconnects and returns to idle', () async {
    await viewModel().prepare();
    service.events$.add(const DecartEvent('generating', null));
    await Future<void>.delayed(Duration.zero);

    await viewModel().stop();

    expect(service.disconnectCount, greaterThanOrEqualTo(1));
    expect(state().status, DecartStatus.idle);
  });

  test('disposing the provider tears the session down', () async {
    await viewModel().prepare();
    final before = service.disconnectCount;

    container.dispose();

    // Leaving a session running past the screen would keep billing.
    expect(service.disconnectCount, before + 1);
  });
}
