import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tamienk/app/theme/app_them.dart';
import 'package:tamienk/features/payment/payment_controller.dart';

class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color backgroundColor = Color.lerp(primaryColor, Colors.black, 0.85)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // إعادة استخدام نفس تصميم الخلفية المتحركة
          _buildAnimatedBackground(primaryColor, AppTheme.accentColor),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOrderSummary(),
                            const SizedBox(height: 24),
                            Text("اختر طريقة الدفع", style: _sectionTitleStyle),
                            const SizedBox(height: 16),
                            _buildPaymentMethodSelector(),
                            const SizedBox(height: 24),
                            // عرض نموذج البطاقة أو زر باي بال بناءً على الاختيار
                            Obx(() {
                              if (controller.selectedMethod.value ==
                                  PaymentMethod.creditCard) {
                                return _buildCreditCardForm(context)
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .slideX(begin: 0.2);
                              } else {
                                return _buildPayPalButton()
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .slideX(begin: -0.2);
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildPayButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- دوال بناء الواجهة الرئيسية والمساعدة ---

  TextStyle get _sectionTitleStyle => const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'Cairo');

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const Text("إتمام عملية الدفع",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo')),
          const SizedBox(width: 48), // لموازنة زر الرجوع
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildGlassCard({required Widget child}) {
    // إعادة استخدام نفس تصميم البطاقة الزجاجية
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("شركة التأمين",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'Cairo')),
              Text(controller.offer.companyName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo')),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("المبلغ الإجمالي",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'Cairo')),
              Text("${controller.amountToPay.toStringAsFixed(0)} ل.س",
                  style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Obx(
          () => Row(
        children: [
          Expanded(
            child: _buildPaymentOption(
              iconPath: 'assets/icons/credit-card.png', // تحتاج لإضافة هذه الصورة
              label: "بطاقة ائتمانية",
              isSelected:
              controller.selectedMethod.value == PaymentMethod.creditCard,
              onTap: () =>
                  controller.selectPaymentMethod(PaymentMethod.creditCard),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildPaymentOption(
              iconPath: 'assets/icons/paypal.png', // تحتاج لإضافة هذه الصورة
              label: "PayPal",
              isSelected:
              controller.selectedMethod.value == PaymentMethod.paypal,
              onTap: () => controller.selectPaymentMethod(PaymentMethod.paypal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      {required String iconPath,
        required String label,
        required bool isSelected,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.white24,
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Image.asset(iconPath, height: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm(BuildContext context) {
    return Form(
      key: controller.cardFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: controller.cardNumberController,
            label: "رقم البطاقة",
            hint: "XXXX XXXX XXXX XXXX",
            keyboardType: TextInputType.number,
            validator: (v) =>
            (v == null || v.length < 19) ? "رقم البطاقة غير صحيح" : null,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberInputFormatter(),
            ],
          ),
          _buildTextField(
            controller: controller.cardHolderNameController,
            label: "اسم حامل البطاقة",
            hint: "الاسم كما يظهر على البطاقة",
            validator: (v) =>
            (v == null || v.isEmpty) ? "الحقل مطلوب" : null,
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.expiryDateController,
                  label: "تاريخ الانتهاء",
                  hint: "MM/YY",
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                  (v == null || v.length < 5) ? "غير صحيح" : null,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    CardMonthInputFormatter(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: controller.cvvController,
                  label: "CVV",
                  hint: "XXX",
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                  (v == null || v.length < 3) ? "غير صحيح" : null,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                ),
              ),
            ],
          ),
        ].animate(interval: 80.ms).fadeIn().slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
        required String label,
        required String hint,
        String? Function(String?)? validator,
        TextInputType? keyboardType,
        List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.6), fontFamily: 'Cairo'),
          hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4), fontFamily: 'Cairo'),
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

  Widget _buildPayPalButton() {
    // في تطبيق حقيقي، هذا الزر سيفتح WebView أو SDK باي بال
    return Center(
      child: Column(
        children: [
          Text(
            "سيتم توجيهك إلى موقع PayPal لإكمال الدفع بأمان.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'Cairo',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // يمكنك وضع زر مخصص هنا إذا أردت
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Obx(
            () => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: controller.isLoading.value
                ? const SizedBox.shrink()
                : const Icon(Icons.security_rounded, size: 20),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.black,
            ),
            onPressed: controller.isLoading.value ? null : controller.processPayment,
            label: controller.isLoading.value
                ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: Colors.black))
                : Text(
              "ادفع الآن (${controller.amountToPay.toStringAsFixed(0)} ل.س)",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo'),
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1.0, duration: 400.ms, curve: Curves.easeOut);
  }

  // --- دوال بناء الخلفية (منسوخة من شاشتك) ---
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
}

// --- كلاسات مساعدة لتنسيق حقول الإدخال ---

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    String inputData = newValue.text;
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