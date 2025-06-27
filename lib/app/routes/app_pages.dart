// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:tamienk/features/ApplicationForm/ApplicationFormBinding.dart';
import 'package:tamienk/features/ApplicationForm/ApplicationFormScreen.dart';
import 'package:tamienk/features/Offer%20Details/OfferDetailsBinding.dart';
import 'package:tamienk/features/Offer%20Details/OfferDetailsScreen.dart';
import 'package:tamienk/features/Offers%20Comparison%20Screen/OffersComparisonBinding.dart';
import 'package:tamienk/features/auth/register/bindings/register_binding.dart';
import 'package:tamienk/features/auth/register/screens/register_screen.dart';
import 'package:tamienk/features/company_list/company_list_binding.dart';
import 'package:tamienk/features/company_list/company_list_screen.dart';
import 'package:tamienk/features/final_comparison_screen/FinalComparisonScreen.dart';
import 'package:tamienk/features/service_provider_dashboard/ServiceProviderDashboardBinding.dart';
import 'package:tamienk/features/service_provider_dashboard/ServiceProviderDashboardScreen.dart';
import '../../features/Offers Comparison Screen/OffersComparisonScreen.dart';
import '../../features/Quote Request Screen/QuoteRequestBinding.dart';
import '../../features/Quote Request Screen/QuoteRequestScreen.dart';
import '../../features/auth/login/bindings/login_binding.dart';
import '../../features/auth/login/screens/login_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/final_comparison_screen/FinalComparisonBinding.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/offer_form/offer_form_binding.dart';
import '../../features/offer_form/offer_form_screen.dart';
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
    GetPage(
      name: Routes.WELCOME, // <--- أضف مسارًا للشاشة الجديدة
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: Routes.WELCOME, // <--- أضف مسارًا للشاشة الجديدة
      page: () => const WelcomeScreen(),
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
    ),
    GetPage(
      name: Routes.SERVICE_PROVIDER_DASHBOARD, // <--- الجديد
      page: () => const ServiceProviderDashboardScreen(),
      binding: ServiceProviderDashboardBinding(),
    ),
    GetPage(
      // <--- الجديد
      name: Routes.OFFER_FORM,
      page: () => const OfferFormScreen(),
      binding: OfferFormBinding(),
    ), // <-- أضف هذا الجزء
    GetPage(
      // <-- أضف هذه الصفحة الجديدة
      name: Routes.COMPANY_LIST,
      page: () => const CompanyListScreen(),
      binding: CompanyListBinding(),
      transition: Transition.rightToLeftWithFade, // تأثير انتقال جميل
    ),
    GetPage(
      name: Routes.QUOTE_REQUEST,
      page: () => QuoteRequestScreen(),
      binding: QuoteRequestBinding(), // سنقوم بإنشاء هذا
    ),
    GetPage(
      name: Routes.FINAL_COMPARISON,
      page: () => const FinalComparisonScreen(),
      binding: FinalComparisonBinding(), // <--- أضف الـ Binding الجديد
      transition: Transition.downToUp, // تأثير انتقال جميل
    ),
    GetPage(
      name: Routes.OFFERS_COMPARISON,
      page: () => const OffersComparisonScreen(),
      binding: OffersComparisonBinding(), // <--- هذه هي التعليمة الحاسمة
      transition:
          Transition.rightToLeftWithFade, // <--- يمكنك إضافة تأثير انتقال جميل
    ),
    GetPage(
      name: Routes.OFFER_DETAILS,
      page: () => const OfferDetailsScreen(),
      binding: OfferDetailsBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.OFFERS_COMPARISON,
      page: () => const OffersComparisonScreen(),
      binding: OffersComparisonBinding(),
    ),
    GetPage(
      name: Routes.OFFER_DETAILS,
      page: () => const OfferDetailsScreen(),
      binding: OfferDetailsBinding(),
    ),
    GetPage(
      name: Routes.APPLICATION_FORM,
      page: () => const ApplicationFormScreen(),
      binding: ApplicationFormBinding(),
    ),
  ];
}
