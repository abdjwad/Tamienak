// presentation/modules/quote_request/bindings/quote_request_binding.dart
import 'package:get/get.dart';

import 'QuoteRequestController.dart';

class QuoteRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuoteRequestController>(() => QuoteRequestController());
  }
}
