import 'package:get/get.dart';
import 'package:tamienk/features/company_list/company_list_controller.dart';

class CompanyListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyListController>(() => CompanyListController());
  }
}