// lib/app/data/models/notification_model.dart
import 'package:flutter/material.dart';

enum NotificationType { offer, status, alert }

class AppNotification {
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  AppNotification({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}