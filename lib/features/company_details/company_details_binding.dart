// مسار الملف: lib/features/company_details/bindings/company_details_binding.dart

import 'package:get/get.dart';

import 'company_details_controller.dart' show CompanyDetailsController;

class CompanyDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyDetailsController>(() => CompanyDetailsController());
  }
}