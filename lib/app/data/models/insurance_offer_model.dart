// lib/app/data/models/insurance_offer_model.dart

class InsuranceOffer {
  final String offerId;
  final String companyName;
  final String companyLogoUrl;
  final double annualPrice;
  final List<String> coverageDetails;
  final Map<String, String> detailedCoverage;
  final List<String> requiredDocuments;
  final String termsAndConditionsUrl;
  final bool isBestValue;
  bool isActive; // <--- الحقل الجديد

  InsuranceOffer({
    required this.offerId,
    required this.companyName,
    required this.companyLogoUrl,
    required this.annualPrice,
    required this.coverageDetails,
    this.detailedCoverage = const {},
    this.requiredDocuments = const [],
    this.termsAndConditionsUrl = '',
    this.isBestValue = false,
    this.isActive = true, required List extraBenefits, // <--- القيمة الافتراضية
  });
}