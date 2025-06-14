// presentation/modules/offer_details/bindings/offer_details_binding.dart

import 'package:get/get.dart';

import 'OfferDetailsController.dart';

class OfferDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OfferDetailsController>(() => OfferDetailsController());
  }
}