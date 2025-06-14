// presentation/modules/offer_details/screens/offer_details_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'OfferDetailsController.dart';

class OfferDetailsScreen extends GetView<OfferDetailsController> {
  const OfferDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatCurrency = NumberFormat.currency(locale: 'ar_SY', symbol: 'ل.س', decimalDigits: 0);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0, // زيادة الارتفاع لجاذبية أكثر
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.offer.companyName,
                    style: const TextStyle(shadows: [Shadow(blurRadius: 8)]),
                  ),
                  if (controller.offer.isBestValue) // إضافة شارة "الأفضل قيمة"
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: const Text(
                          "الأفضل قيمة",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.amber.shade700,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    controller.offer.companyLogoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Center(child: Icon(Icons.broken_image, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ),
                  Container( // تدرج لوني لتحسين وضوح النص
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.0, 0.4, 0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- قسم السعر (مع تحسين التصميم) ---
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text("السعر السنوي", style: theme.textTheme.titleMedium),
                              Text(
                                formatCurrency.format(controller.offer.annualPrice),
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text("شامل الضرائب والرسوم", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 100.ms)
                      .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutCubic) // <--- تم التعديل هنا (begin: Offset)
                      .slideY(), // <--- تم إزالة الفاصلة التي كانت هنا في السطر السابق
                  const SizedBox(height: 24),

                  // --- قسم تفاصيل التغطية ---
                  _buildSectionHeader(context, "تفاصيل التغطية", Icons.verified_user_outlined),
                  // تم تعديل طريقة تطبيق الانيميشن ليكون على كل عنصر على حدة
                  ...controller.offer.detailedCoverage.entries.toList().asMap().entries.map((mapEntry) {
                    final int index = mapEntry.key;
                    final entry = mapEntry.value;
                    return _buildCoverageTile(context, entry.key, entry.value)
                        .animate() // animate تُطبق على الودجيت الفردي
                        .fadeIn(duration: 400.ms, delay: (100 * index).ms) // تطبيق تأخير لكل عنصر
                        .slideX(); // <--- تم التعديل هنا (begin: Offset)
                  }).toList(), // هذا الـ .toList() يقوم بجمع الودجيتات المتحركة
                  const SizedBox(height: 24),

                  // --- قسم المستندات المطلوبة ---
                  _buildSectionHeader(context, "المستندات المطلوبة", Icons.article_outlined),
                  // تم تعديل طريقة تطبيق الانيميشن ليكون على كل عنصر على حدة
                  ...controller.offer.requiredDocuments.asMap().entries.map((mapEntry) {
                    final int index = mapEntry.key;
                    final doc = mapEntry.value;
                    return _buildDocumentTile(context, doc)
                        .animate() // animate تُطبق على الودجيت الفردي
                        .fadeIn(duration: 400.ms, delay: (100 * index).ms) // إضافة تأخير للحركة المتتالية
                        .slideX(); // <--- تم التعديل هنا (begin: Offset)
                  }).toList(),
                  const SizedBox(height: 24),

                  // --- رابط الشروط والأحكام (زر محسّن) ---
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: controller.launchTermsUrl,
                      icon: const Icon(Icons.description_outlined),
                      label: const Text("قراءة الشروط والأحكام الكاملة"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary.withOpacity(0.7)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                ],
              ),
            ),
          ),
        ],
      ),
      // --- زر التقديم العائم ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text("التقديم على هذا العرض"),
          onPressed: controller.applyForOffer,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary, // استخدام لون الثيم الأساسي
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
          ),
        ).animate() // animate تُطبق مباشرة على الـ ElevatedButton
            .slideY( duration: 600.ms, curve: Curves.easeOut), // <--- تم التأكد من هذا السطر
      ),
    );
  }

  // --- ويدجتس مساعدة للتصميم (تم تحسينها) ---

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverageTile(BuildContext context, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile(BuildContext context, String docName) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0, // لا حاجة لظلال كثيرة هنا
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.file_copy_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                docName,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}