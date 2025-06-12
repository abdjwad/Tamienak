import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  // <-- متغير جديد لتشغيل حركة الاهتزاز عند الخطأ
  var registerErrorAnimation = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        await Future.delayed(const Duration(seconds: 2));

        // --- محاكاة خطأ في التسجيل لعرض الحركة ---
        Get.offAllNamed(Routes.HOME);

        // في حال النجاح
        // Get.offAllNamed(Routes.HOME);

      } catch (e) {
        // --- هنا نشغل حركة الاهتزاز ---
        registerErrorAnimation.value = !registerErrorAnimation.value;

        Get.snackbar(
          'خطأ في التسجيل',
          'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      // إذا كانت الحقول غير صالحة، شغل الحركة أيضاً
      registerErrorAnimation.value = !registerErrorAnimation.value;
    }
  }
}