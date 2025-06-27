// lib/features/service_provider_dashboard/controllers/service_provider_dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamienk/app/data/models/insurance_offer_model.dart';
import 'package:tamienk/app/data/models/service_request_model.dart';
import 'package:tamienk/app/routes/app_routes.dart';

class CategorizedOffers {
  final String categoryName;
  final IconData categoryIcon;
  final List<InsuranceOffer> offers;
  RxBool isExpanded;

  CategorizedOffers({
    required this.categoryName,
    required this.categoryIcon,
    required this.offers,
    bool initiallyExpanded = true,
  }) : isExpanded = initiallyExpanded.obs;
}

class ServiceProviderDashboardController extends GetxController with GetTickerProviderStateMixin {
  late TabController tabController;

  var isLoading = true.obs;
  var providerName = 'شركة الأمانة للتأمين'.obs;
  var providerImageUrl = 'https://i.pravatar.cc/150?u=provider'.obs;

  var newRequestsCount = 0.obs;
  var inProgressRequestsCount = 0.obs;
  var approvedRequestsCount = 0.obs;

  final RxList<ServiceRequest> allRequests = <ServiceRequest>[].obs;
  final RxList<ServiceRequest> filteredRequests = <ServiceRequest>[].obs;
  final RxList<CategorizedOffers> categorizedOffers = <CategorizedOffers>[].obs;

  var selectedStatusFilter = Rxn<ServiceRequestStatus>();
  var offerStatusFilter = 'نشط'.obs;

  var weeklyChartData = <double>[12, 15, 8, 18, 10, 14, 16].obs;

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
    await Future.delayed(const Duration(milliseconds: 1200));

    allRequests.assignAll(_generateFakeServiceRequests());
    categorizedOffers.assignAll(_generateFakeCategorizedOffers());
    _updateDashboardStats();
    filterRequests(selectedStatusFilter.value);

