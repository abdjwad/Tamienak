// app/data/models/insurance_offer_model.dart

class InsuranceOffer {

  final String companyName;
  final String companyLogoUrl;
  final double annualPrice;
  final List<String> coverageDetails; // التغطيات الرئيسية
  final String offerId;
  final bool isBestValue;

  // *** حقول جديدة تمت إضافتها ***
  final Map<String, String> detailedCoverage; // تغطيات مفصلة (العنوان والوصف)
  final List<String> requiredDocuments; // المستندات المطلوبة
  final String termsAndConditionsUrl; // رابط الشروط والأحكام

  InsuranceOffer({

    required this.companyName,
    required this.companyLogoUrl,
    required this.annualPrice,
    required this.coverageDetails,
    required this.offerId,
    this.isBestValue = false,

    // *** إضافة الحقول الجديدة إلى الـ constructor ***
    required this.detailedCoverage,
    required this.requiredDocuments,
    required this.termsAndConditionsUrl,
  });
}