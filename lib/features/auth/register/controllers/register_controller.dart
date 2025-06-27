import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamienk/app/data/enums/user_role.dart';
import 'package:tamienk/app/routes/app_routes.dart';


class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // الحقول العامة
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  // الحقول الخاصة بمقدم الخدمة
  late TextEditingController licenseNumberController;
  late TextEditingController licenseIssuerController;
  late TextEditingController experienceYearsController;

  // الحالة
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var registerErrorAnimation = false.obs;

  // الدور المختار
  var selectedRole = UserRole.beneficiary.obs;

  // نوع المهنة المختار
  var selectedProfession = RxnString();
  List<String> professionTypes = [
    'طبيب',
    'مشفى',
    'مختبر',
    'شركة تأمين',
  ];

  @override
  void onInit() {
    super.onInit();

    // تهيئة الحقول
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    licenseNumberController = TextEditingController();
    licenseIssuerController = TextEditingController();
    experienceYearsController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    licenseNumberController.dispose();
    licenseIssuerController.dispose();
    experienceYearsController.dispose();

    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> register() async {
    final isFormValid = formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      registerErrorAnimation.toggle();
      return;
    }

    // تحقق إضافي لمقدم الخدمة
    if (selectedRole.value == UserRole.serviceProvider) {
      if (selectedProfession.value == null ||
          licenseNumberController.text.isEmpty ||
          licenseIssuerController.text.isEmpty ||
          experienceYearsController.text.isEmpty) {
        registerErrorAnimation.toggle();
        Get.snackbar(
          'بيانات ناقصة',
          'يرجى تعبئة كافة الحقول الخاصة بمقدم الخدمة.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
    }

    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 2));

      // تخزين وهمي / توجيه حسب الدور
      if (selectedRole.value == UserRole.serviceProvider) {
        Get.offAllNamed(Routes.SERVICE_PROVIDER_DASHBOARD);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      registerErrorAnimation.toggle();
      Get.snackbar(
        'خطأ في التسجيل',
        'حدث خطأ غير متوقع، حاول مرة أخرى.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
