import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'أهلاً بعودتك!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'الرجاء تسجيل الدخول للمتابعة',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) => (value == null || !GetUtils.isEmail(value)) ? 'الرجاء إدخال بريد إلكتروني صحيح' : null,
                ),
                const SizedBox(height: 16),
                Obx(() => TextFormField(
                  controller: controller.passwordController,
                  obscureText: controller.isPasswordHidden.value,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) => (value == null || value.length < 6) ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : null,
                )),
                const SizedBox(height: 32),
                Obx(() => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: controller.login,
                  child: const Text('تسجيل الدخول'),
                ).animate(target: controller.loginErrorAnimation.value ? 1 : 0)
                    .shake(hz: 10, duration: 400.ms), // --- هنا الكود المصحح لحركة الاهتزاز ---
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("ليس لديك حساب؟", style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.REGISTER),
                      child: const Text('إنشاء حساب جديد'),
                    ),
                  ],
                ),
              ],
            ).animate() // --- حركة ظهور الشاشة بالكامل ---
                .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }
}