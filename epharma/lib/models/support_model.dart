import 'package:flutter/material.dart';

class SupportMessage {
  final String id;
  final String senderId;
  final String senderType; // 'client' or 'pharmacie'
  final String content;
  final DateTime createdAt;

  SupportMessage({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.content,
    required this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['_id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderType: json['senderType'] ?? 'client',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class SupportQuestion {
  final String id;
  final String clientId;
  final String clientName;
  final String companyId;
  final String subject;
  final String status; // 'en_attente', 'repondu', 'ferme'
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
    var messagesList = json['messages'] as List? ?? [];
    List<SupportMessage> msgs = messagesList.map((m) => SupportMessage.fromJson(m)).toList();

    return SupportQuestion(
      id: json['_id'] ?? '',
      clientId: json['clientId'] is Map ? json['clientId']['_id'] : (json['clientId'] ?? ''),
      clientName: json['clientId'] is Map ? (json['clientId']['fullName'] ?? 'Client') : 'Client',
      companyId: json['companyId'] ?? '',
      subject: json['subject'] ?? 'Sans sujet',
      status: json['status'] ?? 'en_attente',
      messages: msgs,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Color get statusColor {
    switch (status) {
      case 'repondu':
        return Colors.green;
      case 'en_attente':
        return Colors.orange;
      case 'ferme':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'repondu':
        return 'Répondu';
      case 'en_attente':
        return 'En attente';
      case 'ferme':
        return 'Fermé';
      default:
        return status;
    }
  }
}
