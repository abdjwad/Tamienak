// مسار الملف: lib/app/data/models/insurance_product_model.dart

import 'pricing_plan_model.dart';

class InsuranceProduct {
  final String id;
  final String name; // مثال: "تأمين طرف ثالث للسيارات"
  final String insuranceTypeId; // مثال: "car", "health" للربط مع أنواع التأمين
  final String description;
  final List<PricingPlan> plans; // قائمة بخطط الأسعار المتاحة لهذا المنتج

  InsuranceProduct({
    required this.id,
    required this.name,
    required this.insuranceTypeId,
    required this.description,
    required this.plans,
  });
}