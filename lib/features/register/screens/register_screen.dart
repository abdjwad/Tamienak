import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/data/enums/user_role.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/register_controller.dart';

// ثابت للمسافات العمودية لضمان التناسق
const _kVerticalSpace = SizedBox(height: 16.0);

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        centerTitle: true,
        backgroundColor: Colors.transparent, // لجعل الخلفية المتدرجة تظهر
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black, // لضمان وضوح أيقونة الرجوع
      ),
      extendBodyBehindAppBar: true, // للسماح للخلفية بالامتداد خلف شريط التطبيق
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // يمكنك إضافة رأس صفحة هنا إذا أردت، أو البدء مباشرة بالبطاقات
                  _buildHeader(theme),
                  const SizedBox(height: 24),

                  _buildGeneralInfoCard(),
                  _kVerticalSpace,
                  _buildRoleSelectionCard(theme),
                  _kVerticalSpace,
                  _buildServiceProviderSection(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                  _buildLoginLink(theme),

                ].animate(interval: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ودجة رأس الصفحة
  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(Icons.person_add_alt_1_rounded, size: 80, color: theme.primaryColor),
        const SizedBox(height: 16),
        Text('أنشئ حسابك الآن', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('انضم إلينا وابدأ رحلتك معنا', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
      ],
    );
  }

  /// بطاقة تحتوي على الحقول العامة
  Widget _buildGeneralInfoCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(label: 'الاسم الكامل', icon: Icons.person_outline, controller: controller.nameController, validator: (val) => val == null || val.isEmpty ? 'الرجاء إدخال الاسم' : null),
            _kVerticalSpace,
            _buildTextField(label: 'البريد الإلكتروني', icon: Icons.email_outlined, controller: controller.emailController, validator: (val) => val == null || !GetUtils.isEmail(val) ? 'بريد غير صالح' : null, keyboardType: TextInputType.emailAddress),
            _kVerticalSpace,
            Obx(() => _buildTextField(
              label: 'كلمة المرور',
              icon: Icons.lock_outline_rounded,
              controller: controller.passwordController,
              obscureText: controller.isPasswordHidden.value,
              suffixIcon: IconButton(
                icon: Icon(controller.isPasswordHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                onPressed: controller.togglePasswordVisibility,
              ),
              validator: (val) => val == null || val.length < 6 ? 'كلمة المرور يجب أن لا تقل عن 6 أحرف' : null,
            )),
            _kVerticalSpace,
            _buildTextField(label: 'تأكيد كلمة المرور', icon: Icons.lock_person_outlined, controller: controller.confirmPasswordController, obscureText: true, validator: (val) => val != controller.passwordController.text ? 'كلمتا المرور غير متطابقتين' : null),
          ],
        ),
      ),
    );
  }

  /// بطاقة تحتوي على أزرار اختيار دور المستخدم
  Widget _buildRoleSelectionCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أنا أسجل بصفتي:', style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() => Center(
              child: ToggleButtons(
                isSelected: [
                  controller.selectedRole.value == UserRole.beneficiary,
                  controller.selectedRole.value == UserRole.serviceProvider,
                ],
                onPressed: (index) {
                  controller.selectedRole.value = index == 0 ? UserRole.beneficiary : UserRole.serviceProvider;
                },
                borderRadius: BorderRadius.circular(12),
                borderColor: theme.colorScheme.primary.withOpacity(0.5),
                selectedBorderColor: theme.colorScheme.primary,
                selectedColor: Colors.white,
                fillColor: theme.colorScheme.primary,
                constraints: BoxConstraints(minWidth: (Get.width / 2) - 70, minHeight: 48),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('مستفيد')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('مقدم خدمة')),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// ودجة متحركة تحتوي على بطاقة بيانات مقدم الخدمة
  Widget _buildServiceProviderSection() {
    return Obx(() => AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: controller.selectedRole.value == UserRole.serviceProvider
          ? _buildServiceProviderCard()
          : const SizedBox.shrink(key: ValueKey('emptySizedBox')),
    ));
  }

  /// بناء بطاقة بيانات مقدم الخدمة الفعلية
  Widget _buildServiceProviderCard() {
    return Card(
      key: const ValueKey('serviceProviderCard'),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDropdown(
              label: 'نوع المهنة',
              items: controller.professionTypes,
              value: controller.selectedProfession.value,
              onChanged: (val) => controller.selectedProfession.value = val,
            ),
            _kVerticalSpace,
            _buildTextField(label: 'رقم الترخيص المهني', icon: Icons.confirmation_number_outlined, controller: controller.licenseNumberController, validator: (val) => val == null || val.isEmpty ? 'أدخل رقم الترخيص' : null),
            _kVerticalSpace,
            _buildTextField(label: 'الجهة المانحة للترخيص', icon: Icons.gavel_outlined, controller: controller.licenseIssuerController, validator: (val) => val == null || val.isEmpty ? 'أدخل الجهة المانحة' : null),
            _kVerticalSpace,
            _buildTextField(label: 'سنوات الخبرة', icon: Icons.history_edu_outlined, controller: controller.experienceYearsController, keyboardType: TextInputType.number, validator: (val) => val == null || val.isEmpty ? 'أدخل عدد سنوات الخبرة' : null),
          ],
        ),
      ),
    );
  }

  /// ودجة لزر إنشاء الحساب
  Widget _buildSubmitButton() {
    return Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton(
      onPressed: controller.register,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        shadowColor: Get.theme.primaryColor.withOpacity(0.4),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
      ),
      child: const Text('إنشاء الحساب'),
    ).animate(target: controller.registerErrorAnimation.value ? 1 : 0).shakeX(duration: 500.ms, amount: 10));
  }

  /// ودجة رابط الانتقال لصفحة تسجيل الدخول
  Widget _buildLoginLink(ThemeData theme) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            const TextSpan(text: 'لديك حساب بالفعل؟ '),
            TextSpan(
              text: 'سجّل الدخول',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  // --- التوابع المساعدة لبناء حقول الإدخال (نفس تصميم شاشة تسجيل الدخول) ---

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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.primaryColor, width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?>? onChanged,
  }) {
    final theme = Get.theme;
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null || val.isEmpty ? 'الرجاء اختيار نوع المهنة' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.work_outline_rounded, color: theme.primaryColor),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.primaryColor, width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
    );
  }
}