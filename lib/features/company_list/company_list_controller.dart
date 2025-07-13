// مسار الملف: lib/features/company_list/controllers/company_list_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/models/company_model.dart';
import '../../../app/data/models/insurance_product_model.dart';
import '../../../app/data/models/insurance_type_model.dart';
import '../../../app/data/models/pricing_plan_model.dart';

class CompanyListController extends GetxController {
  // متغيرات حالة
  var isLoading = true.obs;

  // بيانات
  // هذا المتغير قد يكون null إذا تم عرض كل الشركات
  InsuranceType? selectedInsuranceType;

  // عنوان شريط العلوي أصبح متغيراً ليتكيف مع الحالة
  var appBarTitle = "شركات التأمين".obs;

  final RxList<Company> allCompanies = <Company>[].obs;
  final RxList<Company> filteredCompanies = <Company>[].obs;

  @override
  void onInit() {
    super.onInit();

    // منطق ذكي لتحديد ما إذا كان يجب الفلترة أم عرض الكل
    if (Get.arguments is InsuranceType) {
      selectedInsuranceType = Get.arguments as InsuranceType;
      appBarTitle.value = "شركات ${selectedInsuranceType!.name}";
    } else {
      // إذا لم يتم تمرير نوع تأمين، نعرض كل الشركات
      selectedInsuranceType = null;
      appBarTitle.value = "شركاؤنا من الشركات";
    }

    _fetchAllCompanies();
  }

  void _fetchAllCompanies() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    // [UPGRADE] تم إضافة أيقونات لخطط الأسعار
    allCompanies.assignAll([
      Company(
        id: '1',
        name: 'الشركة السورية للتأمين',
        logoUrl: 'https://via.placeholder.com/150/5603AD/FFFFFF?text=SCI',
        rating: 4.5,
        description: 'رائدة في تأمين السيارات والممتلكات.',
        supportedInsuranceTypes: ['car', 'property'],
        products: [
          InsuranceProduct(
            id: 'p1',
            name: 'تأمين سيارات - طرف ثالث',
            insuranceTypeId: 'car',
            description: 'التغطية الأساسية ضد أضرار الغير.',
            plans: [
              PricingPlan(
                  id: 'pp1',
                  name: 'الباقة البرونزية',
                  price: 50000,
                  durationInDays: 365,
                  features: ['تغطية تصل إلى 10 مليون'],
                  icon: Icons.shield_outlined),
              PricingPlan(
                  id: 'pp2',
                  name: 'الباقة الفضية',
                  price: 75000,
                  durationInDays: 365,
                  features: ['تغطية تصل إلى 15 مليون', 'خصم 10%'],
                  icon: Icons.shield),
            ],
          ),
          InsuranceProduct(
            id: 'p2',
            name: 'تأمين سيارات - شامل',
            insuranceTypeId: 'car',
            description: 'تغطية كاملة لسيارتك وضد أضرار الغير.',
            plans: [
              PricingPlan(
                  id: 'pp3',
                  name: 'الباقة الذهبية',
                  price: 250000,
                  durationInDays: 365,
                  features: ['تغطية شاملة', 'مساعدة على الطريق', 'سيارة بديلة'],
                  icon: Icons.workspace_premium),
            ],
          ),
        ],
      ),
      Company(
        id: '2',
        name: 'الثقة للتأمين',
        logoUrl: 'https://via.placeholder.com/150/8367C7/FFFFFF?text=ATI',
        rating: 4.8,
        description: 'خبرة طويلة في التأمين الصحي والحياة.',
        supportedInsuranceTypes: ['health', 'life'],
        products: [
          InsuranceProduct(
            id: 'p3',
            name: 'تأمين صحي - أفراد',
            insuranceTypeId: 'health',
            description: 'تغطية صحية مميزة للأفراد.',
            plans: [
              PricingPlan(
                  id: 'pp4',
                  name: 'الباقة الفضية',
                  price: 180000,
                  durationInDays: 365,
                  features: ['تغطية مستشفيات', 'عيادات خارجية'],
                  icon: Icons.local_hospital_outlined),
              PricingPlan(
                  id: 'pp5',
                  name: 'الباقة الذهبية',
                  price: 350000,
                  durationInDays: 365,
                  features: ['تغطية مستشفيات وعيادات', 'أسنان ونظر'],
                  icon: Icons.local_hospital),
            ],
          ),
        ],
      ),
      // ... بقية الشركات
    ]);

    _filterCompanies();
    isLoading.value = false;
  }

  void _filterCompanies() {
    // منطق الفلترة المحدث
    if (selectedInsuranceType != null) {
      var results = allCompanies.where((company) {
        // نعرض الشركة إذا كانت تدعم هذا النوع من التأمين
        return company.supportedInsuranceTypes
            .contains(selectedInsuranceType!.id);
      }).toList();
      filteredCompanies.assignAll(results);
    } else {
      // إذا لم يكن هناك نوع محدد، نعرض جميع الشركات
      filteredCompanies.assignAll(allCompanies);
    }
  }
}
