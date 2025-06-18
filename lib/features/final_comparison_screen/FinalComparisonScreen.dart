// presentation/modules/offers_comparison/screens/final_comparison_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../app/data/models/insurance_offer_model.dart';
import 'FinalComparisoncontroller.dart';

class FinalComparisonScreen extends GetView<FinalComparisonController> {
  const FinalComparisonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("المقارنة النهائية", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF0F3460)]
                : [colorScheme.primary, colorScheme.primary.withBlue(200).withOpacity(0.8)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.8,

              ),
            ),
            SafeArea(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Lottie.asset( // تأكد من وجود هذا الملف
                      'assets/animations/loading_animation.json',
                      width: 150, height: 150,
                    ),
                  );
                }
                if (controller.allOffers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset( // تأكد من وجود هذا الملف
                          'assets/animations/empty_state.json',
                          width: 200, height: 200,
                        ),
                        const SizedBox(height: 20),
                        const Text("لا توجد عروض للمقارنة!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }
                final List<InsuranceOffer> offersToCompare = Get.arguments;

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: offersToCompare.length,
                  itemBuilder: (context, index) {
                    final offer = offersToCompare[index];
                    return _SmartComparisonCard(offer: offer)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: (150 * index).ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutBack);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartComparisonCard extends StatefulWidget {
  final InsuranceOffer offer;
  const _SmartComparisonCard({Key? key, required this.offer}) : super(key: key);

  @override
  State<_SmartComparisonCard> createState() => _SmartComparisonCardState();
}

class _SmartComparisonCardState extends State<_SmartComparisonCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildTopSection(),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: ConstrainedBox(
                    constraints: _isExpanded ? const BoxConstraints() : const BoxConstraints(maxHeight: 0.0),
                    child: _buildDetailsSection(),
                  ),
                ),
                _buildExpandToggle(),
              ],
            ),
          ),
        ),
      ),
    ).animate(target: widget.offer.isBestValue ? 1 : 0).shimmer(
      duration: 1800.ms,
      color: Colors.amber.withOpacity(0.3),
      blendMode: BlendMode.srcOver,
    );
  }

  Widget _buildTopSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatCurrency = NumberFormat.currency(locale: 'ar_SY', symbol: ' ل.س', decimalDigits: 0);

    return InkWell(
      onTap: _toggleExpanded,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: widget.offer.isBestValue ? Border(left: BorderSide(color: Colors.amber.shade600, width: 6)) : null,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    widget.offer.companyLogoUrl,
                    height: 60, width: 60, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 60, width: 60,
                      decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
                      child: Icon(Icons.business_rounded, color: Colors.grey.shade600, size: 35),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.offer.companyName,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
                      ),
                      if (widget.offer.isBestValue)
                        Text(
                          "العرض الأفضل قيمة!",
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.amber.shade800, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                Text(
                  formatCurrency.format(widget.offer.annualPrice),
                  style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Get.find<FinalComparisonController>().chooseOffer(widget.offer),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
              label: const Text("اختيار هذا العرض", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = Get.find<FinalComparisonController>();
    final radarStats = controller.getOfferRadarStats(widget.offer);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("التقييمات الذكية", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          _buildPowerBar("السعر", radarStats['السعر'] ?? 0, Colors.greenAccent.shade400),
          _buildPowerBar("التغطية", radarStats['التغطية'] ?? 0, Colors.blueAccent.shade400),
          _buildPowerBar("القيمة", radarStats['القيمة'] ?? 0, Colors.deepPurpleAccent.shade400),
          const Divider(height: 35, thickness: 1, color: Colors.black12),
          Text("التغطيات المشمولة", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          ...widget.offer.coverageDetails.map((detail) => _buildCoverageListItem(detail, colorScheme)).toList(),
        ],
      ),
    );
  }

  Widget _buildExpandToggle() {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: InkWell(
        onTap: _toggleExpanded,
        child: Container(
          height: 45,
          child: Center(
            child: RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPowerBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: Get.theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value / 10,
                minHeight: 18,
                backgroundColor: color.withOpacity(0.25),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${value.toInt()}/10', style: Get.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildCoverageListItem(String detail, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(detail, style: Get.theme.textTheme.bodyLarge?.copyWith(color: Get.theme.colorScheme.onSurface.withOpacity(0.8)))),
        ],
      ),
    );
  }
}