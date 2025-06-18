// lib/features/offer_form/controllers/offer_form_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamienk/app/data/models/insurance_offer_model.dart'; // تأكد من المسار الصحيح

class OfferFormController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  // هل نحن في وضع التعديل أم الإنشاء؟
  var isEditing = false.obs;
  InsuranceOffer? offerToEdit;

  late TextEditingController offerNameController;
  late TextEditingController annualPriceController;
  // قائمة ديناميكية لتفاصيل التغطية
  var coverageDetails = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    offerNameController = TextEditingController();
    annualPriceController = TextEditingController();

    // تحقق مما إذا كان هناك عرض لتعديله
    if (Get.arguments is InsuranceOffer) {
      isEditing.value = true;
      offerToEdit = Get.arguments as InsuranceOffer;
      // ملء الحقول بالبيانات الحالية للعرض
      offerNameController.text = offerToEdit!.offerId; // استخدام offerId كاسم مؤقت
      annualPriceController.text = offerToEdit!.annualPrice.toString();
      for (var detail in offerToEdit!.coverageDetails) {
        coverageDetails.add(TextEditingController(text: detail));
      }
    } else {
      // إذا كان عرضاً جديداً، أضف حقلاً واحداً فارغاً للتغطية
      addCoverageDetail();
    }
  }

  @override
  void onClose() {
    offerNameController.dispose();
    annualPriceController.dispose();
    for (var controller in coverageDetails) {
      controller.dispose();
    }
    super.onClose();
  }

  void addCoverageDetail() {
    coverageDetails.add(TextEditingController());
  }

  void removeCoverageDetail(int index) {
    coverageDetails[index].dispose();
    coverageDetails.removeAt(index);
  }

  void saveOffer() {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      // محاكاة حفظ البيانات
      Future.delayed(const Duration(seconds: 1), () {
        // جمع البيانات من الحقول
        final offerData = {
          'name': offerNameController.text,
          'price': annualPriceController.text,
          'details': coverageDetails.map((c) => c.text).toList(),
        };
        print("Saving offer: $offerData");

        isLoading.value = false;
        Get.back(); // العودة إلى لوحة التحكم
        Get.snackbar(
          'نجاح',
          isEditing.value ? 'تم تعديل العرض بنجاح!' : 'تم إضافة العرض بنجاح!',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    }
  }
}