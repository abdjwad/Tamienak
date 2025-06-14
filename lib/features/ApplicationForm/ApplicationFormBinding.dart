// presentation/modules/application_form/bindings/application_form_binding.dart
import 'package:get/get.dart';
import 'package:tamienk/features/ApplicationForm/ApplicationFormController.dart';

class ApplicationFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApplicationFormController>(
      () => ApplicationFormController(),
    );
  }
}
