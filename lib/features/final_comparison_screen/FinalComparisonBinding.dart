import 'package:get/get.dart';

import 'FinalComparisoncontroller.dart';

class FinalComparisonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinalComparisonController>(() => FinalComparisonController());
  }
}