    isLoading.value = false;
  }

  void _updateDashboardStats() {
    newRequestsCount.value = allRequests.where((r) => r.status == ServiceRequestStatus.pending).length;
    inProgressRequestsCount.value = allRequests.where((r) => r.status == ServiceRequestStatus.inProgress).length;
    approvedRequestsCount.value = allRequests.where((r) => r.status == ServiceRequestStatus.approved).length;
  }

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

  Future<void> updateRequestStatus(String requestId, ServiceRequestStatus newStatus) async {
    var requestIndex = allRequests.indexWhere((r) => r.id == requestId);
    if (requestIndex != -1) {
      var oldRequest = allRequests[requestIndex];
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await Future.delayed(const Duration(milliseconds: 700));
      Get.back();

      allRequests[requestIndex] = ServiceRequest(
        id: oldRequest.id, applicantName: oldRequest.applicantName,
        applicantImageUrl: oldRequest.applicantImageUrl, insuranceType: oldRequest.insuranceType,
        requestDate: oldRequest.requestDate, status: newStatus, notes: oldRequest.notes,
      );

      filterRequests(selectedStatusFilter.value);
      _updateDashboardStats();

      Get.snackbar(
        'تم التحديث بنجاح',
        'تم تغيير حالة الطلب "${oldRequest.applicantName}" إلى "${newStatus.displayName}".',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600, colorText: Colors.white,
        margin: const EdgeInsets.all(10), borderRadius: 8,
        icon: Icon(newStatus.icon, color: Colors.white),
      );
    }
  }

  Future<void> goToAddOffer() async {
    final result = await Get.toNamed(Routes.OFFER_FORM);
    if (result == true) {
      fetchDashboardData(); // إعادة تحميل البيانات بعد الإضافة
    }
  }

  Future<void> goToEditOffer(InsuranceOffer offer) async {
    final result = await Get.toNamed(Routes.OFFER_FORM, arguments: offer);
    if (result == true) {
      fetchDashboardData(); // إعادة تحميل البيانات بعد التعديل
    }
  }

  void deleteOffer(String offerId) {
    Get.defaultDialog(
        title: "تأكيد الحذف", middleText: "هل أنت متأكد من حذف هذا العرض؟",
        textConfirm: "نعم, حذف", textCancel: "إلغاء",
        buttonColor: Colors.red.shade700, confirmTextColor: Colors.white,
        onConfirm: () {
          for (var category in categorizedOffers) {
            category.offers.removeWhere((offer) => offer.offerId == offerId);
          }
          categorizedOffers.refresh();
          _updateDashboardStats();
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
        Get.snackbar('تم تغيير الحالة', 'تم تغيير حالة العرض إلى "${offer.isActive ? 'نشط' : 'غير نشط'}".');
        break;
      }
    }
  }

  void toggleCategoryExpansion(int categoryIndex) {
    if (categoryIndex >= 0 && categoryIndex < categorizedOffers.length) {
      categorizedOffers[categoryIndex].isExpanded.toggle();
    }
  }

  void setOfferStatusFilter(String status) => offerStatusFilter.value = status;

  void logout() {
    Get.defaultDialog(
      title: "تسجيل الخروج", middleText: "هل أنت متأكد من تسجيل الخروج؟",
      textConfirm: "نعم", textCancel: "إلغاء",
      onConfirm: () { Get.back(); Get.offAllNamed(Routes.LOGIN); },
    );
  }

  List<ServiceRequest> _generateFakeServiceRequests() {
    return [
      ServiceRequest(id: 'SR001', applicantName: 'أحمد خالد', insuranceType: 'تأمين صحي شامل', requestDate: DateTime.now().subtract(const Duration(hours: 3)), status: ServiceRequestStatus.pending, applicantImageUrl: 'https://i.pravatar.cc/150?u=ahmed'),
      ServiceRequest(id: 'SR002', applicantName: 'سارة علي', insuranceType: 'تأمين سيارة ضد الغير', requestDate: DateTime.now().subtract(const Duration(days: 1, hours: 5)), status: ServiceRequestStatus.inProgress, notes: "بانتظار فحص السيارة", applicantImageUrl: 'https://i.pravatar.cc/150?u=sara'),
    ];
  }

  List<CategorizedOffers> _generateFakeCategorizedOffers() {
    return [
      CategorizedOffers(categoryName: "تأمين السيارات", categoryIcon: Icons.directions_car_filled_rounded, initiallyExpanded: true, offers: [
        InsuranceOffer(offerId: 'CAR_PREMIUM_01', companyName: 'شركة الأمانة', companyLogoUrl: '...', annualPrice: 350000, coverageDetails: ['تغطية شاملة ضد الحوادث والسرقة', 'مساعدة على الطريق 24/7', 'سيارة بديلة أثناء الإصلاح', 'تغطية الأضرار الجسدية للسائق والركاب', 'إصلاح ضمن الوكالة المعتمدة'], isActive: true, extraBenefits: []),
        InsuranceOffer(offerId: 'CAR_BASIC_02', companyName: 'شركة الأمانة', companyLogoUrl: '...', annualPrice: 180000, coverageDetails: ['تغطية ضد الغير فقط', 'إصلاح ضمن شبكة ورش معتمدة', 'سقف تغطية يصل إلى 5 مليون ل.س'], isActive: false, extraBenefits: []),
      ]),
      CategorizedOffers(categoryName: "التأمين الصحي", categoryIcon: Icons.health_and_safety_rounded, offers: [
        InsuranceOffer(offerId: 'HEALTH_GOLD_01', companyName: 'شركة الأمانة', companyLogoUrl: '...', annualPrice: 550000, coverageDetails: ['تغطية استشفاء 100% درجة أولى', 'عيادات خارجية وأدوية (سقف سنوي)', 'تغطية أسنان ونظارات (جزئية)', 'فحوصات مخبرية وأشعة'], isActive: true, extraBenefits: []),
      ]),
      CategorizedOffers(categoryName: "تأمين السفر", categoryIcon: Icons.flight_takeoff_rounded, offers: [
        InsuranceOffer(offerId: 'TRAVEL_EURO_01', companyName: 'شركة الأمانة', companyLogoUrl: '...', annualPrice: 90000, coverageDetails: ['تغطية طبية طارئة حتى 50 ألف يورو', 'فقدان الأمتعة', 'إلغاء الرحلة'], isActive: true, extraBenefits: []),
      ]),
    ];
  }
}