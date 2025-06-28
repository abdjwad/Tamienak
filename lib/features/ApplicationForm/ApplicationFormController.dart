// lib/features/ApplicationForm/ApplicationFormController.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tamienk/app/data/models/insurance_offer_model.dart';
import 'package:tamienk/app/routes/app_routes.dart';

class ApplicationFormController extends GetxController {
  //----------------------------------------------------------------
  //--- قسم المتغيرات الرئيسية وحالة النموذج (State Variables)
  //----------------------------------------------------------------

  late final InsuranceOffer selectedOffer;

  final List<GlobalKey<FormState>> formKeys =
  List.generate(4, (_) => GlobalKey<FormState>());

  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPaymentPhase = false.obs;
  final Rxn<String> selectedInsuranceSubtype = Rxn<String>();

  // --- متحكمات حقول الإدخال (TextEditingControllers) ---
  final fullNameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final occupationController = TextEditingController();
  final vehicleMakeController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final vehicleYearController = TextEditingController();
  final plateNumberController = TextEditingController();
  final chassisNumberController = TextEditingController();
  final vehicleValueController = TextEditingController();
  final addressController = TextEditingController();
  final policyStartDateController = TextEditingController();

  // --- متغيرات لتخزين القيم المختارة ---
  final Rxn<String> selectedGender = Rxn<String>();
  final Rxn<String> selectedMaritalStatus = Rxn<String>();
  final ImagePicker _picker = ImagePicker();

  final RxMap<String, List<XFile>> selectedDocuments = {
    'nationalIdFront': <XFile>[].obs, 'nationalIdBack': <XFile>[].obs,
    'drivingLicenseFront': <XFile>[].obs, 'drivingLicenseBack': <XFile>[].obs,
    'vehicleRegistration': <XFile>[].obs, 'vehiclePhotos': <XFile>[].obs,
  }.obs;
  final RxBool agreedToTerms = false.obs;

  // --- متغيرات ومتحكمات خاصة بالدفع ---
  final GlobalKey<FormState> cardFormKey = GlobalKey<FormState>();
  // تم تغيير النوع إلى String ليتوافق مع الواجهة
  final RxString selectedPaymentMethod = 'visa'.obs;
  final cardNumberController = TextEditingController();
  final cardHolderNameController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();
  final paypalEmailController = TextEditingController();

  // --- FocusNodes ---
  final fullNameFocusNode = FocusNode();
  final nationalIdFocusNode = FocusNode();
  final phoneNumberFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final occupationFocusNode = FocusNode();
  final addressFocusNode = FocusNode();
  final vehicleMakeFocusNode = FocusNode();
  final vehicleModelFocusNode = FocusNode();
  final vehicleYearFocusNode = FocusNode();
  final plateNumberFocusNode = FocusNode();
  final chassisNumberFocusNode = FocusNode();
  final vehicleValueFocusNode = FocusNode();
  final cvvFocusNode = FocusNode();
  final RxBool isCvvFocused = false.obs;

  @override
  void onInit() {
    super.onInit();
    cvvFocusNode.addListener(() {
      isCvvFocused.value = cvvFocusNode.hasFocus;
    });
  }

  @override
  void onReady() {
    super.onReady();
    _initializeOffer();
  }

  @override
  void onClose() {
    cvvFocusNode.removeListener(() {});
    cvvFocusNode.dispose();
    fullNameFocusNode.dispose();
    nationalIdFocusNode.dispose();
    phoneNumberFocusNode.dispose();
    emailFocusNode.dispose();
    occupationFocusNode.dispose();
    addressFocusNode.dispose();
    vehicleMakeFocusNode.dispose();
    vehicleModelFocusNode.dispose();
    vehicleYearFocusNode.dispose();
    plateNumberFocusNode.dispose();
    chassisNumberFocusNode.dispose();
    vehicleValueFocusNode.dispose();
    pageController.dispose();
    fullNameController.dispose();
    nationalIdController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    dateOfBirthController.dispose();
    occupationController.dispose();
    vehicleMakeController.dispose();
    vehicleModelController.dispose();
    vehicleYearController.dispose();
    plateNumberController.dispose();
    chassisNumberController.dispose();
    vehicleValueController.dispose();
    addressController.dispose();
    policyStartDateController.dispose();
    cardNumberController.dispose();
    cardHolderNameController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    paypalEmailController.dispose();
    super.onClose();
  }

