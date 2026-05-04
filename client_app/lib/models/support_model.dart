import 'package:flutter/material.dart';

class SupportQuestion {
  final String id;
  final String clientId;
  final String clientName;
  final String companyId;
  final String subject;
  final String status;
  final List<SupportMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportQuestion({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.companyId,
    required this.subject,
    required this.status,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportQuestion.fromJson(Map<String, dynamic> json) {
    return SupportQuestion(
      id: json['_id'] ?? '',
      clientId: json['clientId'] is Map ? json['clientId']['_id'] : (json['clientId'] ?? ''),
      clientName: json['clientId'] is Map ? (json['clientId']['fullName'] ?? 'Client') : 'Client',
      companyId: json['companyId'] is Map ? json['companyId']['_id'] : (json['companyId'] ?? ''),
      subject: json['subject'] ?? '',
      status: json['status'] ?? 'en_attente',
      messages: (json['messages'] as List?)
              ?.map((m) => SupportMessage.fromJson(m))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'repondu':
        return 'Répondu';
      case 'ferme':
        return 'Fermé';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'en_attente':
        return Colors.orange;
      case 'repondu':
        return Colors.green;
      case 'ferme':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}

class SupportMessage {
  final String content;
  final String senderId;
  final String senderType; // 'client' or 'pharmacie'
  final DateTime createdAt;

  SupportMessage({
    required this.content,
    required this.senderId,
    required this.senderType,
    required this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      content: json['content'] ?? '',
      senderId: json['senderId'] is Map ? json['senderId']['_id'] : (json['senderId'] ?? ''),
      senderType: json['senderType'] ?? 'client',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
