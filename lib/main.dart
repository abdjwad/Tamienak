import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tamienk/app/theme/app_them.dart';

import 'app/routes/app_pages.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "وساطة التأمين",
      debugShowCheckedModeBanner: false,

      locale: const Locale('ar', 'SY'),
      supportedLocales: const [
        Locale('ar', 'SY'),
      ],

      // --- الحل رقم 2: تم حذف كلمة const من هنا ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,

      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}