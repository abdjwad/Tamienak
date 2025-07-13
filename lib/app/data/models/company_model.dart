// مسار الملف: lib/app/data/models/company_model.dart

import 'insurance_product_model.dart';

class Company {
  final String id;
  final String name;
  final String logoUrl;
  final double rating;
  final String description;
  final List<String> supportedInsuranceTypes;
  final List<InsuranceProduct> products; // <-- تم إضافة هذا الحقل

  Company({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.rating,
    required this.description,
    required this.supportedInsuranceTypes,
    required this.products, // <-- تمت إضافته هنا
  });
}