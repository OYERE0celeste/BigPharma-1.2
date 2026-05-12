import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/notification_model.dart';

import '../services/auth_provider.dart';
import '../services/api_constants.dart';

class NotificationProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  AuthProvider get authProvider => _authProvider!;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  io.Socket? _socket;

  NotificationProvider();

  void update(AuthProvider auth) {
    if (_authProvider?.token == auth.token && _authProvider?.user?.id == auth.user?.id) return;
    
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

    final String baseUrl = ApiConstants.baseUrl;
    String socketUrl = baseUrl;
    if (socketUrl.endsWith('/api/v1')) {
      socketUrl = socketUrl.substring(0, socketUrl.length - 7);
    } else if (socketUrl.endsWith('/api')) {
      socketUrl = socketUrl.substring(0, socketUrl.length - 4);
    }

    _socket = io.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      print('Client App: Connected to Socket.io');
      if (authProvider.user != null) {
        _socket!.emit('join-user', authProvider.user!.id);
        // Clients don't necessarily join company room unless they need company-wide broadcasts
      }
    });

    _socket!.on('notification', (data) {
      final newNotification = NotificationModel.fromJson(data);
      _notifications.insert(0, newNotification);
      _unreadCount++;
      notifyListeners();
    });

    _socket!.onDisconnect(
      (_) => print('Client App: Disconnected from Socket.io'),
    );
  }

  Future<void> fetchNotifications() async {
    if (!authProvider.isAuthenticated) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> list = data['data'];
        _notifications = list
            .map((item) => NotificationModel.fromJson(item))
            .toList();
        _unreadCount = data['extra']['unreadCount'] ?? 0;
      }
    } catch (e) {
      print('Error fetching notifications: $e');
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

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}
