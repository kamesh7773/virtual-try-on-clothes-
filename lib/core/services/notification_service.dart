import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../theme/app_colors.dart';

part 'notification_service.g.dart';

class NotificationChannels {
  NotificationChannels._();
  static const String general = 'general_channel';
  static const String reminders = 'reminders_channel';
  static const String updates = 'updates_channel';
}

class AppNotification {
  final int id;
  final String title;
  final String body;
  final String channelKey;
  final String? payloadKey;
  final String? payloadValue;
  final NotificationLayout layout;
  final String? bigPicture;
  final bool wakeUpScreen;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.channelKey = NotificationChannels.general,
    this.payloadKey,
    this.payloadValue,
    this.layout = NotificationLayout.Default,
    this.bigPicture,
    this.wakeUpScreen = false,
  });
}

@pragma('vm:entry-point')
Future<void> _onActionReceived(ReceivedAction action) async {
  debugPrint(
    'Notification action: ${action.buttonKeyPressed} payload=${action.payload}',
  );
}

@pragma('vm:entry-point')
Future<void> _onNotificationCreated(ReceivedNotification n) async {
  debugPrint('Notification created: id=${n.id}');
}

@pragma('vm:entry-point')
Future<void> _onNotificationDisplayed(ReceivedNotification n) async {
  debugPrint('Notification displayed: id=${n.id}');
}

@pragma('vm:entry-point')
Future<void> _onDismissActionReceived(ReceivedAction action) async {
  debugPrint('Notification dismissed: id=${action.id}');
}

/// Async-init notification service. `build()` initializes the
/// `AwesomeNotifications` plugin and returns it. Callers do:
///
/// ```dart
/// await ref.read(notificationServiceProvider.future);   // ensure ready
/// await ref.read(notificationServiceProvider.notifier).show(...);
/// ```
@Riverpod(keepAlive: true)
class NotificationService extends _$NotificationService {
  @override
  Future<AwesomeNotifications> build() async {
    final plugin = AwesomeNotifications();

    await plugin.initialize(
      null, // null => default app launcher icon
      [
        NotificationChannel(
          channelKey: NotificationChannels.general,
          channelName: 'General Notifications',
          channelDescription: 'General app notifications',
          defaultColor: AppColors.primary,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: NotificationChannels.reminders,
          channelName: 'Reminders',
          channelDescription: 'Reminder notifications',
          defaultColor: AppColors.secondary,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: NotificationChannels.updates,
          channelName: 'Updates',
          channelDescription: 'App update notifications',
          defaultColor: AppColors.info,
          ledColor: Colors.white,
          importance: NotificationImportance.Default,
        ),
      ],
      debug: kDebugMode,
    );

    await plugin.setListeners(
      onActionReceivedMethod: _onActionReceived,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
      onDismissActionReceivedMethod: _onDismissActionReceived,
    );

    return plugin;
  }

  Future<bool> hasPermission() async {
    final plugin = await future;
    return plugin.isNotificationAllowed();
  }

  Future<bool> requestPermission() async {
    final plugin = await future;
    final allowed = await plugin.isNotificationAllowed();
    if (allowed) return true;
    return plugin.requestPermissionToSendNotifications();
  }

  Future<void> show(AppNotification n) async {
    final plugin = await future;
    Map<String, String>? payload;
    if (n.payloadKey != null && n.payloadValue != null) {
      payload = {n.payloadKey!: n.payloadValue!};
    }

    await plugin.createNotification(
      content: NotificationContent(
        id: n.id,
        channelKey: n.channelKey,
        title: n.title,
        body: n.body,
        notificationLayout: n.layout,
        bigPicture: n.bigPicture,
        wakeUpScreen: n.wakeUpScreen,
        payload: payload,
      ),
    );
  }

  Future<void> scheduleAt({
    required AppNotification notification,
    required DateTime scheduledAt,
    bool allowWhileIdle = true,
    bool repeats = false,
  }) async {
    final plugin = await future;
    Map<String, String>? payload;
    if (notification.payloadKey != null && notification.payloadValue != null) {
      payload = {notification.payloadKey!: notification.payloadValue!};
    }

    await plugin.createNotification(
      content: NotificationContent(
        id: notification.id,
        channelKey: notification.channelKey,
        title: notification.title,
        body: notification.body,
        notificationLayout: notification.layout,
        bigPicture: notification.bigPicture,
        wakeUpScreen: notification.wakeUpScreen,
        payload: payload,
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduledAt,
        allowWhileIdle: allowWhileIdle,
        repeats: repeats,
      ),
    );
  }

  Future<void> cancel(int id) async {
    final plugin = await future;
    await plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    final plugin = await future;
    await plugin.cancelAll();
  }

  Future<void> cancelByChannel(String channelKey) async {
    final plugin = await future;
    await plugin.cancelNotificationsByChannelKey(channelKey);
  }

  Future<List<NotificationModel>> pending() async {
    final plugin = await future;
    return plugin.listScheduledNotifications();
  }
}
