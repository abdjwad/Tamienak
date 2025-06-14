// presentation/modules/application_form/screens/application_form_screen.dart
import 'dart:io'; // لاستخدام File.fromUri
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // <--- استيراد مكتبة الصور
import 'package:tamienk/features/ApplicationForm/ApplicationFormController.dart';

class ApplicationFormScreen extends GetView<ApplicationFormController> {
  const ApplicationFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatCurrency =
        NumberFormat.currency(locale: 'ar_SY', symbol: 'ل.س', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text("تقديم طلب لـ ${controller.selectedOffer.companyName}"),
        centerTitle: true, // توسيط العنوان
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- قسم ملخص العرض المختار (تحسينات بصرية) ---
              Card(
                elevation: 6,
                // زيادة الظل
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                // حواف أكثر استدارة
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: colorScheme.surface,
                // لون خلفية البطاقة
                child: Padding(
                  padding: const EdgeInsets.all(20.0), // زيادة البادينج
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // محاذاة العناصر للأعلى
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        // حواف أكثر استدارة للصورة
                        child: Image.network(
                          controller.selectedOffer.companyLogoUrl,
                          width: 80, // حجم أكبر للصورة
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.business,
                              size: 80,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.4)),
                        ),
                      ),
                      const SizedBox(width: 20), // مسافة أكبر
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "العرض المختار من:",
                              style: theme.textTheme.labelLarge?.copyWith(
                                  color:
                                      colorScheme.onSurface.withOpacity(0.7)),
                            ),
                            Text(
                              controller.selectedOffer.companyName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatCurrency
                                  .format(controller.selectedOffer.annualPrice),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.selectedOffer.isBestValue)
                        Align(
                          alignment: Alignment.topRight,
                          // محاذاة الشيب للأعلى يمين
                          child: Chip(
                            label: const Text("الأفضل قيمة",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.amber.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                        ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin:  0.1), // انيميشن أخف وأسرع
              const SizedBox(height: 32),

              // --- قسم البيانات الشخصية ---
              Column(
                // يتم تجميع العنوان والحقول في عمود واحد لتطبيق الانيميشن عليه
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                      context, "البيانات الشخصية", Icons.person_outline),
                  _buildTextField(
                    controller: controller.fullNameController,
                    label: "الاسم الكامل",
                    hint: "أدخل اسمك كما هو في البطاقة الشخصية",
                    icon: Icons.person,
                    validator: (value) => value == null || value.isEmpty
                        ? 'الرجاء إدخال الاسم الكامل'
                        : null,
                  ),
                  _buildTextField(
                    controller: controller.nationalIdController,
                    label: "الرقم الوطني / رقم الهوية",
                    hint: "مثال: 1234567890",
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    validator: (value) => value == null || value.isEmpty
                        ? 'الرجاء إدخال الرقم الوطني / رقم الهوية'
                        : null,
                  ),
                  _buildTextField(
                    controller: controller.phoneNumberController,
                    label: "رقم الهاتف",
                    hint: "مثال: 09XXXXXXXX",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (value) => value == null || value.isEmpty
                        ? 'الرجاء إدخال رقم الهاتف'
                        : null,
                  ),
                  _buildTextField(
                    controller: controller.emailController,
                    label: "البريد الإلكتروني",
                    hint: "example@domain.com",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null ||
                            value.isEmpty ||
                            !GetUtils.isEmail(value)
                        ? 'الرجاء إدخال بريد إلكتروني صحيح'
                        : null,
                  ),
                  _buildDateField(
                    context: context,
                    controller: controller.dateOfBirthController,
                    label: "تاريخ الميلاد",
                    icon: Icons.calendar_today,
                    onTap: () => controller.selectDate(
                        context, controller.dateOfBirthController,
                        initialDate: DateTime.now()
                            .subtract(const Duration(days: 365 * 18)),
                        lastDate: DateTime.now()
                            .subtract(const Duration(days: 365 * 18))),
                    validator: (value) => value == null || value.isEmpty
                        ? 'الرجاء اختيار تاريخ الميلاد'
                        : null,
                  ),
                  Obx(() => _buildDropdownField(
                        value: controller.selectedGender.value,
                        items: ['ذكر', 'أنثى'],
                        label: "الجنس",
                        icon: Icons.wc,
                        onChanged: (String? newValue) =>
                            controller.selectedGender.value = newValue,
                        validator: (value) => value == null || value.isEmpty
                            ? 'الرجاء اختيار الجنس'
                            : null,
                      )),
                  Obx(() => _buildDropdownField(
                        value: controller.selectedMaritalStatus.value,
                        items: [
                          'أعزب/عزباء',
                          'متزوج/متزوجة',
                          'مطلق/مطلقة',
                          'أرمل/أرملة'
                        ],
                        label: "الحالة الاجتماعية",
                        icon: Icons.people,
                        onChanged: (String? newValue) =>
                            controller.selectedMaritalStatus.value = newValue,
                        validator: (value) => value == null || value.isEmpty
                            ? 'الرجاء اختيار الحالة الاجتماعية'
                            : null,
                      )),
                  _buildTextField(
                    controller: controller.occupationController,
                    label: "المهنة",
                    hint: "مثال: مهندس برمجيات",
                    icon: Icons.work,
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin:  0.1),
              const SizedBox(height: 32),

              // --- قسم تفاصيل السيارة (إذا كانت بوليصة سيارة) ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                      context, "تفاصيل المركبة (اختياري)", Icons.car_rental),
                  _buildTextField(
                    controller: controller.vehicleMakeController,
                    label: "ماركة السيارة",
                    hint: "مثال: تويوتا",
                    icon: Icons.car_repair,
                  ),
                  _buildTextField(
                    controller: controller.vehicleModelController,
                    label: "طراز السيارة",
                    hint: "مثال: كامري",
                    icon: Icons.model_training,
                  ),
                  _buildTextField(
                    controller: controller.vehicleYearController,
                    label: "سنة الصنع",
                    hint: "مثال: 2020",
                    icon: Icons.date_range,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final year = int.tryParse(value);
                        if (year == null ||
                            year < 1900 ||
                            year > DateTime.now().year + 1) {
                          return 'سنة صنع غير صالحة';
                        }
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: controller.plateNumberController,
                    label: "رقم لوحة السيارة",
                    hint: "مثال: أ ب ج 1234",
                    icon: Icons.numbers,
                  ),
                  _buildTextField(
                    controller: controller.chassisNumberController,
                    label: "رقم الشاصي (الهيكل)",
                    hint: "أدخل رقم الهيكل كاملاً",
                    icon: Icons.vpn_key_outlined,
                  ),
                  _buildTextField(
                    controller: controller.vehicleValueController,
                    label: "القيمة التقديرية للسيارة (ل.س)",
                    hint: "القيمة التي تقدرها لسيارتك",
                    icon: Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'قيمة غير صالحة';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin:0.1),
              const SizedBox(height: 32),

              // --- قسم معلومات العنوان وتاريخ بدء التأمين ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                      context, "معلومات إضافية", Icons.info_outline),
                  _buildTextField(
                    controller: controller.addressController,
                    label: "العنوان التفصيلي",
                    hint: "البلد، المدينة، الشارع، رقم البناء...",
                    icon: Icons.location_city,
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'الرجاء إدخال العنوان التفصيلي'
                        : null,
                  ),
                  _buildDateField(
                    context: context,
                    controller: controller.policyStartDateController,
                    label: "تاريخ بدء بوليصة التأمين",
                    icon: Icons.date_range,
                    onTap: () => controller.selectDate(
                        context, controller.policyStartDateController,
                        initialDate: DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 30))),
                    validator: (value) => value == null || value.isEmpty
                        ? 'الرجاء اختيار تاريخ بدء البوليصة'
                        : null,
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 600.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 32),

              // --- قسم المستندات المطلوبة (رفع الصور) ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                      context, "المستندات المطلوبة", Icons.file_upload),
                  _buildImagePickerField(
                    context: context,
                    label: "صورة الهوية الوطنية (الوجه الأمامي)",
                    docType: 'nationalIdFront',
                    controller: controller,
                    validator: (images) => images.isEmpty
                        ? 'الرجاء إرفاق صورة الهوية (الوجه الأمامي)'
                        : null,
                  ),
                  _buildImagePickerField(
                    context: context,
                    label: "صورة الهوية الوطنية (الوجه الخلفي)",
                    docType: 'nationalIdBack',
                    controller: controller,
                    validator: (images) => images.isEmpty
                        ? 'الرجاء إرفاق صورة الهوية (الوجه الخلفي)'
                        : null,
                  ),
                  _buildImagePickerField(
                    context: context,
                    label: "صورة رخصة القيادة (الوجه الأمامي) (اختياري)",
                    docType: 'licenseFront',
                    controller: controller,
                  ),
                  _buildImagePickerField(
                    context: context,
                    label: "صورة رخصة القيادة (الوجه الخلفي) (اختياري)",
                    docType: 'licenseBack',
                    controller: controller,
                  ),
                  _buildImagePickerField(
                    context: context,
                    label: "صور للمركبة (جوانب مختلفة) (اختياري)",
                    docType: 'vehiclePhotos',
                    controller: controller,
                    multiple: true,
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 800.ms)
                  .slideY(begin :0.1),
              const SizedBox(height: 32),

              // --- قسم الشروط والأحكام ---
              Obx(() => Row(
                        children: [
                          Checkbox(
                            value: controller.agreedToTerms.value,
                            onChanged: (bool? newValue) {
                              controller.agreedToTerms.value =
                                  newValue ?? false;
                            },
                            activeColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                controller.agreedToTerms.value =
                                    !controller.agreedToTerms.value;
                              },
                              child: Text(
                                "أوافق على ",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: controller.launchTermsUrl,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text("الشروط والأحكام",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ))
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 1000.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 32),

              // --- زر الإرسال ---
              Obx(() => Center(
                        child: controller.isLoading.value
                            ? CircularProgressIndicator(
                                color: colorScheme.primary)
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.send_outlined),
                                label: const Text("تقديم الطلب الآن"),
                                onPressed: controller.submitApplication,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 45),
                                  textStyle: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  elevation: 10,
                                  shadowColor:
                                      colorScheme.primary.withOpacity(0.4),
                                ),
                              ),
                      ))
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 1200.ms)
                  .slideY(begin:  0.1),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- ويدجتس مساعدة لتصميم الحقول (تم تحسينها) ---
  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 24.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          // فاصل بصري يمكن إضافته إذا لزم الأمر
          // const Expanded(child: Divider(thickness: 1, indent: 8)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(Get.context!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon, color: theme.colorScheme.primary)
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.5), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide:
                BorderSide(color: theme.colorScheme.primary, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2.5),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          alignLabelWithHint: maxLines > 1,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          errorStyle: TextStyle(color: theme.colorScheme.error, fontSize: 13),
          suffixIcon: (maxLength != null && controller.text.isNotEmpty)
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12.0),
                  child: Text('${controller.text.length}/$maxLength',
                      style: theme.textTheme.bodySmall),
                )
              : null,
          counterText: "",
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: validator,
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null
              ? Icon(icon, color: theme.colorScheme.primary)
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.5), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide:
                BorderSide(color: theme.colorScheme.primary, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2.5),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          errorStyle: TextStyle(color: theme.colorScheme.error, fontSize: 13),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    IconData? icon,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(Get.context!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null
              ? Icon(icon, color: theme.colorScheme.primary)
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.5), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide:
                BorderSide(color: theme.colorScheme.primary, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2.5),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          errorStyle: TextStyle(color: theme.colorScheme.error, fontSize: 13),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        isExpanded: true,
        menuMaxHeight: 250,
      ),
    );
  }

  Widget _buildImagePickerField({
    required BuildContext context,
    required String label,
    required String docType,
    required ApplicationFormController controller,
    bool multiple = false,
    String? Function(List<XFile>)? validator,
  }) {
    final theme = Theme.of(context);
    return FormField<List<XFile>>(
      initialValue: controller.selectedDocuments[docType]?.toList() ?? [],
      // تأكد من التعامل مع null
      validator: (value) {
        if (validator != null) {
          return validator(value ?? []);
        }
        return null;
      },
      builder: (FormFieldState<List<XFile>> state) {
        return Obx(() {
          final images = controller.selectedDocuments[docType]!;
          // تحديث قيمة FormField كلما تغيرت قائمة الصور في المتحكم
          WidgetsBinding.instance.addPostFrameCallback((_) {
            state.didChange(images);
          });

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: state.hasError
                  ? BorderSide(color: theme.colorScheme.error, width: 2)
                  : BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                      width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: [
                      ...images.map((image) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(image.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: GestureDetector(
                                onTap: () =>
                                    controller.removeImage(docType, image),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: theme.colorScheme.error,
                                  child: const Icon(Icons.close,
                                      size: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      // زر إضافة الصورة، يظهر فقط إذا لم يتم الوصول للحد الأقصى أو كان اختيار متعدد
                      if (multiple || images.isEmpty)
                        InkWell(
                          onTap: () =>
                              controller.pickImage(docType, multiple: multiple),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.7),
                                  width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                    multiple
                                        ? Icons.add_photo_alternate
                                        : Icons.add_a_photo,
                                    size: 40,
                                    color: theme.colorScheme.primary),
                                const SizedBox(height: 6),
                                Text("أضف صورة",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Text(
                        state.errorText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
