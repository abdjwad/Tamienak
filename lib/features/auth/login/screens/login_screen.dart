// lib/features/auth/screens/login_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // استخدام خلفية متدرجة لإضافة لمسة جمالية
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF2D3436), const Color(0xFF1E272E)]
                : [theme.primaryColor.withOpacity(0.1), Colors.white],
            stops: const [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 40),
                    _buildLoginForm(theme),
                    const SizedBox(height: 32),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildRegisterLink(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ودجة رأس الصفحة مع تأثيرات حركية جذابة
  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(Icons.lock_open_rounded, size: 80, color: theme.primaryColor)
            .animate()
            .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
            .shimmer(duration: 1500.ms, color: theme.primaryColor.withOpacity(0.3)),
        const SizedBox(height: 16),
        Text(
          'مرحباً بعودتك!',
          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.5),
        const SizedBox(height: 8),
        Text(
          'سجّل دخولك للوصول إلى خدماتنا',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
        ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
      ],
    );
  }

  /// ودجة حقول تسجيل الدخول مع رابط "نسيت كلمة المرور"
  Widget _buildLoginForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: controller.emailController,
          label: 'البريد الإلكتروني',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) =>
          (value == null || !GetUtils.isEmail(value)) ? 'أدخل بريداً صحيحاً' : null,
        ),
        const SizedBox(height: 16),
        Obx(() => _buildTextField(
          controller: controller.passwordController,
          label: 'كلمة المرور',
          icon: Icons.lock_outline_rounded,
          obscureText: controller.isPasswordHidden.value,
          validator: (value) =>
          (value == null || value.length < 6) ? 'كلمة المرور قصيرة جداً' : null,
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordHidden.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        )),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () {
              // TODO: Implement forgot password logic
              Get.snackbar('قيد التطوير', 'سيتم إضافة صفحة استعادة كلمة المرور قريباً');
            },
            child: Text(
              'هل نسيت كلمة المرور؟',
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideX(begin: -0.2);
  }

  /// ودجة زر تسجيل الدخول الرئيسي
  Widget _buildLoginButton() {
    return Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton(
      onPressed: controller.login,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        shadowColor: Get.theme.primaryColor.withOpacity(0.4),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
      ),
      child: const Text('تسجيل الدخول'),
    ).animate(target: controller.loginErrorAnimation.value ? 1 : 0)
        .shakeX(duration: 500.ms, amount: 10)
    ).animate().fadeIn(delay: 700.ms, duration: 500.ms);
  }

  /// ودجة رابط الانتقال لصفحة التسجيل باستخدام RichText
  Widget _buildRegisterLink(ThemeData theme) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            const TextSpan(text: 'ليس لديك حساب؟ '),
            TextSpan(
              text: 'أنشئ واحداً الآن',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(Routes.REGISTER),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 500.ms);
  }

  /// ودجة مساعدة لبناء حقول الإدخال بتصميم موحد
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    final theme = Get.theme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: theme.primaryColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}