// lib/features/offer_form/controllers/offer_form_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamienk/app/data/models/insurance_offer_model.dart';

import '../service_provider_dashboard/ServiceProviderDashboardController.dart';

class OfferFormController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;
  var isEditing = false.obs;
  InsuranceOffer? offerToEdit;

  // متحكمات الحقول
  late TextEditingController offerIdController;
  late TextEditingController annualPriceController;
  late TextEditingController termsUrlController;

  // اسم الشركة واللوجو سيتم جلبهما من ServiceProviderDashboardController
  // لذا لا نحتاج لمتحكمات خاصة بهما هنا إذا كانا ثابتين لمقدم الخدمة
  String companyName = '';
  String companyLogoUrl = '';

  var coverageDetails = <TextEditingController>[].obs;
  var requiredDocs = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();

    // جلب اسم الشركة واللوجو من ServiceProviderDashboardController
    // يجب التأكد من أن ServiceProviderDashboardController قد تم تهيئته
    try {
      final spController = Get.find<ServiceProviderDashboardController>();
      companyName = spController.providerName.value;
      companyLogoUrl = spController.providerImageUrl.value;
    } catch (e) {
      // معالجة الخطأ إذا لم يتم العثور على المتحكم (احتياطي)
      print("Error finding ServiceProviderDashboardController: $e");
      companyName = "اسم الشركة الافتراضي";
      companyLogoUrl = "رابط لوجو افتراضي";
    }

    offerIdController = TextEditingController();
    annualPriceController = TextEditingController();
    termsUrlController = TextEditingController();

    if (Get.arguments is InsuranceOffer) {
      isEditing.value = true;
      offerToEdit = Get.arguments as InsuranceOffer;

      offerIdController.text = offerToEdit!.offerId;
      annualPriceController.text = offerToEdit!.annualPrice.toStringAsFixed(0);
      termsUrlController.text = offerToEdit!.termsAndConditionsUrl;
      // companyName و companyLogoUrl سيتم استخدام القيم التي تم جلبها أعلاه

      coverageDetails.clear();
      for (var detail in offerToEdit!.coverageDetails) {
        coverageDetails.add(TextEditingController(text: detail));
      }
      requiredDocs.clear();
      for (var doc in offerToEdit!.requiredDocuments) {
        requiredDocs.add(TextEditingController(text: doc));
      }
    } else {
      // قيم افتراضية عند إنشاء عرض جديد
      addCoverageDetail(); // إضافة حقل تغطية واحد فارغ
      addRequiredDoc();    // إضافة حقل مستند واحد فارغ
    }
  }

  @override
  void onClose() {
    offerIdController.dispose();
    annualPriceController.dispose();
    termsUrlController.dispose();
    for (var controller in coverageDetails) { controller.dispose(); }
    for (var controller in requiredDocs) { controller.dispose(); }
    super.onClose();
  }

  void addCoverageDetail() => coverageDetails.add(TextEditingController());
  void removeCoverageDetail(int index) {
    if (index >= 0 && index < coverageDetails.length) {
      coverageDetails[index].dispose();
      coverageDetails.removeAt(index);
    }
  }

  void addRequiredDoc() => requiredDocs.add(TextEditingController());
  void removeRequiredDoc(int index) {
    if (index >= 0 && index < requiredDocs.length) {
      requiredDocs[index].dispose();
      requiredDocs.removeAt(index);
    }
  }

  void saveOffer() {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      // محاكاة عملية الحفظ (هنا يجب أن تتصل بالـ API)
      Future.delayed(const Duration(seconds: 1), () {
        final newOffer = InsuranceOffer(
          offerId: offerIdController.text.trim(),
          companyName: companyName, // اسم الشركة من المتحكم الرئيسي
          companyLogoUrl: companyLogoUrl, // لوجو الشركة من المتحكم الرئيسي
          annualPrice: double.tryParse(annualPriceController.text.trim()) ?? 0.0,
          coverageDetails: coverageDetails.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
          requiredDocuments: requiredDocs.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
          termsAndConditionsUrl: termsUrlController.text.trim(),
          isActive: offerToEdit?.isActive ?? true, // الحفاظ على الحالة أو جعلها نشطة للعروض الجديدة
          isBestValue: offerToEdit?.isBestValue ?? false, extraBenefits: [], // الحفاظ على القيمة أو جعلها false
        );

        // في تطبيق حقيقي:
        // إذا كان isEditing.value == true، قم بتحديث العرض في الـ API.
        // إذا كان isEditing.value == false، قم بإنشاء عرض جديد في الـ API.
        // بناءً على رد الـ API، قم بالخطوات التالية.

        print("Saving offer: ${newOffer.offerId}");
        // يمكنك طباعة باقي بيانات newOffer للتحقق

        isLoading.value = false;
        Get.back(result: true); // <--- إرجاع true للإشارة إلى نجاح العملية
        Get.snackbar(
          'نجاح العملية',
          isEditing.value ? 'تم تعديل العرض بنجاح!' : 'تم إنشاء العرض بنجاح!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
      });
    } else {
      Get.snackbar(
        'خطأ في الإدخال',
        'الرجاء التأكد من ملء جميع الحقول المطلوبة بشكل صحيح.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }
}