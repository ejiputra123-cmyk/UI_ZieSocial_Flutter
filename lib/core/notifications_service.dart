import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/core/network.dart';

/// Top-level background handler wajib beranotasi `@pragma('vm:entry-point')`
/// agar tidak dihapus oleh Dart tree-shaker saat release build.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('FCM Background Init Error: $e');
  }
  debugPrint('FCM Background Message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiClient _apiClient = ApiClient();

  static const String _channelId = 'ziesocial_high_importance';
  static const String _channelName = 'ZieSocial Notifications';
  static const String _channelDescription =
      'Notifikasi pesan baru dan aktivitas di ZieSocial';

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  bool _isInitialized = false;
  int? _syncedUserId;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Callback opsional saat user mengetuk notifikasi (menerima payload data Map)
  void Function(Map<String, dynamic> data)? onNotificationTap;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // 1. Minta izin notifikasi (iOS & Android 13+)
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2. Inisialisasi Flutter Local Notifications (v23 named parameters)
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            try {
              final data = Map<String, dynamic>.from(jsonDecode(payload));
              onNotificationTap?.call(data);
            } catch (_) {}
          }
        },
      );

      // 3. Buat High Importance Notification Channel di Android & minta izin Android 13+
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(_androidChannel);
      await androidPlugin?.requestNotificationsPermission();

      // 4. Konfigurasi tampilan notifikasi foreground di iOS
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 5. Listener notifikasi saat aplikasi sedang terbuka (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showForegroundNotification(message);
      });

      // 6. Listener saat user mengetuk notifikasi dari kondisi Background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data.isNotEmpty) {
          onNotificationTap?.call(message.data);
        }
      });

      // 7. Cek apakah aplikasi dibuka dari notifikasi saat kondisi Terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null && initialMessage.data.isNotEmpty) {
        onNotificationTap?.call(initialMessage.data);
      }
    } catch (e) {
      debugPrint('NotificationService Initialize Error: $e');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) return;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final notificationId =
        message.hashCode ^ DateTime.now().millisecondsSinceEpoch;

    await _localNotifications.show(
      id: notificationId & 0x7FFFFFFF,
      title: title ?? 'ZieSocial',
      body: body ?? '',
      notificationDetails: notificationDetails,
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }

  /// Ambil FCM token perangkat dan kirim ke backend PHP agar user bisa menerima notifikasi.
  Future<void> syncTokenToServer(int userId) async {
    _syncedUserId = userId;
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _sendToken(userId: userId, token: token);
      }

      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
        final activeUserId = _syncedUserId;
        if (activeUserId != null && newToken.isNotEmpty) {
          _sendToken(userId: activeUserId, token: newToken);
        }
      });
    } catch (e) {
      debugPrint('FCM Sync Token Error: $e');
    }
  }

  /// Hapus FCM token user di server saat logout agar tidak menerima notifikasi akun lama.
  Future<void> clearTokenFromServer(int? userId) async {
    final targetUserId = userId ?? _syncedUserId;
    _syncedUserId = null;
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;

    if (targetUserId == null) return;

    try {
      await _sendToken(userId: targetUserId, token: '');
    } catch (e) {
      debugPrint('FCM Clear Token Error: $e');
    }
  }

  Future<void> _sendToken({required int userId, required String token}) async {
    try {
      await _apiClient.post(
        ApiConstants.updateFcmToken,
        body: {'user_id': userId, 'fcm_token': token},
      );
    } catch (e) {
      debugPrint('Update FCM Token API Error: $e');
    }
  }
}
