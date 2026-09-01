import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_service.g.dart';

/// Wraps `permission_handler` as a Riverpod service. Each helper requests
/// the permission if not yet granted and returns whether access was given.
/// Status helpers (`hasCamera` etc.) check the current state without
/// triggering a system dialog.
///
/// ```dart
/// final granted = await ref
///     .read(permissionServiceProvider.notifier)
///     .requestCamera();
/// ```
@Riverpod(keepAlive: true)
class PermissionService extends _$PermissionService {
  @override
  void build() {}

  // -----------------
  // Request (with dialog)
  // -----------------
  Future<bool> requestCamera() async =>
      (await Permission.camera.request()).isGranted;

  Future<bool> requestMicrophone() async =>
      (await Permission.microphone.request()).isGranted;

  Future<bool> requestLocationWhenInUse() async =>
      (await Permission.locationWhenInUse.request()).isGranted;

  Future<bool> requestLocationAlways() async =>
      (await Permission.locationAlways.request()).isGranted;

  Future<bool> requestPhotos() async =>
      (await Permission.photos.request()).isGranted;

  Future<bool> requestStorage() async =>
      (await Permission.storage.request()).isGranted;

  Future<bool> requestNotification() async =>
      (await Permission.notification.request()).isGranted;

  // -----------------
  // Status (no dialog)
  // -----------------
  Future<bool> hasCamera() => Permission.camera.isGranted;
  Future<bool> hasMicrophone() => Permission.microphone.isGranted;
  Future<bool> hasLocationWhenInUse() => Permission.locationWhenInUse.isGranted;
  Future<bool> hasLocationAlways() => Permission.locationAlways.isGranted;
  Future<bool> hasPhotos() => Permission.photos.isGranted;
  Future<bool> hasStorage() => Permission.storage.isGranted;
  Future<bool> hasNotification() => Permission.notification.isGranted;

  // -----------------
  // Generic helpers
  // -----------------
  Future<PermissionStatus> status(Permission permission) => permission.status;

  Future<bool> request(Permission permission) async =>
      (await permission.request()).isGranted;

  Future<bool> isPermanentlyDenied(Permission permission) =>
      permission.isPermanentlyDenied;

  Future<bool> openSettings() => openAppSettings();
}
