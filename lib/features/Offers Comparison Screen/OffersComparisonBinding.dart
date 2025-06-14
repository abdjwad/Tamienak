// presentation/modules/offers_comparison/bindings/offers_comparison_binding.dart
import 'package:get/get.dart';

import 'OffersComparisonController.dart';

class OffersComparisonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OffersComparisonController>(() => OffersComparisonController());
  }
}