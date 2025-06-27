// lib/features/login/controllers/login_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/enums/user_role.dart';
import '../../../../app/routes/app_routes.dart';


class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  late TextEditingController emailController;
  late TextEditingController passwordController;

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var loginErrorAnimation = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    // إزالة أي قيم افتراضية لجعل الحقول فارغة
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true; // ابدأ التحميل

      try {
        await Future.delayed(const Duration(seconds: 2)); // محاكاة عملية تسجيل الدخول

        UserRole userRole;
        if (emailController.text == 'beneficiary@example.com' && passwordController.text == 'password123') {
          userRole = UserRole.beneficiary;
        } else if (emailController.text == 'service_provider@example.com' && passwordController.text == 'password123') {
          userRole = UserRole.serviceProvider;
        } else {
          throw Exception('بيانات الاعتماد غير صحيحة');
        }

        // --- مسار النجاح ---
        // عرض السناك بار أولاً
        Get.snackbar('نجاح', 'تم تسجيل الدخول بنجاح.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 1)); // مدة قصيرة

        // بعد ذلك مباشرةً، انتقل. لا داعي لتحديث isLoading/animation هنا، فالشاشة ستُزال.
        if (userRole == UserRole.beneficiary) {
          Get.offAllNamed(Routes.HOME);
        } else if (userRole == UserRole.serviceProvider) {
          Get.offAllNamed(Routes.SERVICE_PROVIDER_DASHBOARD);
        }

      } catch (e) {
        // --- مسار الخطأ ---
        // تحديث حالة التحميل والأنيميشن *فقط إذا كان المتحكم لا يزال نشطاً*
        if (!isClosed) {
          isLoading.value = false; // توقف التحميل
          loginErrorAnimation.value = !loginErrorAnimation.value; // تفعيل حركة الاهتزاز
        }

        Get.snackbar(
          'خطأ في تسجيل الدخول',
          'البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى التأكد من البيانات والمحاولة مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // إعادة تعيين أنيميشن الاهتزاز بعد فترة قصيرة
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!isClosed) {
            loginErrorAnimation.value = false;
          }
        });
      }
      // إزالة finally block حيث تم التعامل مع isLoading في try/catch
    }
  }
}