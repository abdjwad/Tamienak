// مسار الملف: lib/features/home/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/models/article_model.dart';
import '../../../app/data/models/insurance_type_model.dart';
import '../../../app/data/models/notification_model.dart';
import '../../../app/data/models/partner_company_model.dart';
import '../../../app/data/models/profile_task_model.dart';
import '../../../app/data/models/user_policy_model.dart';
import '../../../app/routes/app_routes.dart';
import '../screens/home_screen.dart';

// enum جديد لتمثيل التبويب النشط
enum NotificationFilter { all, offers, alerts }

class HomeController extends GetxController {
  var isLoading = true.obs;
  var userName = "محمد".obs;

  // قوائم البيانات
  final RxList<UserPolicy> userPolicies = <UserPolicy>[].obs;
  final RxList<InsuranceType> insuranceTypes = <InsuranceType>[].obs;
  final RxList<PartnerCompany> partnerCompanies = <PartnerCompany>[].obs;
  final RxList<Article> featuredArticles = <Article>[].obs;

  // متغيرات ميزة "مستوى الأمان"
  final RxDouble profileCompletionPercentage = 0.0.obs;
  final RxList<ProfileTask> profileTasks = <ProfileTask>[].obs;

  // متغيرات لوحة الإشعارات
  final RxList<AppNotification> allNotifications = <AppNotification>[].obs;
  final RxList<AppNotification> filteredNotifications = <AppNotification>[].obs;
  final Rx<NotificationFilter> activeNotificationFilter = NotificationFilter.all.obs;

  // متغير لإدارة حالة الزر العائم
  var isDialOpen = false.obs;

  Map<String, dynamic>? get currentUser {
    return {
      'displayName': 'محمد المستخدم',
      'email': 'mohammad.user@example.com',
      'photoURL': 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?auto=format&fit=crop&q=80',
    };
  }

  @override
  void onReady() {
    super.onReady();
    fetchData();
  }

