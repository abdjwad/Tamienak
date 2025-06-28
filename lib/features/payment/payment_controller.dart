import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamienk/app/data/models/insurance_offer_model.dart';
import 'package:tamienk/app/routes/app_routes.dart';

// enum لتسهيل التعامل مع طرق الدفع
enum PaymentMethod { creditCard, paypal }

class PaymentController extends GetxController {
  // --- متغيرات الحالة ---
  final Rx<PaymentMethod> selectedMethod = PaymentMethod.creditCard.obs;
  final RxBool isLoading = false.obs;

  // --- بيانات الطلب المستلمة ---
  late final InsuranceOffer offer;
  late final Map<String, dynamic> applicantData;
  late final double amountToPay;

  // --- متحكمات ومفاتيح نموذج البطاقة ---
  final GlobalKey<FormState> cardFormKey = GlobalKey<FormState>();
  final cardNumberController = TextEditingController();
  final cardHolderNameController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // استلام البيانات من الشاشة السابقة
    final arguments = Get.arguments as Map<String, dynamic>;
    offer = arguments['offer'];
    applicantData = arguments['applicantData'];
    // السعر السنوي هو المبلغ المطلوب دفعه
    amountToPay = offer.annualPrice;
  }

  @override
  void onClose() {
    // التخلص من المتحكمات لمنع تسرب الذاكرة
    cardNumberController.dispose();
    cardHolderNameController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    super.onClose();
  }

  // --- دوال التحكم بالواجهة ---

  void selectPaymentMethod(PaymentMethod method) {
    selectedMethod.value = method;
  }

  // --- دالة معالجة الدفع الرئيسية ---
  Future<void> processPayment() async {
    // إذا كانت طريقة الدفع هي البطاقة، تحقق من صحة الحقول أولاً
    if (selectedMethod.value == PaymentMethod.creditCard) {
      if (!cardFormKey.currentState!.validate()) {
        Get.snackbar(
          'بيانات غير صحيحة',
          'يرجى التحقق من بيانات البطاقة الائتمانية.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
        return;
      }
    }

    isLoading.value = true;

    // محاكاة عملية الدفع (في تطبيق حقيقي، هنا يتم استدعاء API الدفع)
    await Future.delayed(const Duration(seconds: 3));

    // طباعة بيانات الدفع النهائية للمحاكاة
    print('--- PAYMENT PROCESSED ---');
    print('Amount: $amountToPay L.S');
    print('Method: ${selectedMethod.value.toString()}');
    print('Applicant Data: $applicantData');
    print('-------------------------');

    isLoading.value = false;

    // إظهار رسالة النجاح
    Get.defaultDialog(
      title: "عملية الدفع تمت بنجاح!",
      middleText:
      "شكراً لك. تم تأكيد بوليصة التأمين الخاصة بك من شركة ${offer.companyName}.",
      textConfirm: "العودة للرئيسية",
      confirmTextColor: Colors.white,
      buttonColor: Get.theme.colorScheme.primary,
      radius: 15,
      barrierDismissible: false, // لا يمكن إغلاقها بالضغط خارجها
      onConfirm: () => Get.offAllNamed(Routes.HOME),
    );
  }
}