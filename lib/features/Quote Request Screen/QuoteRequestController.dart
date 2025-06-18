// presentation/modules/quote_request/controllers/quote_request_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tamienk/app/routes/app_routes.dart';
import '../../../app/data/models/insurance_offer_model.dart';
import '../../../app/data/models/insurance_type_model.dart';
import '../../../app/routes/app_pages.dart';

class QuoteRequestController extends GetxController {
  late InsuranceType insuranceType;
  var isLoading = false.obs;

  final formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>()];
  final pageController = PageController();
  var currentPageIndex = 0.obs;
  int get totalSteps => 3;

  // ... (باقي المتحكمات كما هي)
  final TextEditingController commonNameController = TextEditingController();
  final TextEditingController commonPhoneController = TextEditingController();
  final TextEditingController commonEmailController = TextEditingController();
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController carYearController = TextEditingController();
  final TextEditingController healthDateOfBirthController = TextEditingController();
  final TextEditingController healthWeightController = TextEditingController();
  final TextEditingController healthHeightController = TextEditingController();
  final TextEditingController travelDestinationController = TextEditingController();
  final TextEditingController travelStartDateController = TextEditingController();
  final TextEditingController travelEndDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is InsuranceType) {
      insuranceType = Get.arguments as InsuranceType;
    } else {
      Get.snackbar('خطأ', 'لم يتم تحديد نوع التأمين.', snackPosition: SnackPosition.BOTTOM);
      Future.delayed(const Duration(milliseconds: 500), () => Get.back());
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    commonNameController.dispose();
    commonPhoneController.dispose();
    commonEmailController.dispose();
    carModelController.dispose();
    carYearController.dispose();
    healthDateOfBirthController.dispose();
    healthWeightController.dispose();
    healthHeightController.dispose();
    travelDestinationController.dispose();
    travelStartDateController.dispose();
    travelEndDateController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentPageIndex.value < formKeys.length) {
      // التحقق الآمن
      if (formKeys[currentPageIndex.value].currentState?.validate() ?? false) {
        if (currentPageIndex.value < totalSteps - 1) {
          currentPageIndex.value++;
          pageController.animateToPage(currentPageIndex.value, duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
        }
      }
    } else {
      // للانتقال من صفحة المراجعة
      if (currentPageIndex.value < totalSteps - 1) {
        currentPageIndex.value++;
        pageController.animateToPage(currentPageIndex.value, duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
      }
    }
  }

  void previousPage() {
    if (currentPageIndex.value > 0) {
      currentPageIndex.value--;
      pageController.animateToPage(currentPageIndex.value, duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < totalSteps) {
      currentPageIndex.value = page;
      pageController.animateToPage(page, duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    }
  }

  Future<void> selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.primary)),
        child: child!,
      ),
    );
    if (pickedDate != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  // === الكود المصحح والآمن هنا ===
  void submitQuoteRequest() async {
    // التحقق من صحة النماذج بطريقة آمنة
    final isStep1Valid = formKeys[0].currentState?.validate() ?? false;
    final isStep2Valid = formKeys[1].currentState?.validate() ?? false;

    if (!isStep1Valid || !isStep2Valid) {
      Get.snackbar('بيانات ناقصة', 'الرجاء العودة وإكمال جميع الخطوات بشكل صحيح.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 3)); // محاكاة الشبكة
      List<InsuranceOffer> fetchedOffers = _getFakeOffersForType(insuranceType.id);

      await _showSuccessAndNavigate(fetchedOffers);

    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
      isLoading.value = false;
    }
  }

  Future<void> _showSuccessAndNavigate(List<InsuranceOffer> offers) async {
    Get.dialog(
      barrierDismissible: false,
      PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/animations/success.json', width: 150, height: 150, repeat: false),
                  const SizedBox(height: 16),
                  Text("تم إرسال طلبك بنجاح!", style: Get.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("جارِ تحويلك لصفحة العروض...", style: Get.theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));

    Get.back(); // إغلاق الـ Dialog

    if (offers.isEmpty) {
      Get.snackbar("عذراً", "لا توجد عروض متاحة لهذا النوع حالياً.", snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.offNamed(Routes.OFFERS_COMPARISON, arguments: {'offers': offers, 'type': insuranceType});
    }
  }

  List<InsuranceOffer> _getFakeOffersForType(String typeId) {
    switch (typeId) {
      case 'car':
        return [
          InsuranceOffer(offerId: "syr-c-1", companyName: "السورية للتأمين", companyLogoUrl: "https://via.placeholder.com/150/1E88E5/FFFFFF?text=S", annualPrice: 150000, coverageDetails: ["تغطية ضد الغير", "إصلاح ضمن الوكالة", "مساعدة على الطريق"], detailedCoverage: {}, requiredDocuments: [], termsAndConditionsUrl: "", extraBenefits: []),
          InsuranceOffer(offerId: "thi-c-2", companyName: "الثقة للتأمين", companyLogoUrl: "https://via.placeholder.com/150/D81B60/FFFFFF?text=T", annualPrice: 135000, coverageDetails: ["تغطية ضد الغير فقط"], isBestValue: true, detailedCoverage: {}, requiredDocuments: [], termsAndConditionsUrl: "", extraBenefits: []),
        ];
      case 'health':
        return [
          InsuranceOffer(offerId: "gmd-h-1", companyName: "غلوب ميد", companyLogoUrl: "https://via.placeholder.com/150/43A047/FFFFFF?text=G", annualPrice: 250000, coverageDetails: ["تغطية داخل المشفى 80%", "عيادات خارجية", "أدوية"], detailedCoverage: {}, requiredDocuments: [], termsAndConditionsUrl: "", extraBenefits: []),
          InsuranceOffer(offerId: "uni-h-2", companyName: "الشركة المتحدة", companyLogoUrl: "https://via.placeholder.com/150/00ACC1/FFFFFF?text=U", annualPrice: 320000, coverageDetails: ["تغطية داخل المشفى 100%", "عيادات وأدوية", "تغطية أسنان ونظارات"], isBestValue: true, detailedCoverage: {}, requiredDocuments: [], termsAndConditionsUrl: "", extraBenefits: []),
        ];
      case 'travel':
        return [
          InsuranceOffer(offerId: "arp-t-1", companyName: "آروپ للتأمين", companyLogoUrl: "https://via.placeholder.com/150/F4511E/FFFFFF?text=A", annualPrice: 50000, coverageDetails: ["تغطية طبية طارئة حتى 30 ألف دولار", "فقدان أمتعة", "إلغاء رحلة"], isBestValue: true, detailedCoverage: {}, requiredDocuments: [], termsAndConditionsUrl: "", extraBenefits: []),
        ];
      default:
        return [];
    }
  }
}