  void fetchData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1500));

    userPolicies.assignAll([
      UserPolicy(
        policyName: "تأمين سيارة شامل",
        companyName: "السورية للتأمين",
        status: PolicyStatus.active,
        iconData: Icons.directions_car_filled_rounded,
      ),
    ]);

    insuranceTypes.assignAll([
      InsuranceType(id: "car", name: "السيارات", icon: Icons.directions_car_filled, description: 'تغطية شاملة لسيارتك'),
      InsuranceType(id: "health", name: "الصحي", icon: Icons.local_hospital, description: 'رعاية صحية لك ولعائلتك'),
      InsuranceType(id: "life", name: "الحياة", icon: Icons.family_restroom, description: 'استثمار آمن لمستقبلك'),
      InsuranceType(id: "travel", name: "السفر", icon: Icons.flight_takeoff, description: 'سافر بأمان وراحة بال'),
    ]);

    partnerCompanies.assignAll([
      PartnerCompany(name: 'السورية للتأمين', logoUrl: 'https://image-placeholder.com/images/150x150/5603ad/ffffff/fa-fa-shield-halved?text=SCI&font_size=40'),
      PartnerCompany(name: 'الثقة للتأمين', logoUrl: 'https://image-placeholder.com/images/150x150/8367c7/ffffff/fa-fa-hand-holding-heart?text=ATI&font_size=40'),
    ]);

    allNotifications.assignAll([
      AppNotification(id: "1", title: "عرض جديد!", body: "الشركة السورية قدمت عرضاً لبوليصة سيارتك.", timestamp: DateTime.now().subtract(const Duration(minutes: 5)), type: NotificationType.offer, isRead: false),
      AppNotification(id: "2", title: "حالة طلبك", body: "تمت الموافقة على طلب التأمين الصحي.", timestamp: DateTime.now().subtract(const Duration(hours: 2)), type: NotificationType.status, isRead: true),
      AppNotification(id: "3", title: "تنبيه: بوليصة على وشك الانتهاء", body: "تأمين سيارتك ستنتهي خلال 7 أيام.", timestamp: DateTime.now().subtract(const Duration(days: 1)), type: NotificationType.alert, isRead: false),
      AppNotification(id: "4", title: "مرحباً بك!", body: "نحن سعداء بانضمامك إلى تطبيق وساطة التأمين.", timestamp: DateTime.now().subtract(const Duration(days: 3)), type: NotificationType.status, isRead: true),
    ]);

    filterNotifications(NotificationFilter.all);

    featuredArticles.assignAll([
      Article(title: "نصائح لاختيار التأمين الصحي الأمثل لعائلتك", imageUrl: "https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?auto=format&fit=crop&q=60", readTime: "5 دقائق"),
      Article(title: "كل ما تحتاج معرفته عن التأمين الشامل للسيارات", imageUrl: "https://images.unsplash.com/photo-1553556422-4c26a5d4d38c?auto=format&fit=crop&q=60", readTime: "7 دقائق"),
    ]);

    _setupProfileCompletionTasks();

    isLoading.value = false;
  }

  // ======== [ منطق ميزة مستوى الأمان ] ========
  void _setupProfileCompletionTasks() {
    bool hasCarPolicy = userPolicies.any((p) => p.iconData == Icons.directions_car_filled_rounded);
    bool hasHealthPolicy = userPolicies.any((p) => p.iconData == Icons.local_hospital_rounded);

    final tasks = [
      ProfileTask(
        title: 'أضف أول بوليصة سيارة',
        icon: Icons.directions_car,
        isCompleted: hasCarPolicy,
        onTap: () {
          final carType = insuranceTypes.firstWhere((t) => t.id == 'car', orElse: () => insuranceTypes.first);
          Get.toNamed(Routes.QUOTE_REQUEST, arguments: carType);
        },
      ),
      ProfileTask(
        title: 'استكشف التأمين الصحي',
        icon: Icons.local_hospital_outlined,
        isCompleted: hasHealthPolicy,
        onTap: () {
          final healthType = insuranceTypes.firstWhere((t) => t.id == 'health', orElse: () => insuranceTypes.first);
          Get.toNamed(Routes.QUOTE_REQUEST, arguments: healthType);
        },
      ),
      ProfileTask(
        title: 'تصفح شركاءنا',
        icon: Icons.business_center,
        isCompleted: false,
        onTap: () {
          Get.toNamed(Routes.COMPANY_LIST);
        },
      ),
      ProfileTask(
        title: 'اقرأ عن تأمين السفر',
        icon: Icons.article_outlined,
        isCompleted: false,
        onTap: () {},
      ),
    ];

    profileTasks.assignAll(tasks);
    _calculateProfileCompletion();
  }

  void _calculateProfileCompletion() {
    if (profileTasks.isEmpty) {
      profileCompletionPercentage.value = 0.0;
      return;
    }
    final completedTasks = profileTasks.where((task) => task.isCompleted).length;
    profileCompletionPercentage.value = completedTasks / profileTasks.length;
  }

  // ======== [ منطق الإشعارات ] ========
  void showNotificationsSheet() {
    Get.bottomSheet(
      NotificationsSheetWidget(controller: this),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void filterNotifications(NotificationFilter filter) {
    activeNotificationFilter.value = filter;
    switch (filter) {
      case NotificationFilter.all:
        filteredNotifications.assignAll(allNotifications);
        break;
      case NotificationFilter.offers:
        filteredNotifications.assignAll(allNotifications.where((n) => n.type == NotificationType.offer));
        break;
      case NotificationFilter.alerts:
        filteredNotifications.assignAll(allNotifications.where((n) => n.type == NotificationType.alert));
        break;
    }
  }

  void markAsRead(String notificationId) {
    final index = allNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      allNotifications[index].isRead = true;
      allNotifications.refresh();
      filterNotifications(activeNotificationFilter.value);
    }
  }

  void deleteNotification(String notificationId) {
    allNotifications.removeWhere((n) => n.id == notificationId);
    filterNotifications(activeNotificationFilter.value);
  }

  // ======== [ وظائف عامة ] ========
  void toggleTheme() {
    Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  void toggleDial() {
    isDialOpen.value = !isDialOpen.value;
  }

  void logout() {
    Get.defaultDialog(
      title: "تأكيد تسجيل الخروج",
      middleText: "هل أنت متأكد أنك تريد تسجيل الخروج؟",
      textConfirm: "نعم",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }
}