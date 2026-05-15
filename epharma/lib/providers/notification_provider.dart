import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/notification_model.dart';
import 'auth_provider.dart';
import '../services/api_constants.dart';

class NotificationProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  AuthProvider get authProvider => _authProvider!;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  io.Socket? _socket;
  DateTime? _lastStaffUpdate;

  DateTime? get lastStaffUpdate => _lastStaffUpdate;

  NotificationProvider();

  void update(AuthProvider auth) {
    if (_authProvider?.token == auth.token &&
        _authProvider?.user?.id == auth.user?.id) {
      return;
    }

    _authProvider = auth;
    if (auth.isAuthenticated) {
      fetchNotifications();
      _initSocket();
    } else {
      _socket?.disconnect();
      _socket = null;
      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
    }
  }

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void _initSocket() {
    if (_socket != null) return;

    // Extract socket URL from ApiConstants.baseUrl (remove /api/v1 or /api)
    String socketUrl = ApiConstants.baseUrl;
    if (socketUrl.endsWith('/api/v1')) {
      socketUrl = socketUrl.substring(0, socketUrl.length - 7);
    } else if (socketUrl.endsWith('/api')) {
      socketUrl = socketUrl.substring(0, socketUrl.length - 4);
    }

    try {
      _socket = io.io(socketUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'reconnectionAttempts': 5,
        'upgrade': true,
        'rejectUnauthorized': false, // For development
      });

      _socket!.onConnect((_) {
        print('✅ Connected to Socket.io');
        if (authProvider.user != null) {
          _socket!.emit('join-company', authProvider.user!.companyId);
          _socket!.emit('join-user', authProvider.user!.id);
          print(
            '📍 Joined rooms: company=${authProvider.user!.companyId}, user=${authProvider.user!.id}',
          );
        }
      });

      _socket!.on('notification', (data) {
        print('📬 Received notification: $data');
        final newNotification = NotificationModel.fromJson(data);
        _notifications.insert(0, newNotification);
        _unreadCount++;
        notifyListeners();
      });

      _socket!.on('notification-update', (data) {
        print('🔔 Notification update: $data');
        if (data['userId'] == authProvider.user?.id) {
          _unreadCount = data['unreadCount'] ?? 0;
          notifyListeners();
        }
      });

      _socket!.on('staff-updated', (data) {
        print('🔄 Staff update event received: $data');
        _lastStaffUpdate = DateTime.now();
        notifyListeners();
      });

      _socket!.on('user-updated', (data) async {
        print('👤 User update event received: $data');
        if (data is Map<String, dynamic>) {
          final payload = data['user'];
          final userId =
              payload?['id']?.toString() ?? payload?['_id']?.toString();
          if (userId != null && userId == authProvider.user?.id) {
            await authProvider.refreshCurrentUser();
          }
        }
      });

      _socket!.onConnectError((data) {
        print('❌ Socket connection error: $data');
      });

      _socket!.onError((data) {
        print('❌ Socket error: $data');
      });

      _socket!.onDisconnect((_) {
        print('⚠️ Disconnected from Socket.io');
      });

      _socket!.on('disconnect', (data) {
        print('⚠️ Disconnect event: $data');
      });

      _socket!.on('connect_error', (error) {
        print('❌ Connect error: $error');
      });
    } catch (e) {
      print('❌ Error initializing Socket.io: $e');
    }
  }

  Future<void> fetchNotifications() async {
    if (!authProvider.isAuthenticated) {
      print('⚠️ User not authenticated, skipping notification fetch');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print(
        '📥 Fetching notifications from: ${ApiConstants.baseUrl}/notifications',
      );
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/notifications'),
            headers: {
              'Authorization': 'Bearer ${authProvider.token}',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Notification fetch timeout'),
          );

      print('📨 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        _notifications = list
            .map((item) => NotificationModel.fromJson(item))
            .toList();
        _unreadCount = data['extra']?['unreadCount'] ?? 0;
        print(
          '✅ Loaded ${_notifications.length} notifications (${_unreadCount} unread)',
        );
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - token may have expired');
      } else {
        print('❌ Error fetching notifications: ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/notifications/$id/read'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1 && !_notifications[index].isRead) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          _unreadCount = math.max(0, _unreadCount - 1);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Send a test notification for debugging
  Future<void> sendTestNotification() async {
    if (!authProvider.isAuthenticated) return;

    try {
      print('🧪 Sending test notification...');
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications/test'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Test notification sent successfully');
        // Refresh notifications after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        await fetchNotifications();
      } else {
        print('❌ Failed to send test notification: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}
