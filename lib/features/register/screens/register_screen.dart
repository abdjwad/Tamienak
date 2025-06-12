import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'انضم إلينا!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'أنشئ حسابك لتبدأ رحلتك معنا',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) => (value == null || value.isEmpty) ? 'الرجاء إدخال اسمك' : null,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                Obx(() => TextFormField(
                  controller: controller.confirmPasswordController,
                  obscureText: controller.isPasswordHidden.value,
                  decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور', prefixIcon: Icon(Icons.lock_outline_rounded)),
                  validator: (value) => (value != controller.passwordController.text) ? 'كلمتا المرور غير متطابقتين' : null,
                )),
                const SizedBox(height: 32),
                Obx(() => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: controller.register,
                  child: const Text('إنشاء الحساب'),
                ).animate(target: controller.registerErrorAnimation.value ? 1: 0)
                    .shake(hz: 10, duration: 400.ms), // --- هنا الكود المصحح لحركة الاهتزاز ---
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