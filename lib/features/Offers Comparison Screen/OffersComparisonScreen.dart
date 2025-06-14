// presentation/modules/offers_comparison/screens/offers_comparison_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tamienk/app/routes/app_routes.dart';
import 'package:tamienk/features/Offers%20Comparison%20Screen/OffersComparisonController.dart';

import '../../../app/data/models/insurance_offer_model.dart';

class OffersComparisonScreen extends GetView<OffersComparisonController> {
  const OffersComparisonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مقارنة أفضل العروض"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingShimmer(); // عرض تأثير الشيمر
        }
        if (controller.offers.isEmpty) {
          return const Center(child: Text("عذراً، لم نجد أي عروض."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: controller.offers.length,
          itemBuilder: (context, index) {
            final offer = controller.offers[index];
            return _OfferCard(offer: offer)
                .animate() // إضافة انيميشن
                .fadeIn(duration: 500.ms, delay: (100 * index).ms)
                .slideY(begin: 0.2, curve: Curves.easeOutCubic);
          },
        );
      }),
    );
  }

  // *** لمسة خاصة: تأثير التحميل الأنيق ***
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: 3,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 150, height: 24, color: Colors.white),
                const Divider(height: 24),
                Container(width: double.infinity, height: 16, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 16, color: Colors.white),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 80, height: 28, color: Colors.white),
                      ],
                    ),
                    Container(width: 120, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// *** لمسة خاصة: تصميم بطاقة عرض جذاب ومميز ***
// في ملف offers_comparison_screen.dart

class _OfferCard extends StatelessWidget {
  final InsuranceOffer offer;
  const _OfferCard({Key? key, required this.offer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatCurrency = NumberFormat.currency(locale: 'ar_SY', symbol: 'ل.س', decimalDigits: 0);

    // تحديد لون الحدود بناء على العرض الأفضل
    final cardBorder = offer.isBestValue
        ? Border.all(color: Colors.amber.shade700, width: 2)
        : null;

    // هذا هو المحتوى الأساسي للبطاقة
    final cardContent = Container(
      decoration: BoxDecoration(
        border: cardBorder,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offer.companyName,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          ...offer.coverageDetails.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(detail, style: theme.textTheme.bodyMedium)),
            ]),
          )).toList(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("السعر السنوي", style: theme.textTheme.bodySmall),
                  Text(
                    formatCurrency.format(offer.annualPrice),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => Get.find<OffersComparisonController>().selectOffer(offer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: offer.isBestValue ? colorScheme.primary : colorScheme.secondary,
                  foregroundColor: offer.isBestValue ? colorScheme.onPrimary : colorScheme.onSecondary,
                ),
                child: const Text("اختيار العرض"),
              ),
            ],
          ),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: offer.isBestValue ? 6 : 2,
      shadowColor: offer.isBestValue ? Colors.amber.withOpacity(0.3) : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias, // مهم لكي يظهر البانر بشكل صحيح
      child: offer.isBestValue
          ? Banner( // يتم عرض البانر فقط إذا كان العرض هو الأفضل
        message: "الأفضل قيمة",
        location: BannerLocation.topStart,
        color: Colors.amber.shade700,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        child: cardContent, // يتم وضع المحتوى داخل البانر
      )
          : cardContent, // يتم وضع المحتوى مباشرة بدون بانر
    );
  }
}