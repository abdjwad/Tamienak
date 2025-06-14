// presentation/modules/offer_details/controllers/offer_details_controller.dart

import 'package:get/get.dart';
import 'package:tamienk/app/routes/app_routes.dart';
import '../../../app/data/models/insurance_offer_model.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- هذا السطر يجب أن يكون موجوداً


class OfferDetailsController extends GetxController {
  late final InsuranceOffer offer;

  @override
  void onInit() {
    super.onInit();
    // استلام كائن العرض من الشاشة السابقة
    offer = Get.arguments as InsuranceOffer;
  }

  // دالة لفتح رابط الشروط والأحكام
  void launchTermsUrl() async {
    final Uri url = Uri.parse(offer.termsAndConditionsUrl);
    if (!await launchUrl(url)) {
      Get.snackbar('خطأ', 'لا يمكن فتح الرابط');
    }
  }

  // دالة للتقديم على الطلب
  void applyForOffer() {
    Get.toNamed(Routes.APPLICATION_FORM, arguments: offer);
  }
}