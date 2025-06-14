// presentation/modules/quote_request/controllers/quote_request_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/models/insurance_offer_model.dart';
import '../../../app/data/models/insurance_type_model.dart';
import '../../../app/routes/app_routes.dart';

class QuoteRequestController extends GetxController {
  late InsuranceType insuranceType;
  var isLoading = false.obs;

  // Controllers للنماذج المختلفة
  Map<String, TextEditingController> formControllers = {
    'carModel': TextEditingController(),
    'carYear': TextEditingController(),
    'personAge': TextEditingController(),
    'tripDestination': TextEditingController(),
    'tripDuration': TextEditingController(),
  };

  @override
  void onInit() {
    super.onInit();
    insuranceType = Get.arguments as InsuranceType;
  }

  void submitQuoteRequest() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // محاكاة الشبكة

    // يتم توليد البيانات الديناميكية الكاملة
    List<InsuranceOffer> fetchedOffers = _getFakeOffersForType(insuranceType.id);

    isLoading.value = false;

    if (fetchedOffers.isEmpty) {
      Get.snackbar("عذراً", "لا توجد عروض متاحة لهذا النوع حالياً.",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.toNamed(Routes.OFFERS_COMPARISON, arguments: {
        'offers': fetchedOffers,
        'type': insuranceType,
      });
    }
  }

