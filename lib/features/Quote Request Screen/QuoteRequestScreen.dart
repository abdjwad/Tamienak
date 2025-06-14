// presentation/modules/quote_request/screens/quote_request_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'QuoteRequestController.dart';

class QuoteRequestScreen extends GetView<QuoteRequestController> {
  const QuoteRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('طلب عرض سعر لـ ${controller.insuranceType.name}'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(controller.insuranceType.icon, size: 60, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    "أخبرنا بالمزيد عن احتياجاتك",
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "كلما كانت المعلومات أدق، كانت العروض أفضل.",
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // *** هنا يتم بناء النموذج ديناميكياً ***
                  _buildDynamicForm(context),

                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: controller.submitQuoteRequest,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: const Text("الحصول على العروض"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            // *** لمسة جمالية: عرض شاشة التحميل فوق المحتوى ***
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text("جاري البحث عن أفضل العروض...", style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  // دالة بناء النموذج الديناميكي
  Widget _buildDynamicForm(BuildContext context) {
    switch (controller.insuranceType.id) {
      case 'car':
        return _buildCarInsuranceForm();
      case 'health':
        return _buildHealthInsuranceForm();
      case 'travel':
        return _buildTravelInsuranceForm();
      default:
        return Text("لا يوجد نموذج متاح لهذا النوع من التأمين حالياً.", textAlign: TextAlign.center);
    }
  }

  Widget _buildCarInsuranceForm() {
    return Column(children: [
      TextFormField(
        controller: controller.formControllers['carModel'],
        decoration: const InputDecoration(labelText: 'ماركة وموديل السيارة', border: OutlineInputBorder(), prefixIcon: Icon(Icons.directions_car)),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: controller.formControllers['carYear'],
        decoration: const InputDecoration(labelText: 'سنة الصنع', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
        keyboardType: TextInputType.number,
      ),
    ]);
  }

  Widget _buildHealthInsuranceForm() {
    return Column(children: [
      TextFormField(
        controller: controller.formControllers['personAge'],
        decoration: const InputDecoration(labelText: 'عمر المؤمن عليه', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
        keyboardType: TextInputType.number,
      ),
      // يمكن إضافة المزيد من الحقول مثل (أمراض مزمنة، إلخ)
    ]);
  }

  Widget _buildTravelInsuranceForm() {
    return Column(children: [
      TextFormField(
        controller: controller.formControllers['tripDestination'],
        decoration: const InputDecoration(labelText: 'وجهة السفر', border: OutlineInputBorder(), prefixIcon: Icon(Icons.flight_takeoff)),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: controller.formControllers['tripDuration'],
        decoration: const InputDecoration(labelText: 'مدة الرحلة (بالأيام)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.date_range)),
        keyboardType: TextInputType.number,
      ),
    ]);
  }
}