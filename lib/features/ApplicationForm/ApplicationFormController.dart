// lib/features/ApplicationForm/ApplicationFormController.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tamienk/app/data/models/insurance_offer_model.dart';
import 'package:tamienk/app/routes/app_routes.dart';

class ApplicationFormController extends GetxController {
  //----------------------------------------------------------------
  //--- قسم المتغيرات الرئيسية وحالة النموذج (State Variables)
  //----------------------------------------------------------------

  /// سيتم تهيئته لاحقًا في onReady، لن يتم لمسه في onInit.
  late final InsuranceOffer selectedOffer;

  final List<GlobalKey<FormState>> formKeys =
  List.generate(4, (_) => GlobalKey<FormState>());

  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool agreedToTerms = false.obs;

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

  // --- متغيرات لتخزين القيم المختارة (Dropdowns & Pickers) ---
  final Rxn<String> selectedGender = Rxn<String>();
  final Rxn<String> selectedMaritalStatus = Rxn<String>();
  final ImagePicker _picker = ImagePicker();
  final Map<String, RxList<XFile>> selectedDocuments = {
    'nationalIdFront': <XFile>[].obs,
    'nationalIdBack': <XFile>[].obs,
    'licenseFront': <XFile>[].obs,
    'licenseBack': <XFile>[].obs,
    'vehiclePhotos': <XFile>[].obs,
  }.obs;

