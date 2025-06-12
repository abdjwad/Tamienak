// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:tamienk/features/company_list/company_list_binding.dart';
import 'package:tamienk/features/company_list/company_list_screen.dart';
import 'package:tamienk/features/register/bindings/register_binding.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/login/bindings/login_binding.dart'; // <-- Import binding
import '../../features/login/screens/login_screen.dart';   // <-- Import screen
import '../../features/register/screens/register_screen.dart';
import 'app_routes.dart';

class AppPages {
  // Make the login screen the first screen of the app
  static const INITIAL = Routes.LOGIN; // <-- Change this

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    // Add the new GetPage for the login screen
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginBinding(), // <-- Bind it here
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ), // <-- أضف هذا الجزء
    GetPage( // <-- أضف هذه الصفحة الجديدة
      name: Routes.COMPANY_LIST,
      page: () => const CompanyListScreen(),
      binding: CompanyListBinding(),
      transition: Transition.rightToLeftWithFade, // تأثير انتقال جميل
    ),

  ];
}