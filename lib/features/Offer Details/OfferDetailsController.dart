// presentation/modules/offer_details/controllers/offer_details_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/data/models/insurance_offer_model.dart';
import '../../../app/routes/app_pages.dart';
import '../../app/routes/app_routes.dart';

class OfferDetailsController extends GetxController {
  late final InsuranceOffer offer;
  var isLoading = true.obs;

  // --- الإضافات الجديدة هنا ---
  Rx<Color> dominantColor = Rx<Color>(Colors.grey.shade800);
  Rx<Color> vibrantColor = Rx<Color>(Colors.blue.shade800);

  @override
  void onInit() {
    super.onInit();
    offer = Get.arguments as InsuranceOffer;
    _updatePalette(); // استدعاء دالة استخلاص الألوان
  }

  // دالة لاستخلاص الألوان من صورة شعار الشركة
  Future<void> _updatePalette() async {
    try {
      final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(offer.companyLogoUrl),
        size: const Size(100, 100), // حجم صغير لتحليل أسرع
      );
      dominantColor.value = paletteGenerator.dominantColor?.color ?? Get.theme.primaryColor;
      vibrantColor.value = paletteGenerator.vibrantColor?.color ?? Get.theme.colorScheme.secondary;
    } catch (e) {
      // استخدام ألوان افتراضية في حالة حدوث خطأ
      dominantColor.value = Get.theme.primaryColor;
      vibrantColor.value = Get.theme.colorScheme.secondary;
    } finally {
      isLoading.value = false;
    }
  }

  void launchTermsUrl() async {
    final Uri url = Uri.parse(offer.termsAndConditionsUrl);
    if (!await launchUrl(url)) {
      Get.snackbar('خطأ', 'لا يمكن فتح الرابط');
    }
  }

  void applyForOffer() {
    Get.toNamed(Routes.APPLICATION_FORM, arguments: offer);
  }
}