  void _initializeOffer() {
    if (Get.arguments != null && Get.arguments is InsuranceOffer) {
      selectedOffer = Get.arguments as InsuranceOffer;
    } else {
      selectedOffer = InsuranceOffer(
        offerId: 'offer_123_manual',
        companyName: 'الشركة السورية للتأمين',
        companyLogoUrl: '',
        annualPrice: 250000,
        coverageDetails: [], detailedCoverage: {}, requiredDocuments: [],
        termsAndConditionsUrl: 'https://flutter.dev',
        isBestValue: true, isActive: true, extraBenefits: [],
      );
    }
  }

  void nextStep() {
    if (!formKeys[currentStep.value].currentState!.validate()) {
      _showErrorSnackbar('بيانات غير مكتملة', 'يرجى ملء جميع الحقول المطلوبة.');
      return;
    }
    if (currentStep.value == 3) {
      if (!agreedToTerms.value) {
        _showErrorSnackbar('تنبيه', 'يجب الموافقة على الشروط والأحكام.');
        return;
      }
      isPaymentPhase.value = true;
    } else {
      currentStep.value++;
      pageController.animateToPage(
        currentStep.value,
        duration: 300.ms, curve: Curves.easeInOut,
      );
    }
  }

  void previousStep() {
    if (currentStep.value == 3 && isPaymentPhase.value) {
      isPaymentPhase.value = false;
      return;
    }
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(
        currentStep.value,
        duration: 300.ms, curve: Curves.easeInOut,
      );
    }
  }

  Future<void> processPayment() async {
    // التحقق من صحة النموذج بناءً على طريقة الدفع
    bool isValid = true;
    if (selectedPaymentMethod.value != 'paypal') {
      isValid = cardFormKey.currentState?.validate() ?? false;
    } else {
      // يمكنك إضافة تحقق من بريد باي بال هنا
      if (paypalEmailController.text.isEmpty || !GetUtils.isEmail(paypalEmailController.text)) {
        _showErrorSnackbar('بيانات غير صحيحة', 'يرجى إدخال بريد PayPal صحيح.');
        isValid = false;
      }
    }

    if (!isValid) return;

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 3));
    isLoading.value = false;
    Get.defaultDialog(
      title: "عملية الدفع تمت بنجاح!",
      middleText: "شكراً لك. تم تأكيد بوليصة التأمين الخاصة بك.",
      textConfirm: "العودة للرئيسية",
      confirmTextColor: Colors.white,
      buttonColor: Get.theme.colorScheme.primary,
      radius: 15,
      barrierDismissible: false,
      onConfirm: () => Get.offAllNamed(Routes.HOME),
    );
  }

  Future<void> pickImage(String docType, {bool multiple = false}) async {
    try {
      if (multiple) {
        final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 70);
        if (pickedFiles.isNotEmpty) {
          selectedDocuments[docType]?.addAll(pickedFiles);
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
        if (pickedFile != null) {
          selectedDocuments[docType]?.assignAll([pickedFile]);
        }
      }
    } catch (e) {
      _showErrorSnackbar('خطأ في اختيار الصورة', 'حدث خطأ: ${e.toString()}');
    }
  }

  void removeImage(String docType, XFile imageToRemove) {
    selectedDocuments[docType]?.remove(imageToRemove);
  }

  Future<void> selectDate(BuildContext context, TextEditingController dateController, {DateTime? initialDate, DateTime? firstDate, DateTime? lastDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1920),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Get.theme.colorScheme.primary,
              onPrimary: Colors.white,
              surface: Get.theme.colorScheme.surface,
              onSurface: Get.theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      dateController.text = DateFormat('dd/MM/yyyy', 'ar').format(pickedDate);
    }
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: title == 'تنبيه' ? Colors.orange.shade700 : Colors.red.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(title == 'تنبيه' ? Icons.warning_amber_rounded : Icons.error_outline_rounded, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
}