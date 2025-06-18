import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:tamienk/app/routes/app_routes.dart';
import 'dart:ui' as ui;

import '../../../app/data/models/insurance_type_model.dart';
import '../../../app/data/models/user_policy_model.dart';
import '../../../app/data/models/notification_model.dart';

import '../controllers/home_controller.dart';
import '../../../app/routes/app_pages.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
        );
      }
      return Scaffold(
        backgroundColor: colorScheme.background, // استخدام لون الخلفية القياسي
        drawer: _buildAppDrawer(context),
        body: CustomScrollView(
          slivers: [
            _DynamicSliverHeader(controller: controller),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 16),
                  _buildHeroCard(context),
                  _buildSectionHeader(context, "إجراءات سريعة"),
                  _buildQuickActionsList(context),
                  _buildUserPoliciesSection(context),
                  _buildSectionHeader(context, "اكتشف أنواع التأمين", onViewAll: () {}),
                ],
              ),
            ),
            _buildInsuranceTypesGrid(context),
            SliverList(
              delegate: SliverChildListDelegate(
                  [
                    _buildFeaturedArticlesSection(context),
                    const SizedBox(height: 120), // مساحة للـ FAB
                  ]
              ),
            )
          ],
        ).animate().fadeIn(duration: 400.ms),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.request_quote_outlined),
          label: const Text("طلب عرض سعر"),
          elevation: 4,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ).animate().slideY(begin: 2, duration: 600.ms, delay: 500.ms, curve: Curves.easeOutCubic),
      );
    });
  }

  // ودجات بناء الأقسام (مع تحسينات طفيفة)
  Widget _buildHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [colorScheme.primary, const Color(0xFF5D54A4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("هل تبحث عن تأمين؟", style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("احصل على أفضل العروض من شركات التأمين الرائدة.", style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.9))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text("اكتشف العروض الآن"),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            )
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).moveY(begin: 20, curve: Curves.easeOut);
  }

  Widget _buildQuickActionsList(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildQuickActionCard(context, Icons.request_quote_outlined, "طلب عرض سعر"),
          _buildQuickActionCard(context, Icons.autorenew_outlined, "تجديد بوليصة"),
          _buildQuickActionCard(context, Icons.description_outlined, "مطالباتي"),
          _buildQuickActionCard(context, Icons.help_outline, "المساعدة"),
        ].animate(interval: 100.ms).fadeIn(duration: 400.ms).moveX(begin: 20, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildUserPoliciesSection(BuildContext context) {
    return Obx(() => controller.userPolicies.isNotEmpty
        ? Column(
      children: [
        _buildSectionHeader(context, "بوالص التأمين الخاصة بك", onViewAll: () {}),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.userPolicies.length,
            itemBuilder: (context, index) {
              return _UserPolicyCard(policy: controller.userPolicies[index])
                  .animate().fadeIn(delay: (100 * index).ms).moveX(begin: 20);
            },
          ),
        ),
      ],
    )
        : const SizedBox.shrink());
  }

  Widget _buildInsuranceTypesGrid(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: Obx(() => SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: controller.insuranceTypes.length,
        itemBuilder: (context, index) {
          return _InsuranceTypeCard(type: controller.insuranceTypes[index])
              .animate().fadeIn(delay: (50 * index).ms).scaleXY(begin: 0.9, curve: Curves.easeOut);
        },
      )),
    );
  }

  Widget _buildFeaturedArticlesSection(BuildContext context) {
    return Obx(() => controller.featuredArticles.isNotEmpty
        ? Column(
      children: [
        _buildSectionHeader(context, "أخبار ومقالات مميزة", onViewAll: () {}),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.featuredArticles.length,
            itemBuilder: (context, index) {
              return _ArticleCard(article: controller.featuredArticles[index])
                  .animate().fadeIn(delay: (100 * index).ms).moveX(begin: 20);
            },
          ),
        ),
      ],
    )
        : const SizedBox.shrink());
  }

  Widget _buildSectionHeader(BuildContext context, String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          if (onViewAll != null)
            TextButton(onPressed: onViewAll, child: const Text("عرض الكل")),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      width: 100,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(icon, size: 28, color: colorScheme.onSecondaryContainer),
            ),
            const SizedBox(height: 12),
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Drawer _buildAppDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Drawer(
      child: Column(
        children: [
          Obx(() => UserAccountsDrawerHeader(
            accountName: Text(controller.currentUser?['displayName'] ?? 'مستخدم', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            accountEmail: Text(controller.currentUser?['email'] ?? 'لا يوجد بريد إلكتروني', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
            currentAccountPicture: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              backgroundImage: controller.currentUser?['photoURL'] != null ? NetworkImage(controller.currentUser!['photoURL']!) : null,
              child: controller.currentUser?['photoURL'] == null ? Icon(Icons.person, size: 40, color: colorScheme.primary) : null,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, const Color(0xFF5D54A4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          )),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(leading: const Icon(Icons.home_filled), title: const Text('الرئيسية'), selected: true, onTap: () => Get.back()),
                ListTile(leading: const Icon(Icons.person_outline), title: const Text('الملف الشخصي'), onTap: () {}),
                ListTile(leading: const Icon(Icons.shield_outlined), title: const Text('بوالص التأمين'), onTap: () {}),
                ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('الإعدادات'), onTap: () {}),
                Obx(() => SwitchListTile(
                  title: const Text('الوضع الليلي'),
                  secondary: Icon(Get.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded),
                  value: Get.isDarkMode,
                  onChanged: (value) => controller.toggleTheme(),
                )),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Get.back();
              controller.logout();
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// وُدجات البطاقات (لا تغيير هنا)
class _InsuranceTypeCard extends StatelessWidget {
  final InsuranceType type;
  const _InsuranceTypeCard({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => Get.toNamed(Routes.QUOTE_REQUEST, arguments: type),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(type.icon, size: 28, color: colorScheme.onPrimaryContainer),
              ),
              const Spacer(),
              Text(type.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(type.description, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserPolicyCard extends StatelessWidget {
  final UserPolicy policy;
  const _UserPolicyCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = policy.status.display;

    return SizedBox(
      width: 280,
      child: Card(
        elevation: 4,
        shadowColor: colorScheme.shadow.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: colorScheme.primary, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(policy.policyName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          Text(policy.companyName, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (status['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(status['text'], style: TextStyle(color: status['color'], fontWeight: FontWeight.bold, fontSize: 12)),
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

class _ArticleCard extends StatelessWidget {
  final Article article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 3,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                article.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    height: 120, color: Colors.grey.shade200,
                    alignment: Alignment.center, child: Icon(Icons.image_not_supported, color: Colors.grey.shade400)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(article.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text(article.readTime, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === الكود المصحح لشريط التطبيقات ===
class _DynamicSliverHeader extends StatelessWidget {
  final HomeController controller;
  const _DynamicSliverHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _DynamicSliverHeaderDelegate(
        minHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
        maxHeight: 200,
        child: _buildHeaderContent(context),
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final top = constraints.biggest.height;
        final minExtent = kToolbarHeight + MediaQuery.of(context).padding.top;
        final maxExtent = 200.0;

        // --- التصحيح الرئيسي هنا ---
        // حساب `progress` بشكل آمن باستخدام `clamp`
        final progress = ((top - minExtent) / (maxExtent - minExtent)).clamp(0.0, 1.0);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, const Color(0xFF5D54A4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect( // استخدام ClipRRect لتطبيق الفلتر
            child: BackdropFilter( // إضافة تأثير البلور
              filter: ui.ImageFilter.blur(sigmaX: 4 * (1 - progress), sigmaY: 4 * (1 - progress)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    bottom: ui.lerpDouble(15, 60, progress),
                    right: 20,
                    child: Opacity(
                      opacity: progress,
                      child: Text(
                        "أهلاً بعودتك،",
                        style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white.withOpacity(0.8)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    right: ui.lerpDouble(80, 20, progress),
                    child: Transform.scale(
                      scale: ui.lerpDouble(1.0, 1.2, progress),
                      alignment: Alignment.bottomRight,
                      child: Obx(() => Text(
                        controller.userName.value,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: ui.lerpDouble(20, 28, progress),
                        ),
                      )),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 5,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 5,
                    right: 10,
                    child: Obx(() => Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                          onPressed: controller.showNotificationsSheet,
                        ),
                        if (controller.notifications.where((n) => !n.isRead).isNotEmpty)
                          Positioned(
                            top: 8, right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                              child: Center(
                                child: Text(
                                  controller.notifications.where((n) => !n.isRead).length.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DynamicSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _DynamicSliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }
  @override
  bool shouldRebuild(_DynamicSliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

extension PolicyStatusExtension on PolicyStatus {
  Map<String, dynamic> get display {
    switch (this) {
      case PolicyStatus.active:
        return {'text': 'فعّالة', 'color': Colors.green.shade600};
      case PolicyStatus.pending:
        return {'text': 'قيد المراجعة', 'color': Colors.orange.shade700};
      case PolicyStatus.expired:
        return {'text': 'منتهية', 'color': Colors.red.shade700};
    }
  }
}

// الكود المضاف مسبقاً (لا تغيير هنا)
class NotificationsSheetWidget extends StatelessWidget {
  final List<AppNotification> notifications;
  const NotificationsSheetWidget({Key? key, required this.notifications}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData _getIconForType(NotificationType type) {
      switch (type) {
        case NotificationType.offer: return Icons.local_offer_rounded;
        case NotificationType.status: return Icons.check_circle_outline_rounded;
        case NotificationType.alert: return Icons.warning_amber_rounded;
      }
    }
    return DraggableScrollableSheet(
      initialChildSize: 0.6, minChildSize: 0.3, maxChildSize: 0.9, expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("الإشعارات", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text("لا توجد إشعارات حالياً.", style: theme.textTheme.titleMedium),
                      ],
                    ))
                    : ListView.separated(
                  controller: scrollController,
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Divider(indent: 72, height: 1),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final isUnread = !notification.isRead;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        child: Icon(_getIconForType(notification.type), color: theme.primaryColor),
                      ),
                      title: Text(
                        notification.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            color: isUnread ? theme.textTheme.bodyLarge?.color : Colors.grey.shade600
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notification.body, style: TextStyle(color: isUnread ? Colors.grey.shade700 : Colors.grey.shade500)),
                          const SizedBox(height: 6),
                          Text(DateFormat.yMMMd('ar').add_jm().format(notification.timestamp), style: theme.textTheme.bodySmall),
                        ],
                      ),
                      trailing: isUnread
                          ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle))
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}