// lib/features/login/controllers/login_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

class LoginController extends GetxController {
  // GlobalKey to validate the form
  final formKey = GlobalKey<FormState>();

  // TextEditingControllers for email and password
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // Observable variables for reactive UI
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var loginErrorAnimation = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    // Dispose controllers to free up memory
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Method to toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // The core login method
  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        await Future.delayed(const Duration(seconds: 2));

        // --- محاكاة خطأ في تسجيل الدخول ---
        // في هذا المثال، سنفترض دائماً حدوث خطأ لعرض الحركة
        Get.offAllNamed(Routes.HOME);

        // ... (منطق النجاح)

      } catch (e) {
        // --- هنا نشغل حركة الاهتزاز ---
        loginErrorAnimation.value = !loginErrorAnimation.value;

        Get.snackbar(
          'خطأ',
          'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }
}