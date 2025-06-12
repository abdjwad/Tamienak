// lib/app/data/models/company_model.dart
class Company {
  final String id;
  final String name;
  final String logoUrl;
  final double rating;
  final String description;
  final List<String> supportedInsuranceTypes; // قائمة IDs لأنواع التأمين التي تدعمها

  Company({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.rating,
    required this.description,
    required this.supportedInsuranceTypes,
  });
}