import 'package:flutter/material.dart';

class NotificationItem {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  bool isRead;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}