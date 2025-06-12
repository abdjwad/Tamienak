import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamienk/features/company_list/company_list_controller.dart';
import '../../../app/data/models/company_model.dart';

class CompanyListScreen extends GetView<CompanyListController> {
  const CompanyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "شركات ${controller.selectedInsuranceType.name}",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        // لإعطاء شكل أفضل للـ AppBar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.filteredCompanies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_center_sharp, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "لا توجد شركات لهذا النوع حالياً",
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: controller.filteredCompanies.length,
          itemBuilder: (context, index) {
            final company = controller.filteredCompanies[index];
            // استخدام Animation لجعل الدخول سلساً
            return _CompanyCard(company: company, index: index);
          },
        );
      }),
    );
  }
}

// ويدجت خاصة ببطاقة الشركة لجعل الكود نظيفاً
class _CompanyCard extends StatelessWidget {
  const _CompanyCard({Key? key, required this.company, required this.index}) : super(key: key);

  final Company company;
  final int index;

  // ويدجت صغيرة لعرض النجوم
  Widget _buildRatingStars(double rating, BuildContext context) {
    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      stars.add(Icon(
        i < rating ? (i < rating - 0.5 ? Icons.star : Icons.star_half) : Icons.star_border,
        color: Colors.amber,
        size: 18,
      ));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shadowColor: theme.colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // يمكن هنا الانتقال إلى صفحة تفاصيل الشركة أو عروضها
          Get.snackbar(
            'تم الضغط على',
            company.name,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // شعار الشركة
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  company.logoUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // تفاصيل الشركة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _buildRatingStars(company.rating, context),
                    const SizedBox(height: 8),
                    Text(
                      company.description,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // أيقونة الانتقال
              Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}