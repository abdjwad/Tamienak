// lib/main.dart (مثال)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- هذا هو الاستيراد الصحيح
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Tamienk App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2980B9), // اللون الأساسي
          secondary: const Color(0xFFF1C40F), // لون ثانوي جذاب (أصفر/ذهبي)
          background: const Color(0xFFF5F5F5), // لون الخلفية الفاتح
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF3498DB), // لون أساسي للوضع الداكن
          secondary: const Color(0xFFF1C40F), // نفس اللون الثانوي
          background: const Color(0xFF121212), // خلفية داكنة
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: Routes.HOME, // أو أي مسار بداية تريده
      getPages: AppPages.routes,
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      localizationsDelegates: const [ // <-- إضافة هذا الجزء مهم جداً
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}