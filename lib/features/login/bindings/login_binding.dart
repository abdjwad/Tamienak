// lib/features/login/bindings/login_binding.dart

import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Use lazyPut for efficiency. The controller will only be created when it's needed.
    Get.lazyPut<LoginController>(() => LoginController());
  }
}