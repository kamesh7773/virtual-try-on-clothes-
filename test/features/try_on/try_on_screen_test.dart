import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:virtual_try_on/core/constants/app_constants.dart';
import 'package:virtual_try_on/features/try_on/repositories/catalog_repository.dart';
import 'package:virtual_try_on/features/try_on/views/try_on_screen.dart';

import '../../support/fake_asset_bundle.dart';

class _FakePermissionHandler extends PermissionHandlerPlatform {
  _FakePermissionHandler(this.status);

  final PermissionStatus status;

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async =>
      status;

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async =>
      {for (final p in permissions) p: status};

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async =>
      ServiceStatus.enabled;

  @override
  Future<bool> shouldShowRequestPermissionRationale(
    Permission permission,
  ) async =>
      false;
}

/// ScreenUtil is initialised from a Builder rather than via `ScreenUtilInit`,
/// which carries global state between tests.
Widget _app() => ProviderScope(
      overrides: [
        assetBundleProvider.overrideWithValue(
          FakeAssetBundle({'assets/data/catalog.json': kTestCatalogJson}),
        ),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            ScreenUtil.init(
              context,
              designSize: const Size(
                AppConstants.designWidth,
                AppConstants.designHeight,
              ),
            );
            return const TryOnScreen();
          },
        ),
      ),
    );

Future<void> _boot(WidgetTester tester, PermissionStatus permission) async {
  PermissionHandlerPlatform.instance = _FakePermissionHandler(permission);
  await tester.pumpWidget(_app());
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Regression guard: the mount-time catalog load used to run synchronously
  // inside flutter_hooks' initHook, which modifies a provider mid-build and
  // throws — leaving the app stuck on its spinner. The unit tests missed it
  // because they call load() outside a build.
  testWidgets('loads the catalog on mount without touching providers mid-build',
      (tester) async {
    await _boot(tester, PermissionStatus.granted);

    expect(tester.takeException(), isNull);
    expect(find.text('TEST POLO'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('shows the permission gate when camera access is denied',
      (tester) async {
    await _boot(tester, PermissionStatus.denied);

    expect(tester.takeException(), isNull);
    expect(find.text('CAMERA ACCESS NEEDED'), findsOneWidget);
    expect(find.text('ALLOW CAMERA'), findsOneWidget);
  });

  testWidgets('a permanent denial offers Settings instead of a re-prompt',
      (tester) async {
    await _boot(tester, PermissionStatus.permanentlyDenied);

    expect(find.text('OPEN SETTINGS'), findsOneWidget);
  });

  testWidgets('the catalog still renders while the camera is blocked',
      (tester) async {
    await _boot(tester, PermissionStatus.denied);

    // Hiding the catalog behind the gate would strand the user with nothing
    // to look at, so both halves have to survive a denial.
    expect(find.text('TEST POLO'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('tapping a strip item changes the selected garment',
      (tester) async {
    await _boot(tester, PermissionStatus.granted);

    expect(find.text('1 / 2'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Test Shirt'));
    await tester.pumpAndSettle();

    expect(find.text('TEST SHIRT'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
  });
}
