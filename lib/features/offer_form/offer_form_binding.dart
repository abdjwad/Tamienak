// lib/features/offer_form/bindings/offer_form_binding.dart
import 'package:get/get.dart';

import 'offer_form_controller.dart';

class OfferFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OfferFormController>(
          () => OfferFormController(),
    );
  }
}