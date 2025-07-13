// مسار الملف: lib/features/company_details/controllers/company_details_controller.dart

import 'package:flutter/material.dart'; // استيراد ضروري للأيقونات
import 'package:get/get.dart';
import '../../../app/data/models/company_model.dart';
import '../../../app/data/models/insurance_product_model.dart';
import '../../../app/data/models/insurance_type_model.dart';
import '../../../app/data/models/pricing_plan_model.dart';
import '../../../app/data/models/quote_request_args_model.dart'; // <-- استيراد النموذج الجديد
import '../../../app/routes/app_routes.dart'; // <-- استيراد المسارات

class CompanyDetailsController extends GetxController {
  late final Company company;
  final RxList<InsuranceType> availableProductTypes = <InsuranceType>[].obs;
  final Rx<InsuranceType?> selectedType = Rx<InsuranceType?>(null);
  final RxList<InsuranceProduct> filteredProducts = <InsuranceProduct>[].obs;
  final RxMap<String, bool> expandedProducts = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    company = Get.arguments as Company;
    _getAvailableProductTypes();
    if (availableProductTypes.isNotEmpty) {
      changeSelectedType(availableProductTypes.first);
    }
  }

  void _getAvailableProductTypes() {
    final allTypes = [
      InsuranceType(id: "car", name: "السيارات", icon: Icons.directions_car_filled, description: ''),
      InsuranceType(id: "health", name: "الصحي", icon: Icons.local_hospital, description: ''),
      InsuranceType(id: "property", name: "الممتلكات", icon: Icons.home_work, description: ''),
    ];
    final uniqueTypeIds = company.products.map((p) => p.insuranceTypeId).toSet();
    availableProductTypes.assignAll(allTypes.where((type) => uniqueTypeIds.contains(type.id)));
  }

  void changeSelectedType(InsuranceType type) {
    selectedType.value = type;
    expandedProducts.clear();
    _filterProducts();
  }

  void _filterProducts() {
    if (selectedType.value == null) {
      filteredProducts.assignAll(company.products);
    } else {
      final results = company.products
          .where((product) => product.insuranceTypeId == selectedType.value!.id)
          .toList();
      filteredProducts.assignAll(results);
    }
  }

  void toggleProductExpansion(String productId) {
    expandedProducts[productId] = !(expandedProducts[productId] ?? false);
  }

  // [UPGRADE] تم تحديث هذه الوظيفة بالكامل
  void selectPlan(InsuranceProduct product, PricingPlan plan) {
    // التأكد من أن النوع المختار ليس null
    if (selectedType.value == null) return;

    // 1. تجميع كل البيانات في كائن واحد
    final args = QuoteRequestArgs(
      insuranceType: selectedType.value!,
      company: company,
      product: product,
      plan: plan,
    );

    // 2. الانتقال إلى صفحة طلب عرض السعر مع تمرير البيانات
    Get.toNamed(Routes.QUOTE_REQUEST, arguments: args);
  }
}