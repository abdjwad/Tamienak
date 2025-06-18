// presentation/modules/offers_comparison/controllers/final_comparison_controller.dart
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../app/data/models/insurance_offer_model.dart';
import '../../../app/routes/app_pages.dart';
import '../../app/routes/app_routes.dart';

class FinalComparisonController extends GetxController {
  // --- متغيرات العروض الأصلية ---
  late List<InsuranceOffer> allOffers; // قائمة بكل العروض التي يمكن الاختيار منها
  var isLoading = true.obs;

  // --- متغيرات جديدة لساحة المقارنة ---
  var leftOfferIndex = 0.obs;  // مؤشر العرض على اليسار
  var rightOfferIndex = 1.obs; // مؤشر العرض على اليمين

  // خاصية للوصول السريع للعروض الحالية
  InsuranceOffer get leftOffer => allOffers[leftOfferIndex.value];
  InsuranceOffer get rightOffer => allOffers[rightOfferIndex.value];

  // قائمة الألوان للخلفيات الديناميكية (يمكن نقلها إلى ملف ثوابت)
  final List<List<Color>> backgroundGradients = [
    [const Color(0xFF1E88E5), const Color(0xFF42A5F5)], // Syrian
    [const Color(0xFFD81B60), const Color(0xFFF06292)], // Thiqa
    [const Color(0xFF8E24AA), const Color(0xFFAB47BC)], // Aqeela
    [const Color(0xFF43A047), const Color(0xFF66BB6A)], // GlobeMed
    [const Color(0xFF00ACC1), const Color(0xFF26C6DA)], // United
    [const Color(0xFFF4511E), const Color(0xFFFF7043)], // Arope
  ];
  final pageController = PageController(viewportFraction: 0.85);
  final selectedOfferIndex = 0.obs;

  void onPageChanged(int index) {
    selectedOfferIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    // التأكد من أن الـ arguments هي قائمة من InsuranceOffer
    if (Get.arguments is List<InsuranceOffer>) {
      allOffers = Get.arguments;
      if (allOffers.length < 2) {
        // التعامل مع حالة وجود أقل من عرضين
        Get.back();
        Get.snackbar("خطأ في البيانات", "مطلوب عرضين على الأقل للمقارنة.");
        return;
      }
      isLoading.value = false;
    } else {
      // التعامل مع حالة عدم تمرير البيانات بشكل صحيح
      isLoading.value = false;
      Get.back();
      Get.snackbar("خطأ", "لم يتم العثور على بيانات العروض.");
    }
  }

  // دالة لتغيير العرض في أحد الجانبين
  void changeOffer(bool isLeftPanel, bool isIncrement) {
    if (isLeftPanel) {
      int newIndex = isIncrement ? leftOfferIndex.value + 1 : leftOfferIndex.value - 1;
      // التأكد من أن المؤشر الجديد لا يساوي مؤشر الجانب الآخر
      if (newIndex == rightOfferIndex.value) {
        newIndex += isIncrement ? 1 : -1;
      }
      // التأكد من أن المؤشر ضمن حدود القائمة
      if (newIndex >= 0 && newIndex < allOffers.length) {
        leftOfferIndex.value = newIndex;
      }
    } else { // الجانب الأيمن
      int newIndex = isIncrement ? rightOfferIndex.value + 1 : rightOfferIndex.value - 1;
      if (newIndex == leftOfferIndex.value) {
        newIndex += isIncrement ? 1 : -1;
      }
      // التأكد من أن المؤشر ضمن حدود القائمة
      if (newIndex >= 0 && newIndex < allOffers.length) {
        rightOfferIndex.value = newIndex;
      }
    }
  }

  // دالة وهمية لتقييم نقاط قوة العرض للرسم البياني
  Map<String, double> getOfferRadarStats(InsuranceOffer offer) {
    // القيم يجب أن تكون بين 0 و 10
    double priceScore = (1 / offer.annualPrice * 300000).clamp(1.0, 10.0);
    double coverageScore = (offer.coverageDetails.length * 2.5).clamp(1.0, 10.0);
    double valueScore = offer.isBestValue ? 9.5 : 6.5;

    return {
      'السعر': priceScore,
      'التغطية': coverageScore,
      'القيمة': valueScore,
    };
  }

  // دالة اختيار العرض النهائي
  void chooseOffer(InsuranceOffer offer) {
    // يمكنك هنا الانتقال لصفحة الدفع أو تفاصيل العقد
    Get.toNamed(Routes.OFFER_DETAILS, arguments: offer);
  }
}