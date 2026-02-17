import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding_project/core/routes/app_routes.dart';
import 'package:onboarding_project/core/services/supabase_service.dart';
import 'package:firebase_core/firebase_core.dart';

/// Background handler (top-level)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[Background] message: ${message.messageId}');
  await Firebase.initializeApp();
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialize everything
  Future<void> initialize({required GlobalKey<NavigatorState> navigatorKey}) async {
    _navigatorKey = navigatorKey;
    await _initializeLocalNotifications();
    await _requestPermissions();
    await _setupTokenHandling();
    _setupMessageHandlers();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );
    debugPrint('✅ Local notifications initialized');
  }

  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
    debugPrint('✅ FCM permissions requested');
  }

  Future<void> _setupTokenHandling() async {
    try {
      debugPrint('🔍 Attempting to get FCM token...');
      final token = await _firebaseMessaging.getToken();
      debugPrint('📱 FCM Token: $token');
      await _saveTokenToDatabase(token);
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 Token refreshed: $newToken');
      _saveTokenToDatabase(newToken);
    });
  }

  Future<void> _saveTokenToDatabase(String? token) async {
    if (token == null) return;
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    try {
      await SupabaseService.client.from('user_devices').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'push_enabled': true,
        'last_active_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,fcm_token');
      debugPrint('✅ Token saved to Supabase');
    } catch (e) {
      debugPrint('❌ Error saving token: $e');
    }
  }

  void _setupMessageHandlers() {
    // Foreground
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('⚡ [Foreground] message: ${message.notification?.title}');
      debugPrint('⚡ [Foreground] data: ${message.data}');
      _showLocalNotification(message);
    });

    // Opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('⚡ [OpenedApp] message tapped: ${message.notification?.title}');
      _handleNotificationTap(message.data['room_id']?.toString());
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      channelDescription: 'Chat notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      details,
      payload: message.data['room_id']?.toString(),
    );

    debugPrint('Local notification displayed: ${message.notification?.title}');
  }

  // only go to chat screen
  // void _handleNotificationTap(String? roomId) {
  //   if (roomId == null || _navigatorKey?.currentContext == null) return;

  //   // Navigate using go_router
  //   _navigatorKey!.currentContext!.goNamed(
  //     AppRoutes.chat,
  //     extra: {'roomId': roomId},
  //   );
  //   debugPrint('🟢 Navigated to room: $roomId');
  // }

  // directly go to specific chat room
  void _handleNotificationTap(String? roomId) {
    if (roomId == null || _navigatorKey?.currentContext == null) {
      debugPrint('⚠️ Notification tap ignored, roomId is null or context missing');
      return;
    }

    debugPrint('Navigating to chat room: $roomId');
    _navigatorKey!.currentContext!.goNamed(
      AppRoutes.chatRoom,  // Changed from AppRoutes.chat
      pathParameters: {'roomId': roomId},  // Use pathParameters instead of extra
    );
  }

}

