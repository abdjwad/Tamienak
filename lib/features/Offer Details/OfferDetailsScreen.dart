// presentation/modules/offer_details/screens/offer_details_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'OfferDetailsController.dart';


class OfferDetailsScreen extends GetView<OfferDetailsController> {
  const OfferDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_outlined)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            // الخلفية الديناميكية
            _buildAnimatedBackground(),
            // المحتوى
            _buildContent(context),
          ],
        );
      }),
      bottomNavigationBar: _buildApplyButton(),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            controller.dominantColor.value.withOpacity(0.6),
            Colors.black,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                controller.offer.companyLogoUrl,
                width: 400,
                height: 400,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // --- رأس الصفحة البطل (Hero Section) ---
        SliverToBoxAdapter(
          child: _buildHeaderSection(),
        ),
        // --- جسم الصفحة (بطاقات المعلومات) ---
        SliverList(
          delegate: SliverChildListDelegate(
            [
              _buildSection(
                title: "لماذا تختار هذا العرض؟",
                child: _buildWhyChooseUs(),
              ),
              _buildSection(
                title: "أبرز التغطيات",
                child: _buildCoverageHighlights(),
              ),
              _buildSection(
                title: "التقييمات والآراء",
                child: _buildReviewsSection(),
              ),
              const SizedBox(height: 120), // مساحة للزر العائم
            ]
                .animate(interval: 100.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    final theme = Get.theme;
    final formatCurrency = NumberFormat.currency(locale: 'ar_SY', symbol: 'ل.س', decimalDigits: 0);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
                controller.offer.companyLogoUrl,
                height: 80,
                errorBuilder: (c,e,s) => const SizedBox.shrink()
            ).animate().slideX(begin: -0.5).fadeIn(),
            const SizedBox(height: 16),
            Text(
              "تأمين شامل لسيارتك مع ${controller.offer.companyName}", // مثال لعنوان جذاب
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ).animate(delay: 200.ms).slideX(begin: -0.5).fadeIn(),
            const SizedBox(height: 12),
            Text(
              "ابتداءً من",
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            Text(
              formatCurrency.format(controller.offer.annualPrice),
              style: theme.textTheme.displayMedium?.copyWith(
                color: controller.vibrantColor.value,
                fontWeight: FontWeight.w900,
              ),
            ).animate(delay: 400.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Get.theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildWhyChooseUs() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _FeatureChip(icon: Icons.support_agent, label: "خدمة 24/7"),
        _FeatureChip(icon: Icons.verified, label: "شركة موثوقة"),
        _FeatureChip(icon: Icons.speed, label: "موافقات سريعة"),
      ],
    );
  }

  Widget _buildCoverageHighlights() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.offer.coverageDetails.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemBuilder: (context, index) {
        final detail = controller.offer.coverageDetails[index];
        return _GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: controller.vibrantColor.value, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(detail, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsSection() {
    final theme = Get.theme;
    return _GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Column(
            children: [
              Text("4.8", style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (i) => Icon(i < 4 ? Icons.star_rounded : Icons.star_half_rounded, color: Colors.amber, size: 18)),
              ),
              const Text("من 250 تقييم", style: TextStyle(color: Colors.white70)),
            ],
          ),
          const VerticalDivider(width: 32, thickness: 1, color: Colors.white24),
          const Expanded(
            child: Text(
              '"خدمة ممتازة وسرعة في الاستجابة. أوصي بهم بشدة!"',
              style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: Get.mediaQuery.padding.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
        ],
      ),
      child: Obx(() => ElevatedButton.icon(
        icon: const Icon(Icons.check_circle_outline),
        label: const Text("التقديم على هذا العرض"),
        onPressed: controller.applyForOffer,
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.vibrantColor.value,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )),
    ).animate().slideY(begin: 1, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

// === ويدجتس مساعدة جديدة للتصميم ===

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _GlassCard({Key? key, required this.child, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: padding ?? const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}