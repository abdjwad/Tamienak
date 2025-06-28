// lib/features/application_form/screens/application_form_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tamienk/features/ApplicationForm/ApplicationFormController.dart';
import '../../app/theme/app_them.dart';

class ApplicationFormScreen extends GetView<ApplicationFormController> {
  const ApplicationFormScreen({Key? key}) : super(key: key);

  static final List<Map<String, dynamic>> _steps = [
    {'title': 'المعلومات الشخصية', 'icon': Icons.account_circle_outlined},
    {'title': 'تفاصيل المركبة', 'icon': Icons.directions_car_outlined},
    {'title': 'بيانات الوثيقة', 'icon': Icons.policy_outlined},
    {'title': 'الإنهاء والدفع', 'icon': Icons.credit_card_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color accentColor = AppTheme.accentColor;
    final Color backgroundColor = Color.lerp(primaryColor, Colors.black, 0.85)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                          content = _buildStep3PolicyDetails(context);
                          break;
                        default:
                          content = _buildStep4Dynamic(context);
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

  Widget _buildAnimatedBackground(Color color1, Color color2) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color1.withOpacity(0.3),
            color2.withOpacity(0.1),
            Colors.transparent
          ],
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
      decoration:
      BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .move(
        duration: GetNumUtils(20).seconds,
        begin: Offset.zero,
        end: const Offset(50, -50))
        .then(delay: GetNumUtils(5).seconds)
        .move(
        duration: GetNumUtils(25).seconds,
        begin: Offset.zero,
        end: const Offset(-50, 50));
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
                          color: isCompleted
                              ? AppTheme.accentColor
                              : Colors.white.withOpacity(0.2),
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

  Widget _buildStepIndicator(
      {required BuildContext context,
        required int index,
        required bool isActive,
        required bool isCompleted}) {
    final Color activeColor = AppTheme.accentColor;
    final Color inactiveColor = Colors.white.withOpacity(0.5);
    final Color completedColor = Theme.of(context).colorScheme.primary;
    final Color targetColor =
    isCompleted ? completedColor : (isActive ? activeColor : inactiveColor);
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
            // <<< تعديل: تم جعل الودجت الداخلي لا يتمدد للسماح بالـ Scroll >>>
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ),
      ),
    ).animate(key: ValueKey(index)).fadeIn(duration: 500.ms).slideY(begin: 0.1, curve: Curves.easeOut);
  }

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
          _buildTextField(
              context: context,
              label: "الاسم الكامل",
              controller: controller.fullNameController,
              focusNode: controller.fullNameFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(controller.nationalIdFocusNode),
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildTextField(
              context: context,
              label: "الرقم الوطني",
              controller: controller.nationalIdController,
              focusNode: controller.nationalIdFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(controller.phoneNumberFocusNode),
              keyboardType: TextInputType.number,
              validator: (v) => v!.length != 11 ? 'يجب أن يكون 11 رقمًا' : null),
          _buildTextField(
              context: context,
              label: "رقم الهاتف",
              controller: controller.phoneNumberController,
              focusNode: controller.phoneNumberFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(controller.emailFocusNode),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildTextField(
              context: context,
              label: "البريد الإلكتروني",
              controller: controller.emailController,
              focusNode: controller.emailFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(controller.occupationFocusNode),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty || !GetUtils.isEmail(v) ? 'بريد إلكتروني غير صحيح' : null),
          _buildDateField(
              context: context,
              label: "تاريخ الميلاد",
              controller: controller.dateOfBirthController,
              onTap: () {
                final minAgeDate = DateTime.now().subtract(const Duration(days: 365 * 18));
                controller.selectDate(context, controller.dateOfBirthController,
                    initialDate: minAgeDate,
                    lastDate: minAgeDate,
                    firstDate: DateTime(1920));
              },
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildTextField(
              context: context,
              label: "المهنة",
              controller: controller.occupationController,
              focusNode: controller.occupationFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildDropdownField(
              context: context,
              label: 'الجنس',
              value: controller.selectedGender.value,
              items: ['ذكر', 'أنثى'],
              onChanged: (val) => controller.selectedGender.value = val,
              validator: (v) => v == null ? 'مطلوب' : null),
          _buildDropdownField(
              context: context,
              label: 'الحالة الاجتماعية',
              value: controller.selectedMaritalStatus.value,
              items: ['أعزب', 'متزوج', 'مطلق', 'أرمل'],
              onChanged: (val) => controller.selectedMaritalStatus.value = val,
              validator: (v) => v == null ? 'مطلوب' : null),
          _buildTextField(
              context: context,
              label: "العنوان التفصيلي",
              controller: controller.addressController,
              focusNode: controller.addressFocusNode,
              textInputAction: TextInputAction.done,
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
        ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildStep2VehicleDetails(BuildContext context) {
    return Form(
      key: controller.formKeys[1],
      child: Column(
        children: [
          _buildSectionHeader(
              context: context,
              icon: _steps[1]['icon'],
              title: _steps[1]['title'],
              subtitle: "أخبرنا عن سيارتك بدقة."),
          _buildTextField(
              context: context,
              label: "ماركة السيارة",
              controller: controller.vehicleMakeController,
              focusNode: controller.vehicleMakeFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(controller.vehicleModelFocusNode),
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildTextField(
              context: context,
              label: "موديل السيارة",
              controller: controller.vehicleModelController,
              focusNode: controller.vehicleModelFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(controller.vehicleYearFocusNode),
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildTextField(
              context: context,
              label: "سنة الصنع",
              controller: controller.vehicleYearController,
              focusNode: controller.vehicleYearFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(controller.plateNumberFocusNode),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildTextField(
              context: context,
              label: "رقم اللوحة",
              controller: controller.plateNumberController,
              focusNode: controller.plateNumberFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(controller.chassisNumberFocusNode),
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
          _buildTextField(
              context: context,
              label: "رقم الهيكل (VIN)",
              controller: controller.chassisNumberController,
              focusNode: controller.chassisNumberFocusNode,
              textInputAction: TextInputAction.done,
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
        ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildStep3PolicyDetails(BuildContext context) {
    return Form(
      key: controller.formKeys[2],
      child: Column(
        children: [
          _buildSectionHeader(
              context: context,
              icon: _steps[2]['icon'],
              title: _steps[2]['title'],
              subtitle: "حدد تفاصيل التغطية المطلوبة."),
          _buildDropdownField(
              context: context,
              label: 'نوع التأمين المطلوب',
              value: controller.selectedInsuranceSubtype.value,
              items: ['ضد الغير', 'شامل'],
              onChanged: (val) {
                controller.selectedInsuranceSubtype.value = val;
                if (val == 'شامل') {
                  Future.delayed(
                      100.ms,
                          () => FocusScope.of(context).requestFocus(controller.vehicleValueFocusNode));
                }
              },
              validator: (v) => v == null ? 'مطلوب' : null),
          Obx(() {
            if (controller.selectedInsuranceSubtype.value == 'شامل') {
              return _buildTextField(
                  context: context,
                  label: "القيمة التقديرية للمركبة (ل.س)",
                  controller: controller.vehicleValueController,
                  focusNode: controller.vehicleValueFocusNode,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null)
                  .animate()
                  .fadeIn(duration: 400.ms);
            }
            return const SizedBox.shrink();
          }),
          _buildDateField(
              context: context,
              label: "تاريخ بدء التأمين",
              controller: controller.policyStartDateController,
              onTap: () => controller.selectDate(
                  context, controller.policyStartDateController,
                  initialDate: DateTime.now(), firstDate: DateTime.now()),
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
        ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildStep4Dynamic(BuildContext context) {
    return Obx(() => AnimatedSwitcher(
      duration: 500.ms,
      transitionBuilder: (child, animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.4),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
      child: controller.isPaymentPhase.value
          ? _buildPaymentInterface(context, key: const ValueKey('payment'))
          : _buildDocumentsContent(context, key: const ValueKey('documents')),
    ));
  }

  Widget _buildDocumentsContent(BuildContext context, {Key? key}) {
    return Form(
      key: controller.formKeys[3],
      child: Column(
        key: key,
        children: [
          _buildSectionHeader(
              context: context,
              icon: Icons.file_copy_outlined,
              title: "المستندات والموافقة",
              subtitle: "الخطوة الأخيرة قبل تأكيد طلبك."),
          _buildImagePickerField(context: context, label: "صورة الهوية (الأمام)", docType: 'nationalIdFront', controller: controller, validator: (img) => img == null || img.isEmpty ? 'مطلوب' : null),
          _buildImagePickerField(context: context, label: "صورة الهوية (الخلف)", docType: 'nationalIdBack', controller: controller, validator: (img) => img == null || img.isEmpty ? 'مطلوب' : null),
          _buildImagePickerField(context: context, label: "رخصة القيادة (الأمام)", docType: 'drivingLicenseFront', controller: controller, validator: (img) => img == null || img.isEmpty ? 'مطلوب' : null),
          _buildImagePickerField(context: context, label: "رخصة القيادة (الخلف)", docType: 'drivingLicenseBack', controller: controller, validator: (img) => img == null || img.isEmpty ? 'مطلوب' : null),
          _buildImagePickerField(context: context, label: "ملكية المركبة (الاستمارة)", docType: 'vehicleRegistration', controller: controller, validator: (img) => img == null || img.isEmpty ? 'مطلوب' : null),
          Obx(() {
            if (controller.selectedInsuranceSubtype.value == 'شامل') {
              return _buildImagePickerField(context: context, label: "صور للمركبة (4 زوايا)", docType: 'vehiclePhotos', controller: controller, multiple: true, validator: (img) => img == null || img.isEmpty ? 'مطلوب' : null).animate().fadeIn(duration: 400.ms);
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 24),
          _buildTermsAndConditions(context),
        ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildPaymentInterface(BuildContext context, {Key? key}) {
    final flipController = FlipCardController();
    ever(controller.isCvvFocused, (bool isFocused) {
      if (isFocused) {
        if (flipController.state?.isFront == true) {
          flipController.flipcard();
        }
      } else {
        if (flipController.state?.isFront == false) {
          flipController.flipcard();
        }
      }
    });
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context: context,
          icon: Icons.payment_rounded,
          title: "إتمام الدفع",
          subtitle: "تجربة دفع تفاعلية وآمنة.",
        ),
        Obx(() {
          // واجهة الدفع تعتمد على طريقة الدفع المختارة
          if (controller.selectedPaymentMethod.value == 'paypal') {
            return _buildPayPalForm();
          }
          // الافتراضي هو واجهة البطاقة الائتمانية
          return _buildCreditCardWidgets(flipController);
        }
        ),
        const SizedBox(height: 24),
        _buildPaymentMethodSelector(),
      ],
    );
  }

  Widget _buildCreditCardWidgets(FlipCardController flipController) {
    return Column(
      children: [
        FlipCard(
          controller: flipController,
          frontWidget: _buildCreditCardFront(),
          backWidget: _buildCreditCardBack(),
          rotateSide: RotateSide.right,
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
        const SizedBox(height: 24),
        _buildCreditCardForm(),
      ],
    );
  }

  Widget _buildPayPalForm() {
    return Column(
      children: [
        Container(
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.paypal, color: Colors.blue.shade200, size: 60),
                const SizedBox(height: 16),
                Text(
                  "أدخل بريدك الإلكتروني المرتبط بحساب PayPal.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildPaymentTextField(
          controller: controller.paypalEmailController,
          label: "البريد الإلكتروني لـ PayPal",
          hint: "you@example.com",
          keyboardType: TextInputType.emailAddress,
          validator: (v) => GetUtils.isEmail(v ?? '') ? null : "بريد إلكتروني غير صحيح",
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPaymentMethodOption(Icons.credit_card, 'visa', 'بطاقة'),
        const SizedBox(width: 20),
        _buildPaymentMethodOption(Icons.paypal, 'paypal', 'PayPal'),
      ],
    ));
  }

  Widget _buildPaymentMethodOption(IconData icon, String method, String label) {
    final isSelected = controller.selectedPaymentMethod.value == method;
    return GestureDetector(
      onTap: () => controller.selectedPaymentMethod.value = method,
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardFront() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Get.theme.colorScheme.primary, Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/chip.png', height: 40),
                Obx(() => _getCardTypeIcon(controller.cardNumberController.text)),
              ],
            ),
          ),
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  controller.cardNumberController.text.isEmpty ? "XXXX XXXX XXXX XXXX" : controller.cardNumberController.text,
                  style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 3, fontFamily: 'monospace'),
                )),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Card Holder", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                          Obx(() => Text(
                            controller.cardHolderNameController.text.isEmpty ? "FULL NAME" : controller.cardHolderNameController.text.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          )),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Expires", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                        Obx(() => Text(
                          controller.expiryDateController.text.isEmpty ? "MM/YY" : controller.expiryDateController.text,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        )),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardBack() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Get.theme.colorScheme.primary, Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 25),
          Container(height: 40, color: Colors.black),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: Container(height: 40, color: Colors.white.withOpacity(0.8))),
                SizedBox(width: 10),
                Obx(() => Text(
                  controller.cvvController.text.padRight(3, '*'),
                  style: TextStyle(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                      backgroundColor: Colors.white.withOpacity(0.8)),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCardTypeIcon(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return Image.asset('assets/images/visa.png', height: 40, width: 60, fit: BoxFit.contain);
    } else if (cardNumber.startsWith(RegExp(r'^(5[1-5])'))) {
      return Image.asset('assets/images/mastercard.png', height: 40, width: 60, fit: BoxFit.contain);
    }
    return SizedBox(width: 60, height: 40);
  }

  Widget _buildCreditCardForm() {
    return Form(
      key: controller.cardFormKey,
      child: Column(
        children: [
          _buildPaymentTextField(
              controller: controller.cardNumberController,
              label: "رقم البطاقة",
              hint: "XXXX XXXX XXXX XXXX",
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.length < 19) ? "رقم البطاقة غير صحيح" : null,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), CardNumberInputFormatter()]),
          _buildPaymentTextField(
              controller: controller.cardHolderNameController,
              label: "اسم حامل البطاقة",
              hint: "الاسم كما يظهر على البطاقة",
              validator: (v) => (v == null || v.isEmpty) ? "الحقل مطلوب" : null),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _buildPaymentTextField(
                      controller: controller.expiryDateController,
                      label: "تاريخ الانتهاء",
                      hint: "MM/YY",
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.length < 5) ? "غير صحيح" : null,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4), CardMonthInputFormatter()])),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildPaymentTextField(
                      focusNode: controller.cvvFocusNode,
                      controller: controller.cvvController,
                      label: "CVV",
                      hint: "XXX",
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.length < 3) ? "غير صحيح" : null,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)])),
            ],
          ),
        ].animate(interval: 80.ms).fadeIn(delay: 400.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildPaymentTextField({required TextEditingController controller, required String label, required String hint, String? Function(String?)? validator, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters, FocusNode? focusNode}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        focusNode: focusNode,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: label, hintText: hint,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: 'Cairo'),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Cairo'),
          filled: true, fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.accentColor, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
          errorStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required BuildContext context, required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines = 1,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.6), fontFamily: 'Cairo'),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.accentColor, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
          errorStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      {required BuildContext context,
        required String label,
        required String? value,
        required List<String> items,
        required void Function(String?)? onChanged,
        String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((String item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(fontFamily: 'Cairo'))))
            .toList(),
        onChanged: onChanged,
        validator: validator,
        dropdownColor: const Color(0xFF2D2F41),
        style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.6), fontFamily: 'Cairo'),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.accentColor, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
          errorStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  Widget _buildDateField(
      {required BuildContext context,
        required String label,
        required TextEditingController controller,
        required VoidCallback onTap,
        String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.6), fontFamily: 'Cairo'),
          suffixIcon:
          Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.6)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.accentColor, width: 2)),
          errorStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  Widget _buildImagePickerField(
      {required BuildContext context,
        required String label,
        required String docType,
        required ApplicationFormController controller,
        bool multiple = false,
        String? Function(List<XFile>?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<List<XFile>>(
        validator: (value) {
          final images = controller.selectedDocuments[docType] ?? [];
          if (validator != null) {
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
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(state.errorText!,
                        style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontFamily: 'Cairo')),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: [
                    ...images.map((image) => _buildImageThumbnail(context,
                        image, () => controller.removeImage(docType, image))),
                    if (multiple || images.isEmpty)
                      _buildAddImageButton(context, () async {
                        await controller.pickImage(docType, multiple: multiple);
                        state.didChange(controller.selectedDocuments[docType]);
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

  Widget _buildImageThumbnail(
      BuildContext context, XFile image, VoidCallback onRemove) {
    return SizedBox(
      width: 85,
      height: 85,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(image.path),
                width: 85, height: 85, fit: BoxFit.cover),
          ).animate().fadeIn(),
          Positioned(
            top: -8,
            right: -8,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(50),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black.withOpacity(0.8),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Colors.white),
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
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined,
                size: 32, color: Colors.white.withOpacity(0.8)),
            const SizedBox(height: 4),
            Text("إضافة",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Cairo',
                    fontSize: 12)),
          ],
        ),
      ),
    ).animate().scaleXY(
        delay: 100.ms, duration: 400.ms, begin: 0.8, curve: Curves.easeOutBack);
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    return InkWell(
      onTap: () =>
      controller.agreedToTerms.value = !controller.agreedToTerms.value,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Obx(() => Row(
          children: [
            AnimatedContainer(
              duration: 200.ms,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: controller.agreedToTerms.value
                    ? AppTheme.accentColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: controller.agreedToTerms.value
                        ? AppTheme.accentColor
                        : Colors.white.withOpacity(0.5),
                    width: 2),
              ),
              child: controller.agreedToTerms.value
                  ? const Icon(Icons.check, color: Colors.black, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text("أوافق على الشروط والأحكام.",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Cairo')),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Obx(() {
        final isLastStepBeforePayment = controller.currentStep.value == _steps.length - 1 && !controller.isPaymentPhase.value;
        final isPaymentStep = controller.isPaymentPhase.value;
        String nextButtonText = "التالي";
        IconData nextButtonIcon = Icons.arrow_forward_rounded;
        VoidCallback? onNextPressed = controller.isLoading.value ? null : controller.nextStep;
        if (isLastStepBeforePayment) {
          nextButtonText = "المتابعة للدفع";
          nextButtonIcon = Icons.shield_moon_outlined;
        } else if (isPaymentStep) {
          nextButtonText = "ادفع الآن";
          nextButtonIcon = Icons.payment_rounded;
          onNextPressed = controller.isLoading.value ? null : controller.processPayment;
        }
        return Row(
          children: [
            AnimatedOpacity(
              opacity: controller.currentStep.value > 0 || isPaymentStep ? 1.0 : 0.0,
              duration: 200.ms,
              child: IgnorePointer(
                ignoring: !(controller.currentStep.value > 0 || isPaymentStep),
                child: TextButton(
                  onPressed: controller.isLoading.value ? null : controller.previousStep,
                  child: Text("السابق", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, fontFamily: 'Cairo')),
                ).animate(key: const ValueKey('prev_btn')).fadeIn().slideX(begin: -0.2),
              ),
            ),
            const Spacer(),
            Flexible(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppTheme.accentColor.withOpacity(0.5),
                ),
                onPressed: onNextPressed,
                icon: controller.isLoading.value ? const SizedBox.shrink() : Icon(nextButtonIcon, size: 20),
                label: controller.isLoading.value
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
                    : Text(
                  nextButtonText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  overflow: TextOverflow.ellipsis,
                ),
              ).animate(key: ValueKey('next_btn_${controller.currentStep.value}_${isPaymentStep}')).fadeIn().slideX(begin: 0.2),
            ),
          ],
        );
      }),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    String inputData = newValue.text.replaceAll(RegExp(r'\s+\b|\b\s'), '');
    StringBuffer buffer = StringBuffer();
    for (var i = 0; i < inputData.length; i++) {
      buffer.write(inputData[i]);
      int index = i + 1;
      if (index % 4 == 0 && inputData.length != index) {
        buffer.write("  ");
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}