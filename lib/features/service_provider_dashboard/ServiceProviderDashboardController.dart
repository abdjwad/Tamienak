// lib/features/service_provider_dashboard/controllers/service_provider_dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamienk/app/data/models/insurance_offer_model.dart';
import 'package:tamienk/app/data/models/service_request_model.dart';
import 'package:tamienk/app/routes/app_routes.dart';

// فئة جديدة لتمثيل العروض المصنفة
class CategorizedOffers {
  final String categoryName;
  final IconData categoryIcon;
  final List<InsuranceOffer> offers;

  CategorizedOffers({
    required this.categoryName,
    required this.categoryIcon,
    required this.offers,
  });
}

class ServiceProviderDashboardController extends GetxController with GetTickerProviderStateMixin {
  late TabController tabController;

  var isLoading = true.obs;
  var providerName = 'شركة الثقة للتأمين'.obs;
  var providerImageUrl = 'https://via.placeholder.com/150/D81B60/FFFFFF?text=Thiqa'.obs;

  // إحصائيات لوحة التحكم
  var newRequestsCount = 0.obs;
  var inProgressRequestsCount = 0.obs;
  var activeServicesCount = 0.obs;

  // قوائم البيانات
  final RxList<ServiceRequest> allRequests = <ServiceRequest>[].obs;
  final RxList<ServiceRequest> filteredRequests = <ServiceRequest>[].obs;
  final RxList<CategorizedOffers> categorizedOffers = <CategorizedOffers>[].obs;

  // متغيرات الفلاتر
  var selectedStatusFilter = Rxn<ServiceRequestStatus>();
  var offerStatusFilter = 'نشط'.obs;

  // <--- هذا هو السطر الذي تمت إعادته ---
  // بيانات الرسم البياني (مثال: طلبات الأسبوع الماضي)
  var weeklyChartData = <int>[5, 8, 3, 10, 7, 6, 9].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    fetchDashboardData();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));

    allRequests.assignAll(_generateFakeServiceRequests());
    categorizedOffers.assignAll(_generateFakeCategorizedOffers());

    newRequestsCount.value = allRequests.where((r) => r.status == ServiceRequestStatus.pending).length;
    inProgressRequestsCount.value = allRequests.where((r) => r.status == ServiceRequestStatus.inProgress).length;
    activeServicesCount.value = allRequests.where((r) => r.status == ServiceRequestStatus.approved).length;

    filterRequests(null);

    isLoading.value = false;
  }

  // --- دوال التحكم بالطلبات ---
  void goToRequestsTabWithFilter(ServiceRequestStatus? status) {
    selectedStatusFilter.value = status;
    filterRequests(status);
    tabController.animateTo(1);
  }

  void filterRequests(ServiceRequestStatus? status) {
    selectedStatusFilter.value = status;
    if (status == null) {
      filteredRequests.assignAll(allRequests);
    } else {
      filteredRequests.assignAll(allRequests.where((req) => req.status == status).toList());
    }
  }

  void updateRequestStatus(String requestId, ServiceRequestStatus newStatus) {
    var request = allRequests.firstWhereOrNull((r) => r.id == requestId);
    if (request != null) {
      int index = allRequests.indexOf(request);
      allRequests[index] = ServiceRequest(
        id: request.id, applicantName: request.applicantName,
        applicantImageUrl: request.applicantImageUrl, insuranceType: request.insuranceType,
        requestDate: request.requestDate, status: newStatus, notes: request.notes,
      );
      fetchDashboardData();
      Get.snackbar('تم التحديث', 'تم تغيير حالة الطلب بنجاح إلى "${newStatus.displayName}".');
    }
  }

  // --- دوال التحكم بالعروض ---
  void goToAddOffer() => Get.toNamed(Routes.OFFER_FORM);

  void goToEditOffer(InsuranceOffer offer) => Get.toNamed(Routes.OFFER_FORM, arguments: offer);

  void deleteOffer(String offerId) {
    Get.defaultDialog(
        title: "تأكيد الحذف",
        middleText: "هل أنت متأكد من حذف هذا العرض؟",
        textConfirm: "نعم, حذف", textCancel: "إلغاء",
        buttonColor: Colors.red, confirmTextColor: Colors.white,
        onConfirm: () {
          for (var category in categorizedOffers) {
            category.offers.removeWhere((offer) => offer.offerId == offerId);
          }
          categorizedOffers.refresh();
          Get.back();
          Get.snackbar('تم الحذف', 'تم حذف العرض بنجاح.');
        });
  }

  void toggleOfferStatus(String offerId) {
    for (var category in categorizedOffers) {
      var offer = category.offers.firstWhereOrNull((o) => o.offerId == offerId);
      if (offer != null) {
        offer.isActive = !offer.isActive;
        categorizedOffers.refresh();
        Get.snackbar(
          'تم تغيير الحالة',
          'تم تغيير حالة العرض إلى "${offer.isActive ? 'نشط' : 'غير نشط'}".',
        );
        break;
      }
    }
  }

  void setOfferStatusFilter(String status) {
    offerStatusFilter.value = status;
  }

  void logout() {
    Get.defaultDialog(
      title: "تسجيل الخروج", middleText: "هل أنت متأكد من تسجيل الخروج؟",
      textConfirm: "نعم", textCancel: "إلغاء",
      onConfirm: () {
        Get.back();
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }

  // --- دوال توليد البيانات الوهمية ---
  List<ServiceRequest> _generateFakeServiceRequests() {
    return [
      ServiceRequest(
        id: 'SR001', applicantName: 'لينا أحمد', insuranceType: 'تأمين صحي',
        requestDate: DateTime.now().subtract(const Duration(hours: 2)), status: ServiceRequestStatus.pending,
        applicantImageUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
      ),
      ServiceRequest(
        id: 'SR002', applicantName: 'خالد محمود', insuranceType: 'تأمين سيارة',
        requestDate: DateTime.now().subtract(const Duration(days: 1)), status: ServiceRequestStatus.inProgress,
        notes: "بانتظار مستندات إضافية",
        applicantImageUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704e',
      ),
    ];
  }

  List<CategorizedOffers> _generateFakeCategorizedOffers() {
    return [
      CategorizedOffers(
          categoryName: "تأمين السيارات",
          categoryIcon: Icons.directions_car,
          offers: [
            InsuranceOffer(
              offerId: 'car-premium-2024', companyName: 'شركة الثقة', companyLogoUrl: '...', annualPrice: 250000,
              coverageDetails: ['تغطية شاملة ضد الحوادث والسرقة', 'مساعدة على الطريق 24/7', 'سيارة بديلة أثناء الإصلاح'],
              isActive: true, extraBenefits: [],
            ),
            InsuranceOffer(
              offerId: 'car-basic-2024', companyName: 'شركة الثقة', companyLogoUrl: '...', annualPrice: 150000,
              coverageDetails: ['تغطية ضد الغير فقط', 'إصلاح ضمن شبكة معتمدة'],
              isActive: false, extraBenefits: [],
            ),
          ]
      ),
      CategorizedOffers(
          categoryName: "التأمين الصحي",
          categoryIcon: Icons.local_hospital,
          offers: [
            InsuranceOffer(
              offerId: 'health-gold-2024', companyName: 'شركة الثقة', companyLogoUrl: '...', annualPrice: 400000,
              coverageDetails: ['تغطية استشفاء 100% درجة أولى', 'عيادات خارجية وأدوية', 'تغطية أسنان ونظارات'],
              isActive: true, extraBenefits: [],
            ),
          ]
      ),
    ];
  }
}