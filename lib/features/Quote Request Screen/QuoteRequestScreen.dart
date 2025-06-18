// presentation/modules/quote_request/screens/quote_request_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'QuoteRequestController.dart';

// وُدجة للحفاظ على حالة كل صفحة في PageView
class StepPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final GlobalKey<FormState>? formKey;
  final bool isReviewStep;

  const StepPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.content,
    this.formKey,
    this.isReviewStep = false,
  }) : super(key: key);

  @override
  State<StepPage> createState() => _StepPageState();
}

class _StepPageState extends State<StepPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // هذا هو السطر الذي يحل مشكلة فقدان البيانات

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Get.theme;
    final isDark = theme.brightness == Brightness.dark;
    final contentWidget = widget.isReviewStep ? widget.content : Form(key: widget.formKey, child: widget.content);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(widget.subtitle, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 32),
                    contentWidget,
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).moveY(begin: 30, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

// ======================================================================

class QuoteRequestScreen extends GetView<QuoteRequestController> {
  const QuoteRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("طلب عرض سعر لـ ${controller.insuranceType.name}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: Obx(() => _buildProgressBar(
            totalSteps: controller.totalSteps,
            currentStep: controller.currentPageIndex.value,
          )),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF2D3436), const Color(0xFF1E272E)]
                : [colorScheme.primary, const Color(0xFF5D54A4)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) { controller.currentPageIndex.value = index; },
                  children: [
                    StepPage(
                      formKey: controller.formKeys[0],
                      title: "لنبدأ بالمعلومات الأساسية...",
                      subtitle: "نحتاجها للتواصل معك بخصوص العروض.",
                      content: _buildContactInfoStep(),
                    ),
                    StepPage(
                      formKey: controller.formKeys[1],
                      title: "رائع! الآن، تفاصيل الطلب...",
                      subtitle: "أخبرنا المزيد عن ${controller.insuranceType.name}.",
                      content: _buildDynamicFields(context),
                    ),
                    StepPage(
                      isReviewStep: true,
                      title: "مراجعة أخيرة لطلبك",
                      subtitle: "تأكد من أن جميع المعلومات صحيحة قبل الإرسال.",
                      content: _buildReviewStep(context),
                    ),
                  ],
                ),
              ),
              _buildNavigationControls(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfoStep() {
    return Column(
      children: [
        _buildTextField(controller: controller.commonNameController, label: "الاسم الكامل", icon: Icons.person_outline, validator: (v) => v!.isEmpty ? 'مطلوب' : null),
        _buildTextField(controller: controller.commonPhoneController, label: "رقم الهاتف", icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'مطلوب' : null),
        _buildTextField(controller: controller.commonEmailController, label: "البريد الإلكتروني", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => GetUtils.isEmail(v!) ? null : 'بريد غير صحيح'),
      ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2),
    );
  }

  Widget _buildDynamicFields(BuildContext context) {
    List<Widget> fields = [];
    switch (controller.insuranceType.id) {
      case 'car':
        fields.addAll([
          _buildTextField(controller: controller.carModelController, label: "موديل السيارة", icon: Icons.directions_car_outlined, validator: (v) => v!.isEmpty ? 'مطلوب' : null),
          _buildTextField(controller: controller.carYearController, label: "سنة الصنع", icon: Icons.calendar_today_outlined, keyboardType: TextInputType.number, maxLength: 4, validator: (v) => (v!.isEmpty || int.tryParse(v) == null || v.length != 4) ? 'غير صالح' : null),
        ]);
        break;
      case 'health':
        fields.addAll([
          _buildDateField(context: context, controller: controller.healthDateOfBirthController, label: "تاريخ الميلاد", icon: Icons.cake_outlined, onTap: () => controller.selectDate(context, controller.healthDateOfBirthController), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
          _buildTextField(controller: controller.healthWeightController, label: "الوزن (كجم)", icon: Icons.monitor_weight_outlined, keyboardType: TextInputType.number, validator: (v) => (v!.isEmpty || int.tryParse(v) == null) ? 'مطلوب' : null),
          _buildTextField(controller: controller.healthHeightController, label: "الطول (سم)", icon: Icons.height_outlined, keyboardType: TextInputType.number, validator: (v) => (v!.isEmpty || int.tryParse(v) == null) ? 'مطلوب' : null),
        ]);
        break;
      case 'travel':
        fields.addAll([
          _buildTextField(controller: controller.travelDestinationController, label: "الوجهة", icon: Icons.public_outlined, validator: (v) => v!.isEmpty ? 'مطلوب' : null),
          _buildDateField(context: context, controller: controller.travelStartDateController, label: "تاريخ المغادرة", icon: Icons.flight_takeoff_outlined, onTap: () => controller.selectDate(context, controller.travelStartDateController), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
          _buildDateField(context: context, controller: controller.travelEndDateController, label: "تاريخ العودة", icon: Icons.flight_land_outlined, onTap: () => controller.selectDate(context, controller.travelEndDateController), validator: (v) {
            if (v!.isEmpty) return 'مطلوب';
            try {
              if (controller.travelStartDateController.text.isNotEmpty) {
                if (DateFormat('dd/MM/yyyy').parse(v).isBefore(DateFormat('dd/MM/yyyy').parse(controller.travelStartDateController.text))) return 'يجب أن يكون بعد المغادرة';
              }
            } catch (e) {/* ignore */}
            return null;
          }),
        ]);
        break;
      default:
        fields.add(const Center(child: Text("لا توجد حقول إضافية", style: TextStyle(color: Colors.white70))));
    }
    return Column(children: fields.animate(interval: 100.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2));
  }

  // === الكود المصحح هنا (تم إزالة Obx) ===
  Widget _buildReviewStep(BuildContext context) {
    return Column(
      children: [
        _buildReviewSection(
            title: "معلومات التواصل",
            onEdit: () => controller.goToPage(0),
            children: [
              _buildReviewRow("الاسم:", controller.commonNameController.text),
              _buildReviewRow("الهاتف:", controller.commonPhoneController.text),
              _buildReviewRow("البريد:", controller.commonEmailController.text),
            ]
        ),
        const SizedBox(height: 24),
        _buildReviewSection(
            title: "تفاصيل الطلب",
            onEdit: () => controller.goToPage(1),
            children: _getDynamicReviewRows()
        ),
      ],
    );
  }

  List<Widget> _getDynamicReviewRows() {
    List<Widget> rows = [];
    switch (controller.insuranceType.id) {
      case 'car':
        rows.add(_buildReviewRow("موديل السيارة:", controller.carModelController.text));
        rows.add(_buildReviewRow("سنة الصنع:", controller.carYearController.text));
        break;
      case 'health':
        rows.add(_buildReviewRow("تاريخ الميلاد:", controller.healthDateOfBirthController.text));
        rows.add(_buildReviewRow("الوزن:", "${controller.healthWeightController.text} كجم"));
        rows.add(_buildReviewRow("الطول:", "${controller.healthHeightController.text} سم"));
        break;
      case 'travel':
        rows.add(_buildReviewRow("الوجهة:", controller.travelDestinationController.text));
        rows.add(_buildReviewRow("تاريخ المغادرة:", controller.travelStartDateController.text));
        rows.add(_buildReviewRow("تاريخ العودة:", controller.travelEndDateController.text));
        break;
      default:
        rows.add(_buildReviewRow("بيانات إضافية:", "لا يوجد"));
    }
    return rows;
  }

  Widget _buildReviewSection({required String title, required List<Widget> children, required VoidCallback onEdit}) {
    final theme = Get.theme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(onPressed: onEdit, icon: Icon(Icons.edit_outlined, color: theme.colorScheme.secondary), tooltip: "تعديل"),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Colors.white24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    final theme = Get.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.1),
            border: Border(top: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1))),
          ),
          child: Obx(() => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Row(
            children: [
              if (controller.currentPageIndex.value > 0)
                TextButton(
                  onPressed: controller.previousPage,
                  child: const Text("السابق", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              const Spacer(),
              ElevatedButton.icon(
                icon: Icon(controller.currentPageIndex.value == controller.totalSteps - 1 ? Icons.send_rounded : Icons.arrow_forward_rounded),
                label: Text(controller.currentPageIndex.value == controller.totalSteps - 1 ? "تأكيد وإرسال" : "التالي"),
                onPressed: controller.currentPageIndex.value == controller.totalSteps - 1 ? controller.submitQuoteRequest : controller.nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                  shadowColor: colorScheme.secondary.withOpacity(0.5),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildProgressBar({required int totalSteps, required int currentStep}) {
    final colorScheme = Get.theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6.0,
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              decoration: BoxDecoration(
                color: index <= currentStep ? colorScheme.secondary : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    final theme = Get.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white.withOpacity(0.7)) : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.error, width: 2)),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    IconData? icon,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    final theme = Get.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white.withOpacity(0.7)) : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.error, width: 2)),
        ),
        validator: validator,
      ),
    );
  }
}