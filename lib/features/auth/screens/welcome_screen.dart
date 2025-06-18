import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tamienk/app/routes/app_routes.dart';
import '../../../app/routes/app_pages.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1E272E), const Color(0xFF2D3436)]
                : [Colors.white, theme.primaryColor.withOpacity(0.2)],
            stops: const [0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // ==================== التصحيح النهائي هنا ====================
                // تم تغليف Lottie داخل SizedBox لتجنب تعارض الأسماء
                SizedBox(
                  height: 300,
                  child: Lottie.asset(
                    'assets/animations/family_security.json',
                    repeat: true,
                  ),
                )
                    .animate() // يتم تطبيق الأنيميشن الآن على SizedBox بشكل آمن
                    .fadeIn(duration: 900.ms)
                    .scale(
                  delay: 200.ms,
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
                // ==========================================================
                const Spacer(),
                Text(
                  'أمانك وأمان عائلتك،\nأولويتنا القصوى',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: isDark ? Colors.white : theme.primaryColorDark,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOut),

                const SizedBox(height: 16),

                Text(
                  'نقدم لك أفضل حلول التأمين التي تمنحك راحة البال التي تستحقها.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

                const Spacer(flex: 2),

                _buildButtons(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => Get.toNamed(Routes.REGISTER),
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.theme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 5,
            shadowColor: Get.theme.primaryColor.withOpacity(0.4),
          ),
          child: const Text('ابدأ الآن (إنشاء حساب)'),
        ),

        const SizedBox(height: 12),

        ElevatedButton(
          onPressed: () => Get.toNamed(Routes.LOGIN),
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.theme.colorScheme.surface,
            foregroundColor: Get.theme.primaryColor,
            minimumSize: const Size.fromHeight(55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Get.theme.primaryColor, width: 2),
            ),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 0,
          ),
          child: const Text('لدي حساب بالفعل'),
        ),
      ],
    ).animate().fadeIn(delay: 900.ms, duration: 600.ms).slideY(begin: 0.5, curve: Curves.easeOut);
  }
}