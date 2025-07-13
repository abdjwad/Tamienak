// مسار الملف: lib/features/company_details/screens/company_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tamienk/features/company_details/company_details_controller.dart';
import '../../../app/data/models/insurance_product_model.dart';
import '../../../app/data/models/pricing_plan_model.dart';

class CompanyDetailsScreen extends GetView<CompanyDetailsController> {
  const CompanyDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                controller.company.name,
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: _CompanyHeader(controller: controller),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _ProductTypeTabsDelegate(controller: controller),
          ),
          Obx(() {
            if (controller.filteredProducts.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: const Text("لا توجد منتجات من هذا النوع حالياً.")
                      .animate()
                      .fadeIn(),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final product = controller.filteredProducts[index];
                    return _ProductCard(
                        product: product, controller: controller)
                        .animate()
                        .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOutCubic);
                  },
                  childCount: controller.filteredProducts.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============== [ الويدجتس المخصصة لهذه الشاشة ] ==============

class _CompanyHeader extends StatelessWidget {
  final CompanyDetailsController controller;
  const _CompanyHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://images.unsplash.com/photo-1517976487-142835255339?auto=format&fit=crop&q=80',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: Colors.grey.shade300),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: const [0.3, 0.7, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(controller.company.logoUrl),
            onBackgroundImageError: (exception, stackTrace) {}, // لمنع الخطأ عند فشل تحميل الشعار
          ).animate().scale(delay: 200.ms),
        )
      ],
    );
  }
}

class _ProductTypeTabsDelegate extends SliverPersistentHeaderDelegate {
  final CompanyDetailsController controller;

  _ProductTypeTabsDelegate({required this.controller});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: maxExtent,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: controller.availableProductTypes.length,
        itemBuilder: (context, index) {
          final type = controller.availableProductTypes[index];
          final isSelected = controller.selectedType.value?.id == type.id;
          return GestureDetector(
            onTap: () => controller.changeSelectedType(type),
            child: AnimatedContainer(
              duration: 300.ms,
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Theme.of(context)
                      .colorScheme
                      .outline
                      .withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type.icon,
                    size: 18,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type.name,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )),
    );
  }

  @override
  double get maxExtent => 56.0;
  @override
  double get minExtent => 56.0;
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}


class _ProductCard extends StatelessWidget {
  final InsuranceProduct product;
  final CompanyDetailsController controller;
  const _ProductCard({required this.product, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final isExpanded = controller.expandedProducts[product.id] ?? false;
      return Card(
        elevation: isExpanded ? 6 : 2,
        shadowColor: theme.colorScheme.primary.withOpacity(0.2),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.toggleProductExpansion(product.id),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(product.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: 300.ms,
                      child: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: 300.ms,
              curve: Curves.easeInOut,
              child: isExpanded
                  ? SizedBox(
                height: 230,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // Adjusted padding
                  itemCount: product.plans.length,
                  itemBuilder: (context, index) {
                    final plan = product.plans[index];
                    return _PricingPlanCard(
                      plan: plan,
                      product: product,
                      controller: controller,
                    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.5);
                  },
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }
}


// [FIXED] تم إصلاح خطأ تجاوز الحدود في هذه الويدجت
class _PricingPlanCard extends StatelessWidget {
  final PricingPlan plan;
  final InsuranceProduct product;
  final CompanyDetailsController controller;
  const _PricingPlanCard({required this.plan, required this.product, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.5),
            theme.colorScheme.primaryContainer.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.colorScheme.primaryContainer),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(plan.icon, size: 22, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(plan.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
            const Spacer(),
            Text("${plan.price} ل.س", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
            Text("/ ${plan.durationInDays} يوم", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7))),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: () => controller.selectPlan(product, plan),
                child: const Text("اختيار"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}