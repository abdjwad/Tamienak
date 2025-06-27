// lib/features/application_form/screens/application_form_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tamienk/features/ApplicationForm/ApplicationFormController.dart';

// تأكد من أن هذا المسار صحيح
import '../../app/theme/app_them.dart';

class ApplicationFormScreen extends GetView<ApplicationFormController> {
  const ApplicationFormScreen({Key? key}) : super(key: key);

  static final List<Map<String, dynamic>> _steps = [
    {'title': 'المعلومات الشخصية', 'icon': Icons.account_circle_outlined},
    {'title': 'تفاصيل المركبة', 'icon': Icons.directions_car_outlined},
    {'title': 'بيانات إضافية', 'icon': Icons.add_location_alt_outlined},
    {'title': 'المستندات والموافقة', 'icon': Icons.file_copy_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color accentColor = AppTheme.accentColor;
    final Color backgroundColor = Color.lerp(primaryColor, Colors.black, 0.85)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          _buildAnimatedBackground(primaryColor, accentColor),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      Widget content;
                      switch (index) {
                        case 0:
                          content = _buildStep1PersonalDetails(context);
                          break;
                        case 1:
                          content = _buildStep2VehicleDetails(context);
                          break;
                        case 2:
                          content = _buildStep3AdditionalInfo(context);
                          break;
                        default:
                          content = _buildStep4DocumentsAndTerms(context);
                      }
                      return _buildGlassCard(
                        index: index,
                        child: content,
                      );
                    },
                  ),
                ),
                _buildNavigationButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- دوال بناء الواجهة الرئيسية ---

  Widget _buildAnimatedBackground(Color color1, Color color2) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1.withOpacity(0.3), color2.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -100, left: -100, child: _buildBlob(color1, 300)),
          Positioned(bottom: -150, right: -150, child: _buildBlob(color2, 400)),
        ],
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .move(duration: GetNumUtils(20).seconds, begin: Offset.zero, end: const Offset(50, -50))
        .then(delay: GetNumUtils(5).seconds)
        .move(duration: GetNumUtils(25).seconds, begin: Offset.zero, end: const Offset(-50, 50));
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Obx(
            () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_steps.length, (index) {
            final bool isActive = index == controller.currentStep.value;
            final bool isCompleted = index < controller.currentStep.value;

            Widget stepIndicator = _buildStepIndicator(
              context: context,
              index: index,
              isActive: isActive,
              isCompleted: isCompleted,
            );

            if (index < _steps.length - 1) {
              return Expanded(
                child: Row(
                  children: [
                    stepIndicator,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: AnimatedContainer(
                          duration: 400.ms,
                          height: 2,
                          color: isCompleted ? AppTheme.accentColor : Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return stepIndicator;
          }),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildStepIndicator({required BuildContext context, required int index, required bool isActive, required bool isCompleted}) {
    final Color activeColor = AppTheme.accentColor;
    final Color inactiveColor = Colors.white.withOpacity(0.5);
    final Color completedColor = Theme.of(context).colorScheme.primary;
    final Color targetColor = isCompleted ? completedColor : (isActive ? activeColor : inactiveColor);
    final double targetScale = isActive ? 1.2 : 1.0;

    return AnimatedScale(
      scale: targetScale,
      duration: 300.ms,
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: 300.ms,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: targetColor.withOpacity(isActive || isCompleted ? 1.0 : 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: targetColor, width: 2),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: activeColor.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              )
          ],
        ),
        child: Center(
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : Icon(_steps[index]['icon'], color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required int index, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ),
      ),
    ).animate(key: ValueKey(index)).fadeIn(duration: 500.ms).slideY(begin: 0.1, curve: Curves.easeOut);
  }

  // --- دوال بناء محتوى الخطوات ---

  Widget _buildStep1PersonalDetails(BuildContext context) {
    return Form(
      key: controller.formKeys[0],
      child: Column(
        children: [
          _buildSectionHeader(
            context: context,
            icon: _steps[0]['icon'],
            title: _steps[0]['title'],
            subtitle: "لنبدأ بمعلوماتك الأساسية.",
          ),
          _buildTextField(context: context, label: "الاسم الكامل", controller: controller.fullNameController, validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildTextField(context: context, label: "الرقم الوطني", controller: controller.nationalIdController, keyboardType: TextInputType.number, validator: (v) => v!.length != 11 ? 'يجب أن يكون 11 رقمًا' : null),
          _buildTextField(context: context, label: "رقم الهاتف", controller: controller.phoneNumberController, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildTextField(context: context, label: "البريد الإلكتروني", controller: controller.emailController, keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty || !GetUtils.isEmail(v) ? 'بريد إلكتروني غير صحيح' : null),
          _buildDateField(context: context, label: "تاريخ الميلاد", controller: controller.dateOfBirthController, onTap: () { final minAgeDate = DateTime.now().subtract(const Duration(days: 365 * 18)); controller.selectDate(context, controller.dateOfBirthController, initialDate: minAgeDate, lastDate: minAgeDate, firstDate: DateTime(1920));}, validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
        ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildStep2VehicleDetails(BuildContext context) {
    return Form(
      key: controller.formKeys[1],
      child: Column(
        children: [
          _buildSectionHeader(context: context, icon: _steps[1]['icon'], title: _steps[1]['title'], subtitle: "أخبرنا عن سيارتك."),
          _buildTextField(context: context, label: "ماركة السيارة", controller: controller.vehicleMakeController, validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildTextField(context: context, label: "موديل السيارة", controller: controller.vehicleModelController, validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildTextField(context: context, label: "سنة الصنع", controller: controller.vehicleYearController, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
        ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildStep3AdditionalInfo(BuildContext context) {
    return Form(
      key: controller.formKeys[2],
      child: Column(
        children: [
          _buildSectionHeader(context: context, icon: _steps[2]['icon'], title: _steps[2]['title'], subtitle: "معلومات تكميلية للوثيقة."),
          _buildTextField(context: context, label: "العنوان التفصيلي", controller: controller.addressController, maxLines: 3, validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildDateField(context: context, label: "تاريخ بدء التأمين", controller: controller.policyStartDateController, onTap: () => controller.selectDate(context, controller.policyStartDateController, initialDate: DateTime.now(), firstDate: DateTime.now()), validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
        ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildStep4DocumentsAndTerms(BuildContext context) {
    return Form(
      key: controller.formKeys[3],
      child: Column(
        children: [
          _buildSectionHeader(context: context, icon: _steps[3]['icon'], title: _steps[3]['title'], subtitle: "الخطوة الأخيرة!"),
          _buildImagePickerField(context: context, label: "صورة الهوية (الأمام)", docType: 'nationalIdFront', controller: controller, validator: (img) => img == null || img.isEmpty ? 'مطلوب' : null),
          _buildImagePickerField(context: context, label: "صورة الهوية (الخلف)", docType: 'nationalIdBack', controller: controller, validator: (img) => img == null || img.isEmpty ? 'مطلوب' : null),
          const SizedBox(height: 24),
          Obx(() => _buildTermsAndConditions(context)),
        ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
      ),
    );
  }

  // --- دوال بناء الواجهة المساعدة ---

  Widget _buildSectionHeader({required BuildContext context, required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTextField({required BuildContext context, required String label, required TextEditingController controller, String? Function(String?)? validator, TextInputType? keyboardType, int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: 'Cairo'),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.accentColor, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
          errorStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  Widget _buildDateField({required BuildContext context, required String label, required TextEditingController controller, required VoidCallback onTap, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller, readOnly: true, onTap: onTap, validator: validator,
        style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: 'Cairo'),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.6)),
          filled: true, fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.accentColor, width: 2)),
          errorStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  Widget _buildImagePickerField({required BuildContext context, required String label, required String docType, required ApplicationFormController controller, bool multiple = false, String? Function(List<XFile>?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<List<XFile>>(
        initialValue: controller.selectedDocuments[docType],
        validator: (value) {
          // Manually trigger validation in the controller
          if (validator != null) {
            final images = controller.selectedDocuments[docType] ?? [];
            return validator(images.cast<XFile>());
          }
          return null;
        },
        builder: (state) {
          return Obx(() {
            final images = controller.selectedDocuments[docType] ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                if (state.hasError) Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(state.errorText!, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'Cairo')),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: [
                    ...images.map((image) => _buildImageThumbnail(context, image, () => controller.removeImage(docType, image))),
                    if (multiple || images.isEmpty)
                      _buildAddImageButton(context, () async {
                        await controller.pickImage(docType, multiple: multiple);
                        state.didChange(controller.selectedDocuments[docType]); // Update FormField state
                      }),
                  ],
                ),
              ],
            );
          });
        },
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, XFile image, VoidCallback onRemove) {
    return SizedBox(
      width: 85, height: 85,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(image.path), width: 85, height: 85, fit: BoxFit.cover),
          ).animate().fadeIn(),
          Positioned(
            top: -8, right: -8,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(50),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black.withOpacity(0.8),
                child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(BuildContext context, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 85, height: 85,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.white.withOpacity(0.8)),
            const SizedBox(height: 4),
            Text("إضافة", style: TextStyle(color: Colors.white.withOpacity(0.8), fontFamily: 'Cairo', fontSize: 12)),
          ],
        ),
      ),
    ).animate().scaleXY(delay: 100.ms, duration: 400.ms, begin: 0.8, curve: Curves.easeOutBack);
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    return InkWell(
      onTap: () => controller.agreedToTerms.value = !controller.agreedToTerms.value,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            AnimatedContainer(
              duration: 200.ms,
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: controller.agreedToTerms.value ? AppTheme.accentColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: controller.agreedToTerms.value ? AppTheme.accentColor : Colors.white.withOpacity(0.5), width: 2),
              ),
              child: controller.agreedToTerms.value ? const Icon(Icons.check, color: Colors.black, size: 18) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text("أوافق على الشروط والأحكام.", style: TextStyle(color: Colors.white.withOpacity(0.8), fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Obx(() => Row(
        children: [
          if (controller.currentStep.value > 0)
            TextButton(
              onPressed: controller.isLoading.value ? null : controller.previousStep,
              child: Text("السابق", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, fontFamily: 'Cairo')),
            ).animate(key: const ValueKey('prev_btn')).fadeIn().slideX(begin: -0.2),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.black,
            ),
            onPressed: controller.isLoading.value ? null : controller.nextStep,
            child: controller.isLoading.value
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
                : Row(
              children: [
                Text(
                  controller.currentStep.value == _steps.length - 1 ? "إرسال الطلب" : "التالي",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
                const SizedBox(width: 8),
                Icon(controller.currentStep.value == _steps.length - 1 ? Icons.send_rounded : Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ).animate(key: ValueKey('next_btn_${controller.currentStep.value}')).fadeIn().slideX(begin: 0.2),
        ],
      )),
    );
  }
}