  // *** دالة توليد البيانات الوهمية الواقعية بعد التعديل ***
  List<InsuranceOffer> _getFakeOffersForType(String typeId) {
    switch (typeId) {
      case 'car':
        return [
          InsuranceOffer(
            companyName: "السورية للتأمين",
            companyLogoUrl: "https://via.placeholder.com/300/1E88E5/FFFFFF?text=Syrian",
            annualPrice: 150000,
            coverageDetails: ["تغطية ضد الغير", "إصلاح ضمن الوكالة", "مساعدة على الطريق"],
            offerId: "syr-c-1",
            // --- بيانات تفصيلية ---
            detailedCoverage: {
              "تغطية الأضرار تجاه الغير": "تغطية الأضرار المادية والجسدية التي تلحق بالطرف الثالث نتيجة حادث.",
              "إصلاح ضمن الوكالة": "يتم إصلاح الأضرار لدى الوكيل المعتمد للسيارة.",
              "مساعدة على الطريق": "خدمة سحب السيارة في حال الأعطال.",
            },
            requiredDocuments: ["صورة الهوية", "دفتر السيارة", "رخصة القيادة"],
            termsAndConditionsUrl: "https://example.com/syrian-terms",
          ),
          InsuranceOffer(
            companyName: "الثقة للتأمين",
            companyLogoUrl: "https://via.placeholder.com/300/D81B60/FFFFFF?text=Thiqa",
            annualPrice: 135000,
            coverageDetails: ["تغطية ضد الغير فقط"],
            offerId: "thi-c-2",
            isBestValue: true, // عرض القيمة الأفضل
            // --- بيانات تفصيلية ---
            detailedCoverage: {
              "تغطية الأضرار تجاه الغير": "تغطية أساسية للأضرار المادية التي تلحق بالطرف الثالث بحدود معينة.",
            },
            requiredDocuments: ["صورة الهوية", "دفتر السيارة"],
            termsAndConditionsUrl: "https://example.com/thiqa-terms",
          ),
          InsuranceOffer(
            companyName: "العقيلة للتأمين",
            companyLogoUrl: "https://via.placeholder.com/300/8E24AA/FFFFFF?text=Aqeela",
            annualPrice: 195000,
            coverageDetails: ["تغطية شاملة (حوادث وسرقة)", "سيارة بديلة", "مساعدة على الطريق"],
            offerId: "aqi-c-3",
            // --- بيانات تفصيلية ---
            detailedCoverage: {
              "تغطية الحوادث الشخصية": "تغطي الأضرار الجسدية للسائق والركاب نتيجة حادث.",
              "تغطية السرقة والحريق": "توفر حماية كاملة في حال سرقة السيارة أو تعرضها لحريق.",
              "مساعدة على الطريق 24/7": "خدمة سحب السيارة وتأمين وقود وتغيير إطارات في أي وقت.",
              "سيارة بديلة": "توفير سيارة بديلة أثناء فترة إصلاح سيارتك (حتى 7 أيام).",
            },
            requiredDocuments: ["صورة الهوية", "دفتر السيارة", "رخصة القيادة", "تقرير شرطة في حال الحوادث الكبيرة"],
            termsAndConditionsUrl: "https://example.com/aqeela-terms",
          ),
        ];
      case 'health':
        return [
          InsuranceOffer(
            companyName: "غلوب ميد",
            companyLogoUrl: "https://via.placeholder.com/300/43A047/FFFFFF?text=GlobeMed",
            annualPrice: 250000,
            coverageDetails: ["تغطية داخل المشفى 80%", "عيادات خارجية", "أدوية"],
            offerId: "gmd-h-1",
            // --- بيانات تفصيلية ---
            detailedCoverage: {
              "تغطية الاستشفاء": "تغطي 80% من تكاليف الإقامة في المستشفى والعمليات الجراحية.",
              "العيادات الخارجية": "تغطي الاستشارات الطبية والفحوصات المخبرية بحدود سنوية.",
              "الأدوية": "تغطية تكاليف الأدوية الموصوفة طبياً.",
            },
            requiredDocuments: ["صورة الهوية", "تقرير طبي (إذا لزم)"],
            termsAndConditionsUrl: "https://example.com/globemed-terms",
          ),
          InsuranceOffer(
            companyName: "الشركة المتحدة",
            companyLogoUrl: "https://via.placeholder.com/300/00ACC1/FFFFFF?text=United",
            annualPrice: 320000,
            coverageDetails: ["تغطية داخل المشفى 100%", "عيادات وأدوية", "تغطية أسنان ونظارات"],
            offerId: "uni-h-2",
            isBestValue: true,
            // --- بيانات تفصيلية ---
            detailedCoverage: {
              "تغطية الاستشفاء الكاملة": "تغطية 100% من تكاليف الإقامة في درجة أولى والعمليات الجراحية.",
              "تغطية الأسنان": "تشمل المعالجات السنية الروتينية بحدود سنوية.",
              "تغطية النظارات الطبية": "تساهم في تكلفة النظارات الطبية مرة كل سنتين.",
            },
            requiredDocuments: ["صورة الهوية"],
            termsAndConditionsUrl: "https://example.com/united-terms",
          ),
        ];
      case 'travel':
        return [
          InsuranceOffer(
            companyName: "آروپ للتأمين",
            companyLogoUrl: "https://via.placeholder.com/300/F4511E/FFFFFF?text=Arope",
            annualPrice: 50000,
            coverageDetails: ["تغطية طبية طارئة حتى 30 ألف دولار", "فقدان أمتعة", "إلغاء رحلة"],
            offerId: "arp-t-1",
            isBestValue: true,
            // --- بيانات تفصيلية ---
            detailedCoverage: {
              "الطوارئ الطبية": "تغطي تكاليف العلاج الطبي الطارئ في الخارج حتى 30,000 دولار أمريكي.",
              "فقدان الأمتعة": "تعويض في حال فقدان أو تأخر وصول الأمتعة المسجلة.",
              "إلغاء الرحلة": "تغطية التكاليف غير المستردة في حال إلغاء الرحلة لأسباب قاهرة.",
            },
            requiredDocuments: ["صورة جواز السفر", "تذكرة الطيران"],
            termsAndConditionsUrl: "https://example.com/arope-terms",
          ),
        ];
      default:
        return []; // لا توجد عروض للأنواع الأخرى بعد
    }
  }

  @override
  void onClose() {
    formControllers.forEach((key, controller) => controller.dispose());
    super.onClose();
  }
}