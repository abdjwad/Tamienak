import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // تأكد من استيرادها إذا كنت تستخدمها

import '../../../app/data/models/insurance_type_model.dart';
import '../../../app/data/models/user_policy_model.dart';
import '../../../app/data/models/notification_model.dart';
import '../../../app/routes/app_routes.dart';
import '../screens/home_screen.dart'; // هذا الاستيراد ضروري لـ NotificationsSheetWidget

class HomeController extends GetxController {
  var isLoading = true.obs;
  var userName = "محمد".obs;

  final RxList<UserPolicy> userPolicies = <UserPolicy>[].obs;
  final RxList<InsuranceType> insuranceTypes = <InsuranceType>[].obs;
  final RxList<String> partnerCompanies = <String>[].obs;
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxList<Article> featuredArticles = <Article>[].obs;

  // محاكاة لبيانات المستخدم الحالي (بدون Firebase)
  Map<String, dynamic>? get currentUser {
    return {
      'displayName': 'محمد المستخدم',
      'email': 'mohammad.user@example.com',
      'photoURL': 'https://via.placeholder.com/150/5603AD/FFFFFF?text=MU', // صورة رمزية
    };
  }

  @override
  void onReady() {
    super.onReady();
    fetchData();
  }

  void fetchData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));

    userPolicies.assignAll([
      UserPolicy(policyName: "تأمين سيارة شامل", companyName: "السورية للتأمين", status: PolicyStatus.active, iconAsset: ""),
      UserPolicy(policyName: "تأمين صحي", companyName: "الثقة للتأمين", status: PolicyStatus.pending, iconAsset: ""),
      UserPolicy(policyName: "تأمين شحن بحري", companyName: "العقيلة للتأمين", status: PolicyStatus.active, iconAsset: ""),
      UserPolicy(policyName: "تأمين شحن بحري", companyName: "العقيلة للتأمين", status: PolicyStatus.active, iconAsset: ""),
      UserPolicy(policyName: "تأمين شحن بحري", companyName: "العقيلة للتأمين", status: PolicyStatus.active, iconAsset: ""),
    ]);

    insuranceTypes.assignAll([
      InsuranceType(id: "car", name: "تأمين السيارات", icon: Icons.directions_car_filled, description: ''),
      InsuranceType(id: "health", name: "التأمين الصحي", icon: Icons.local_hospital, description: ''),
      InsuranceType(id: "life", name: "تأمين الحياة", icon: Icons.family_restroom, description: ''),
      InsuranceType(id: "travel", name: "تأمين السفر", icon: Icons.flight_takeoff, description: ''),
      InsuranceType(id: "car", name: "تأمين السيارات", icon: Icons.directions_car_filled, description: ''),
      InsuranceType(id: "health", name: "التأمين الصحي", icon: Icons.local_hospital, description: ''),
      InsuranceType(id: "life", name: "تأمين الحياة", icon: Icons.family_restroom, description: ''),
      InsuranceType(id: "travel", name: "تأمين السفر", icon: Icons.flight_takeoff, description: ''),
      // ... وهكذا لباقي الأنواع
    ]);

    partnerCompanies.assignAll(["", "", "", ""]);

    notifications.assignAll([
      AppNotification(title: "عرض جديد!", body: "الشركة السورية قدمت عرضاً لبوليصة سيارتك.", timestamp: DateTime.now().subtract(const Duration(minutes: 5)), type: NotificationType.offer),
      AppNotification(title: "حالة طلبك", body: "تمت الموافقة على طلب التأمين الصحي الخاص بك.", timestamp: DateTime.now().subtract(const Duration(hours: 2)), type: NotificationType.status, isRead: true),
      AppNotification(title: "تنبيه: بوليصة على وشك الانتهاء", body: "تأمين سيارتك ستنتهي خلال 7 أيام.", timestamp: DateTime.now().subtract(const Duration(days: 1)), type: NotificationType.alert),
      AppNotification(title: "مرحباً بك!", body: "نحن سعداء بانضمامك إلى تطبيق وساطة التأمين.", timestamp: DateTime.now().subtract(const Duration(days: 3)), type: NotificationType.status, isRead: true),
    ]);

    featuredArticles.assignAll([
      Article(title: "نصائح لاختيار التأمين الصحي الأمثل", imageUrl: "https://via.placeholder.com/150/B3E9C7/000000?text=Health", readTime: "5 دقائق قراءة"),
      Article(title: "تأمين سيارتك: كل ما تحتاج معرفته", imageUrl: "https://via.placeholder.com/150/C2F8CB/000000?text=Car", readTime: "7 دقائق قراءة"),
      Article(title: "أهمية تأمين السفر في رحلاتك الخارجية", imageUrl: "https://via.placeholder.com/150/F0FFF1/000000?text=Travel", readTime: "4 دقائق قراءة"),
    ]);

    isLoading.value = false;
  }

  void showNotificationsSheet() {
    Get.bottomSheet(
      // لا تغيير هنا
      NotificationsSheetWidget(notifications: notifications),

      backgroundColor: Get.theme.scaffoldBackgroundColor, // <--- هذا السطر يجب حذفه

      // لا تغيير هنا
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,

      // (إضافة اختيارية) لجعل خلفية التطبيق معتمة عند ظهور الورقة
      barrierColor: Colors.black.withOpacity(0.4),

    );
  }

  void toggleTheme() {
    if (Get.isDarkMode) {
      Get.changeThemeMode(ThemeMode.light);
    } else {
      Get.changeThemeMode(ThemeMode.dark);
    }
  }

  void logout() {
    Get.defaultDialog(
      title: "تأكيد تسجيل الخروج",
      middleText: "هل أنت متأكد أنك تريد تسجيل الخروج؟",
      textConfirm: "نعم، تسجيل الخروج",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }
}

class Article {
  final String title;
  final String imageUrl;
  final String readTime;
  Article({required this.title, required this.imageUrl, required this.readTime});
}