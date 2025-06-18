// presentation/modules/offers_comparison/screens/offers_comparison_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/data/models/insurance_offer_model.dart';
import 'OffersComparisonController.dart';

class OffersComparisonScreen extends GetView<OffersComparisonController> {
  const OffersComparisonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Obx(() {
        Widget background = AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: controller.isLoading.value || controller.offers.isEmpty
              ? Container(key: const ValueKey('loading_bg'), color: theme.scaffoldBackgroundColor)
              : Container(
            key: ValueKey(controller.offers[controller.pageOffset.value.round() % controller.offers.length].companyLogoUrl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  controller.backgroundGradients[controller.pageOffset.value.round() % controller.backgroundGradients.length][0].withOpacity(0.5),
                  theme.scaffoldBackgroundColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  left: -100,
                  child: Image.network(
                    controller.offers[controller.pageOffset.value.round() % controller.offers.length].companyLogoUrl,
                    width: 400,
                    height: 400,
                    color: Colors.white.withOpacity(0.05),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(), // إخفاء الخطأ
                  ),
                ),
              ],
            ),
          ),
        );

        return Stack(
          children: [
            background,
            SafeArea(
              child: Column(
                children: [
                  _buildCustomAppBar(),
                  Expanded(
                    child: controller.isLoading.value
                        ? _buildLoadingShimmer()
                        : controller.offers.isEmpty
                        ? _buildEmptyState()
                        : PageView.builder(
                      controller: controller.pageController,
                      itemCount: controller.offers.length,
                      itemBuilder: (context, index) {
                        return Obx(() {
                          double scale = 1.0;
                          double angle = 0.0;
                          if (controller.pageController.position.haveDimensions) {
                            scale = (1 - (controller.pageOffset.value - index).abs() * 0.25).clamp(0.8, 1.0);
                            angle = (controller.pageOffset.value - index) * -0.5;
                          }
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            alignment: angle > 0 ? Alignment.centerLeft : Alignment.centerRight,
                            child: Transform.scale(
                              scale: scale,
                              child: _OfferCard(offer: controller.offers[index]),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        child: controller.comparisonList.isNotEmpty
            ? _buildComparisonBar()
            : const SizedBox.shrink(),
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // === الدوال المساعدة التي تمت إعادتها ===

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const Text("اختر عرض التأمين", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.2),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Get.theme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text("عذراً، لم نجد أي عروض.", style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildComparisonBar() {
    final theme = Get.theme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() => Row(
                    children: controller.comparisonList.map((offer) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(offer.companyLogoUrl),
                      ),
                    )).toList(),
                  )),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.compare_arrows_rounded),
                label: Obx(() => Text("قارن الآن (${controller.comparisonList.length})")),
                onPressed: controller.startComparison,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: controller.clearComparison,
                tooltip: "مسح المقارنة",
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _OfferCard extends StatefulWidget {
  final InsuranceOffer offer;
  const _OfferCard({Key? key, required this.offer}) : super(key: key);

  @override
  State<_OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<_OfferCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _iconAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatCurrency = NumberFormat.currency(locale: 'ar_SY', symbol: ' ل.س', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (widget.offer.isBestValue) ...[
                        Chip(
                          label: const Text("الأفضل قيمة"),
                          backgroundColor: Colors.amber.shade700,
                          labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          avatar: const Icon(Icons.star, color: Colors.white, size: 16),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Image.network(
                        widget.offer.companyLogoUrl,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.business_rounded, size: 60, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.offer.companyName, style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(formatCurrency.format(widget.offer.annualPrice), style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.secondary)),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                InkWell(
                  onTap: _toggleExpanded,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("أبرز التغطيات", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        RotationTransition(
                          turns: _iconAnimation,
                          child: const Icon(Icons.expand_more, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: ConstrainedBox(
                    constraints: _isExpanded ? const BoxConstraints() : const BoxConstraints(maxHeight: 0.0),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: widget.offer.coverageDetails.map((detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(children: [
                            const Icon(Icons.check, color: Colors.greenAccent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(detail, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white))),
                          ]),
                        )).toList(),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(() {
                        final isSelectedForCompare = Get.find<OffersComparisonController>().comparisonList.contains(widget.offer);
                        return IconButton.filled(
                          onPressed: () => Get.find<OffersComparisonController>().toggleCompare(widget.offer),
                          icon: Icon(isSelectedForCompare ? Icons.check_circle : Icons.compare_arrows_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: isSelectedForCompare ? Colors.green : Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                          ),
                          tooltip: "إضافة للمقارنة",
                        );
                      }),
                      ElevatedButton(
                        onPressed: () => Get.find<OffersComparisonController>().selectOffer(widget.offer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("اختيار العرض"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}