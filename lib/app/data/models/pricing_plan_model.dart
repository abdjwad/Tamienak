// مسار الملف: lib/app/data/models/pricing_plan_model.dart

import 'package:flutter/material.dart';

class PricingPlan {
  final String id;
  final String name;
  final double price;
  final int durationInDays;
  final List<String> features;
  final IconData icon; // <-- تم إضافة هذا الحقل

  PricingPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationInDays,
    required this.features,
    required this.icon, // <-- تمت إضافته هنا
  });
}