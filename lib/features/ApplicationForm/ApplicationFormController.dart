// presentation/modules/application_form/controllers/application_form_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart'; // <--- استيراد مكتبة الصور

import '../../../app/data/models/insurance_offer_model.dart';
import '../../../app/routes/app_routes.dart'; // تأكد من استيراد المسارات

class ApplicationFormController extends GetxController {
  late final InsuranceOffer selectedOffer;

  final formKey = GlobalKey<FormState>();

  // متحكمات حقول الإدخال
  final fullNameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final addressController = TextEditingController();
  final occupationController = TextEditingController(); // جديد
  final policyStartDateController = TextEditingController(); // جديد

  // متحكمات تفاصيل السيارة (جديد)
  final vehicleMakeController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final vehicleYearController = TextEditingController();
  final plateNumberController = TextEditingController();
  final chassisNumberController = TextEditingController();
  final vehicleValueController = TextEditingController();


  // متغيرات لتخزين القيم المختارة
  var selectedGender = Rxn<String>();
  var selectedMaritalStatus = Rxn<String>(); // جديد
  var agreedToTerms = false.obs;
  var isLoading = false.obs;

  // متغيرات لتخزين الصور المرفوعة (جديد)
  final ImagePicker _picker = ImagePicker();
  final Map<String, RxList<XFile>> selectedDocuments = {
    'nationalIdFront': <XFile>[].obs,
    'nationalIdBack': <XFile>[].obs,
    'licenseFront': <XFile>[].obs,
    'licenseBack': <XFile>[].obs,
    'vehiclePhotos': <XFile>[].obs,
  }.obs; // جعل الخريطة نفسها قابلة للملاحظة لتحديث الـ UI

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is InsuranceOffer) {
      selectedOffer = Get.arguments as InsuranceOffer;
    } else {
      // التعامل مع حالة عدم تمرير العرض (مهم لتجنب الأخطاء)
      // تأكد أن 'offerId' هو اسم الخاصية في نموذجك، إذا كان 'id' فاستخدمه
      selectedOffer = InsuranceOffer(
        offerId: 'default', // استخدم 'id' إذا كان هذا هو الاسم الصحيح في InsuranceOffer Model
        companyName: 'غير معروف',
        companyLogoUrl: 'https://via.placeholder.com/150',
        annualPrice: 0.0,
        coverageDetails: ['لا توجد تفاصيل'],
        detailedCoverage: {'لا توجد تفاصيل': 'لا توجد'},
        requiredDocuments: ['لا توجد وثائق'],
        termsAndConditionsUrl: 'https://www.google.com',
        isBestValue: false, extraBenefits: [],
      );
      Get.snackbar('خطأ', 'لم يتم استلام تفاصيل العرض. يرجى المحاولة مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.7), colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    // التخلص من المتحكمات عند إغلاق الشاشة لتجنب تسرب الذاكرة
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

  // دالة عامة لاختيار تاريخ (للتاريخين: الميلاد وبدء البوليصة)
  Future<void> selectDate(BuildContext context, TextEditingController dateController, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      helpText: 'اختر التاريخ',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  // دالة لفتح رابط الشروط والأحكام
  void launchTermsUrl() async {
    final Uri url = Uri.parse(selectedOffer.termsAndConditionsUrl);
    if (!await launchUrl(url)) {
      Get.snackbar('خطأ', 'لا يمكن فتح الرابط',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.7), colorText: Colors.white);
    }
  }

  // دالة اختيار الصور (جديد)
  Future<void> pickImage(String docType, {bool multiple = false}) async {
    List<XFile>? pickedFiles;
    if (multiple) {
      pickedFiles = await _picker.pickMultiImage(imageQuality: 70); // جودة أقل لصور أسرع
    } else {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile != null) {
        pickedFiles = [pickedFile];
      }
    }

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      if (!multiple) {
        // إذا كان الاختيار ليس متعددًا، استبدل الصورة الموجودة
        selectedDocuments[docType]?.clear();
      }
      selectedDocuments[docType]?.addAll(pickedFiles);
    }
  }

  // دالة إزالة الصورة (جديد)
  void removeImage(String docType, XFile imageToRemove) {
    selectedDocuments[docType]?.remove(imageToRemove);
  }

  // دالة لإرسال الطلب
  void submitApplication() async {
    if (formKey.currentState!.validate()) {
      if (!agreedToTerms.value) {
        Get.snackbar('خطأ', 'يجب الموافقة على الشروط والأحكام للمتابعة',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.7), colorText: Colors.white);
        return;
      }

      isLoading.value = true;
      // محاكاة إرسال البيانات إلى خادم
      await Future.delayed(const Duration(seconds: 2));
      isLoading.value = false;

      final applicantData = {
        'offerId': selectedOffer.offerId,
        'companyName': selectedOffer.companyName,
        'fullName': fullNameController.text,
        'nationalId': nationalIdController.text,
        'phoneNumber': phoneNumberController.text,
        'email': emailController.text,
        'dateOfBirth': dateOfBirthController.text,
        'gender': selectedGender.value,
        'maritalStatus': selectedMaritalStatus.value, // جديد
        'occupation': occupationController.text, // جديد
        'address': addressController.text,
        'policyStartDate': policyStartDateController.text, // جديد
        'vehicleDetails': { // جديد
          'make': vehicleMakeController.text,
          'model': vehicleModelController.text,
          'year': vehicleYearController.text,
          'plateNumber': plateNumberController.text,
          'chassisNumber': chassisNumberController.text,
          'value': vehicleValueController.text,
        },
        'documents': selectedDocuments.map((key, value) => MapEntry(key, value.map((e) => e.path).toList())), // إرسال مسارات الصور
      };

      print("تم إرسال بيانات الطلب: $applicantData");

      Get.defaultDialog(
        title: "تم استلام طلبك بنجاح!",
        middleText: "شكراً لتقديم طلبك لشركة ${selectedOffer.companyName}. سيقوم فريقنا بالتواصل معك قريباً.",
        textConfirm: "تم",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // إغلاق الحوار
          Get.offAllNamed(Routes.HOME); // العودة إلى الشاشة الرئيسية مباشرةً
        },
      );
    }
  }
}