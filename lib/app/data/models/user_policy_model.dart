// مسار الملف: lib/app/data/models/user_policy_model.dart

import 'package:flutter/material.dart';

enum PolicyStatus { active, pending, expired }

class UserPolicy {
  final String policyName;
  final String companyName;
  final PolicyStatus status;
  final IconData iconData; // تمت إضافة هذا الحقل

  UserPolicy({
    required this.policyName,
    required this.companyName,
    required this.status,
    required this.iconData, // تمت إضافة هذا الحقل
  });
}