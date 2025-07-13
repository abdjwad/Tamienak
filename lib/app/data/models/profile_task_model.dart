// مسار الملف: lib/app/data/models/profile_task_model.dart
import 'package:flutter/material.dart';

class ProfileTask {
  final String title;
  final IconData icon;
  final bool isCompleted;
  final VoidCallback onTap; // الوظيفة التي سيتم استدعاؤها عند الضغط

  ProfileTask({
    required this.title,
    required this.icon,
    required this.isCompleted,
    required this.onTap,
  });
}