  //----------------------------------------------------------------
  //--- دورة حياة المتحكم (Controller Lifecycle)
  //----------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    // >> مهم جداً: onInit() فارغ الآن من أي استدعاء قد يتفاعل مع الواجهة <<
    // هنا يتم فقط تهيئة المتغيرات الأساسية (التي يقوم بها GetX تلقائيًا).
  }

  /// <<< بداية التعديل الجذري هنا >>>
  /// تم نقل كل المنطق الذي يتفاعل مع الواجهة إلى onReady.
  @override
  void onReady() {
    super.onReady();
    // onReady() هي المكان الصحيح لتنفيذ الكود الذي قد يعرض Dialog أو Snackbar
    // لأنها تضمن أن الواجهة قد تم بناؤها بالفعل.
    _initializeOffer();
  }
  /// <<< نهاية التعديل الجذري هنا >>>

  @override
  void onClose() {
    // التخلص من جميع المتحكمات لتجنب تسرب الذاكرة
    pageController.dispose();
    fullNameController.dispose();
    nationalIdController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    dateOfBirthController.dispose();
    addressController.dispose();
    occupationController.dispose();
    policyStartDateController.dispose();
    vehicleMakeController.dispose();
    vehicleModelController.dispose();
    vehicleYearController.dispose();
    plateNumberController.dispose();
    chassisNumberController.dispose();
    vehicleValueController.dispose();
    super.onClose();
  }

  /// دالة خاصة لتهيئة العرض المستلم من الشاشة السابقة.
  void _initializeOffer() {
    // التحقق من وجود arguments
    if (Get.arguments != null && Get.arguments is InsuranceOffer) {
      selectedOffer = Get.arguments as InsuranceOffer;
    } else {
      // التعامل مع حالة الخطأ عند عدم استلام العرض
      selectedOffer = InsuranceOffer(
        offerId: 'default_error_id',
        companyName: 'شركة غير محددة',
        companyLogoUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?Text=Error',
        annualPrice: 0,
        coverageDetails: ['خطأ في تحميل تفاصيل العرض'],
        detailedCoverage: {},
        requiredDocuments: [],
        termsAndConditionsUrl: '',
        isBestValue: false,
        isActive: true, extraBenefits: [],
      );

      // هذا الاستدعاء آمن الآن لأنه يتم من داخل onReady
      _showErrorSnackbar(
        'خطأ فادح',
        'لم يتم استلام تفاصيل العرض بشكل صحيح. الرجاء المحاولة مرة أخرى.',
      );

      // تأجيل العودة للخلف قليلاً للسماح للمستخدم بقراءة رسالة الخطأ
      Future.delayed(const Duration(seconds: 3), () {
        // التحقق مما إذا كانت الصفحة لا تزال موجودة قبل محاولة العودة
        // ملاحظة: افترضت أن اسم المسار هو Routes.APPLICATION_FORM. قم بتغييره إذا كان مختلفاً.
        if (Get.currentRoute == Routes.APPLICATION_FORM) {
          Get.back();
        }
      });
    }
  }

  //----------------------------------------------------------------
  //--- دوال التحكم بالخطوات والتنقل (Navigation & Step Control)
  //----------------------------------------------------------------

  void nextStep() {
    // التحقق من صحة النموذج الخاص بالخطوة الحالية
    if (formKeys[currentStep.value].currentState!.validate()) {
      if (currentStep.value < 3) { // 3 هو (عدد الخطوات - 1)
        currentStep.value++;
        pageController.animateToPage(
          currentStep.value,
          duration: 300.ms,
          curve: Curves.easeInOut,
        );
      } else {
        submitApplication();
      }
    } else {
      _showErrorSnackbar('بيانات غير مكتملة', 'يرجى ملء جميع الحقول المطلوبة في هذه الخطوة.');
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(
        currentStep.value,
        duration: 300.ms,
        curve: Curves.easeInOut,
      );
    }
  }

  //----------------------------------------------------------------
  //--- دوال الخدمات المساعدة (Helper & Service Functions)
  //----------------------------------------------------------------

  Future<void> selectDate(
      BuildContext context,
      TextEditingController dateController, {
        DateTime? initialDate,
        DateTime? firstDate,
        DateTime? lastDate,
      }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1920),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('ar'),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: Get.theme.colorScheme.primary,
              onPrimary: Colors.white,
              surface: Get.theme.colorScheme.surface,
              onSurface: Get.theme.colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Get.theme.colorScheme.primary,
              ),
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

  void launchTermsUrl() async {
    final urlString = selectedOffer.termsAndConditionsUrl;
    if (urlString.isNotEmpty) {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        _showErrorSnackbar('خطأ', 'لا يمكن فتح الرابط: $urlString');
      }
    } else {
      Get.snackbar('معلومة', 'لا يوجد رابط شروط وأحكام متاح لهذا العرض.');
    }
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

  //----------------------------------------------------------------
  //--- دالة إرسال الطلب النهائية (Submission Function)
  //----------------------------------------------------------------

  void submitApplication() async {
    if (!formKeys[currentStep.value].currentState!.validate()) {
      _showErrorSnackbar('بيانات غير مكتملة', 'يرجى ملء جميع الحقول المطلوبة في هذه الخطوة.');
      return;
    }
    if (!agreedToTerms.value) {
      _showErrorSnackbar('تنبيه', 'يجب الموافقة على الشروط والأحكام للمتابعة.');
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

    final applicantData = {
      'offerId': selectedOffer.offerId,
      'companyName': selectedOffer.companyName,
      'fullName': fullNameController.text,
      'nationalId': nationalIdController.text,
      'phoneNumber': phoneNumberController.text,
      'email': emailController.text,
      'dateOfBirth': dateOfBirthController.text,
      'gender': selectedGender.value,
      'maritalStatus': selectedMaritalStatus.value,
      'occupation': occupationController.text,
      'address': addressController.text,
      'policyStartDate': policyStartDateController.text,
      'vehicleDetails': {
        'make': vehicleMakeController.text,
        'model': vehicleModelController.text,
        'year': vehicleYearController.text,
        'plateNumber': plateNumberController.text,
        'chassisNumber': chassisNumberController.text,
        'value': vehicleValueController.text,
      },
      'documents': selectedDocuments.map((key, value) => MapEntry(key, value.map((e) => e.path).toList())),
    };

    print("Application Data Submitted: $applicantData");
    isLoading.value = false;

    Get.defaultDialog(
      title: "تم استلام طلبك بنجاح!",
      titleStyle: Get.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Get.theme.colorScheme.primary),
      middleText: "شكراً لتقديم طلبك لشركة ${selectedOffer.companyName}. سيقوم فريقنا بمراجعة الطلب والتواصل معك قريباً.",
      middleTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Cairo'),
      textConfirm: "العودة للرئيسية",
      confirmTextColor: Colors.white,
      buttonColor: Get.theme.colorScheme.primary,
      radius: 15,
      onConfirm: () => Get.offAllNamed(Routes.HOME),
    );
  }

  /// دالة مساعدة موحدة لعرض رسائل الخطأ أو التنبيه.
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
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