// presentation/modules/offers_comparison/controllers/offers_comparison_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/models/insurance_offer_model.dart';
import '../../../app/routes/app_pages.dart';
import '../../app/routes/app_routes.dart';

class OffersComparisonController extends GetxController {
  final RxList<InsuranceOffer> offers = <InsuranceOffer>[].obs;
  var isLoading = true.obs;

  // PageView controller
  final pageController = PageController(viewportFraction: 0.8);
  var pageOffset = 0.0.obs;

  // متغيرات منطق المقارنة
  final RxList<InsuranceOffer> comparisonList = <InsuranceOffer>[].obs;
  final int maxCompareItems = 3;

  // بيانات الخلفيات (تبقى هنا لأنها مرتبطة بعرض هذه الشاشة)
  final List<List<Color>> backgroundGradients = [
    [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
    [const Color(0xFFD81B60), const Color(0xFFF06292)],
    [const Color(0xFF8E24AA), const Color(0xFFAB47BC)],
    [const Color(0xFF43A047), const Color(0xFF66BB6A)],
    [const Color(0xFF00ACC1), const Color(0xFF26C6DA)],
    [const Color(0xFFF4511E), const Color(0xFFFF7043)],
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map<String, dynamic>) {
      final arguments = Get.arguments as Map<String, dynamic>;
      final fetchedOffers = arguments['offers'] as List<InsuranceOffer>;
      Future.delayed(const Duration(milliseconds: 600), () {
        offers.assignAll(fetchedOffers);
        isLoading.value = false;
      });
    } else {
      isLoading.value = false;
      Get.snackbar("خطأ", "لم يتم العثور على بيانات العروض.");
    }
    pageController.addListener(() {
      if (pageController.page != null) {
        pageOffset.value = pageController.page!;
      }
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void selectOffer(InsuranceOffer offer) {
    Get.toNamed(Routes.OFFER_DETAILS, arguments: offer);
  }

  void toggleCompare(InsuranceOffer offer) {
    if (comparisonList.contains(offer)) {
      comparisonList.remove(offer);
    } else {
      if (comparisonList.length < maxCompareItems) {
        comparisonList.add(offer);
      } else {
        Get.snackbar(
          'الحد الأقصى للمقارنة',
          'يمكنك مقارنة $maxCompareItems عروض فقط في المرة الواحدة.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void startComparison() {
    if (comparisonList.length < 2) {
      Get.snackbar('مطلوب عرضين على الأقل', 'الرجاء تحديد عرضين أو أكثر لبدء المقارنة.');
      return;
    }
    // تمرير القائمة المختارة إلى شاشة المقارنة النهائية
    Get.toNamed(Routes.FINAL_COMPARISON, arguments: comparisonList.toList());
  }

  void clearComparison() {
    comparisonList.clear();
  }
}