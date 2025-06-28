import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../app/data/models/insurance_type_model.dart';
import '../../../app/data/models/user_policy_model.dart';
import '../../../app/data/models/notification_model.dart';
import '../controllers/home_controller.dart';
import '../../../app/routes/app_routes.dart';

// يمكن استيراد هذا من نفسه إذا كان في نفس الملف
import 'home_screen.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // للسماح للخلفية بالظهور خلف الهيدر
      drawer: _buildAppDrawer(context),
      body: Stack(
        children: [
          // NEW: خلفية الشفق القطبي الحية والديناميكية
          const _DynamicAuroraBackground(),
          Obx(() {
            if (controller.isLoading.value) {
              // أثناء التحميل، نعرض مؤشر تحميل ناعم فوق الخلفية الجميلة
              return const Center(child: CircularProgressIndicator(color: Colors.white70));
            }
            // عند انتهاء التحميل، نعرض المحتوى
            return CustomScrollView(
              slivers: [
                _DynamicSliverHeader(controller: controller),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, "بوالص التأمين الخاصة بك"),
                        _buildUserPoliciesSection(context),
                        _buildSectionHeader(context, "اكتشف خدماتنا"),
                      ],
                    ),
                  ),
                ),
                _buildInsuranceTypesGrid(context),
                SliverToBoxAdapter(
                  child: Container(
                    color: Theme.of(context).colorScheme.background,
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildFeaturedArticlesSection(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                      color: Theme.of(context).colorScheme.background,
                      height: 120 // مساحة آمنة للـ Floating Action Button
                  ),
                )
              ],
            ).animate().fadeIn(duration: 900.ms);
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // أضف الإجراء المطلوب هنا
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text("طلب تأمين جديد"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ).animate(delay: GetNumUtils(1).seconds)
          .slideY(begin: 2, end: 0, curve: Curves.easeInOutCubic, duration: 600.ms)
          .saturate(delay: GetNumUtils(1).seconds, duration: 1500.ms),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          if (onViewAll != null)
            TextButton(
                onPressed: onViewAll,
                child: const Text("عرض الكل"),
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary)
            ),
        ],
      ),
    );
  }

  Widget _buildUserPoliciesSection(BuildContext context) {
    return Obx(() => controller.userPolicies.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none, // للسماح للظل بالظهور خارج الحدود
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.userPolicies.length,
        itemBuilder: (context, index) {
          return _UserPolicyCard(policy: controller.userPolicies[index])
              .animate().fadeIn(delay: (200 * index).ms)
              .moveX(begin: 30, duration: 600.ms, curve: Curves.easeOutCubic);
        },
      ),
    ));
  }

  Widget _buildInsuranceTypesGrid(BuildContext context) {
    final types = controller.insuranceTypes;
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: types.length,
          itemBuilder: (context, index) {
            return _InsuranceTypeCard(type: types[index])
                .animate().fadeIn(delay: (100 * index).ms)
                .scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOutBack);
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedArticlesSection(BuildContext context) {
    return Obx(() => controller.featuredArticles.isEmpty
        ? const SizedBox.shrink()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, "آخر الأخبار", onViewAll: () {}),
        ...controller.featuredArticles.map((article) =>
            _ArticleListTile(article: article)
                .animate(delay: (100 * controller.featuredArticles.indexOf(article)).ms)
                .fadeIn(duration: 600.ms).moveX(begin: -20, curve: Curves.easeOutCubic)
        ).toList(),
      ],
    ));
  }

  Drawer _buildAppDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Drawer(
      backgroundColor: colorScheme.surface.withOpacity(0.9), // شبه شفاف
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10), // تأثير زجاجي
        child: Column(
          children: [
            Obx(() => UserAccountsDrawerHeader(
              accountName: Text(controller.currentUser?['displayName'] ?? 'مستخدم',
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, shadows: [const Shadow(blurRadius: 5)])),
              accountEmail: Text(controller.currentUser?['email'] ?? '',
                  style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70, shadows: [const Shadow(blurRadius: 3)])),
              currentAccountPicture: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white24,
                backgroundImage: controller.currentUser?['photoURL'] != null ? NetworkImage(controller.currentUser!['photoURL']!) : null,
                child: controller.currentUser?['photoURL'] == null ? Icon(Icons.person_rounded, size: 40, color: colorScheme.onPrimary) : null,
              ),
              decoration: const BoxDecoration(color: Colors.transparent),
            )),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(leading: const Icon(Icons.home_filled), title: const Text('الرئيسية'), selected: true, onTap: () => Get.back()),
                  ListTile(leading: const Icon(Icons.person_outline), title: const Text('الملف الشخصي'), onTap: () {}),
                  ListTile(leading: const Icon(Icons.shield_outlined), title: const Text('بوالص التأمين'), onTap: () {}),
                  ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('الإعدادات'), onTap: () {}),
                  const Divider(),
                  Obx(() => SwitchListTile(
                    title: const Text('الوضع الليلي'),
                    secondary: Icon(Get.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
                    value: Get.isDarkMode,
                    onChanged: (value) => controller.toggleTheme(),
                  )),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Get.back(); // إغلاق القائمة أولاً
                controller.logout();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ===================================
// === NEW & REFINED WIDGETS ===
// ===================================

class _DynamicAuroraBackground extends StatelessWidget {
  const _DynamicAuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
      child: Stack(
        children: [
          ...List.generate(2, (index) => Positioned.fill(
            child: SvgPicture.asset('assets/svg/aurora_bg.svg', fit: BoxFit.cover,)
                .animate(
                onPlay: (controller) => controller.repeat(),
                delay: GetNumUtils(1 * index).seconds)
                .rotate(duration: GetNumUtils(45).seconds, begin: index * 0.1, end: index * 0.1 + 0.2)
                .scaleXY(duration: GetNumUtils(30).seconds, begin: 1.0, end: 1.5, curve: Curves.easeInOut)
                .then()
                .scaleXY(duration: GetNumUtils(30).seconds, begin: 1.5, end: 1.0, curve: Curves.easeInOut),
          )
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          )
        ],
      ),
    );
  }
}

class _DynamicSliverHeader extends StatelessWidget {
  final HomeController controller;
  const _DynamicSliverHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _DynamicSliverHeaderDelegate(
        minHeight: 120, // الارتفاع الأدنى (شريط التطبيقات)
        maxHeight: 280, // الارتفاع الأقصى
        child: _buildHeaderContent(context),
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final top = constraints.biggest.height;
        final minExtent = 120.0;
        final maxExtent = 280.0;
        final progress = ((top - minExtent) / (maxExtent - minExtent)).clamp(0.0, 1.0);

        return ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 15 * (1-progress), sigmaY: 15 * (1-progress)),
            child: Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1 * (1-progress)),
                  border: Border(bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2 * (1 - progress)),
                    width: 1.5,
                  ))
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // محتوى الهيدر (النص)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: Offset(0, 50 * (1-progress)),
                          child: Opacity(
                            opacity: (progress * 2 - 0.5).clamp(0.0, 1.0),
                            child: Text("أهلاً بعودتك،",
                                style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white70)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Transform.scale(
                          scale: ui.lerpDouble(0.9, 1.0, progress),
                          alignment: Alignment.bottomRight,
                          child: Text(controller.userName.value,
                            style: theme.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.1
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      top: MediaQuery.of(context).padding.top + 5,
                      left: 10,
                      child: IconButton(
                          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
                          onPressed: () => Scaffold.of(context).openDrawer())
                  ),
                  Positioned(
                      top: MediaQuery.of(context).padding.top + 5,
                      right: 10,
                      child: Obx(() {
                        final unreadCount = controller.notifications.where((n) => !n.isRead).length;
                        return Badge(
                            isLabelVisible: unreadCount > 0,
                            label: Text(unreadCount.toString()),
                            child: IconButton(
                                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 30),
                                onPressed: controller.showNotificationsSheet)
                        );
                      }
                      )
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

class _UserPolicyCard extends StatefulWidget {
  final UserPolicy policy;
  const _UserPolicyCard({required this.policy});

  @override
  State<_UserPolicyCard> createState() => __UserPolicyCardState();
}

class __UserPolicyCardState extends State<_UserPolicyCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 300.ms);
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset = Offset((_offset.dx + details.delta.dx).clamp(-15, 15), (_offset.dy + details.delta.dy).clamp(-15, 15));
      _controller.value = (_offset.distance / 15).clamp(0, 1); // التحكم بالأنيميشن عبر السحب
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() { _offset = Offset.zero; });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.policy.status.display;

    return GestureDetector(
      onPanStart: (_) => _controller.forward(),
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // منظور ثلاثي الأبعاد
            ..rotateY(_offset.dx * 0.008 * _animation.value)
            ..rotateX(-_offset.dy * 0.008 * _animation.value);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: Container(
              width: 260,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (status['color'] as Color).withOpacity(0.5 * _animation.value),
                    blurRadius: 15 * _animation.value,
                    spreadRadius: -2,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.2))
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                                radius: 20,
                                backgroundColor: (status['color'] as Color).withOpacity(0.3),
                                child: Icon(Icons.shield_outlined, color: status['color'], size: 20)),
                            const SizedBox(width: 12),
                            Text(widget.policy.companyName, style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70))
                          ],
                        ),
                        const Spacer(),
                        Text(widget.policy.policyName, style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, height: 1.2)),
                        const SizedBox(height: 4),
                        Text(status['text'], style: theme.textTheme.bodyMedium?.copyWith(color: status['color'])),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InsuranceTypeCard extends StatelessWidget {
  final InsuranceType type;
  const _InsuranceTypeCard({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: Icon(type.icon, size: 32, color: theme.colorScheme.primary)),
              Text(type.name, style: theme.textTheme.titleLarge?.copyWith(height: 1.2, fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleListTile extends StatelessWidget {
  final Article article;
  const _ArticleListTile({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                article.imageUrl, width: 80, height: 80, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                    width: 80, height: 80, color: theme.colorScheme.surfaceVariant,
                    child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(article.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(article.readTime, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}

// ===============================================
// === FULL WIDGETS (SliverDelegate, PolicyStatus, Notifications) ===
// ===============================================

class _DynamicSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _DynamicSliverHeaderDelegate({ required this.minHeight, required this.maxHeight, required this.child });

  @override double get minExtent => minHeight;
  @override double get maxExtent => maxHeight;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox.expand(child: child);
  @override bool shouldRebuild(_DynamicSliverHeaderDelegate old) => maxHeight != old.maxHeight || minHeight != old.minHeight || child != old.child;
}

extension PolicyStatusExtension on PolicyStatus {
  Map<String, dynamic> get display {
    switch (this) {
      case PolicyStatus.active:
        return {'text': 'فعّالة', 'color': Colors.greenAccent.shade400};
      case PolicyStatus.pending:
        return {'text': 'قيد المراجعة', 'color': Colors.amberAccent.shade400};
      case PolicyStatus.expired:
        return {'text': 'منتهية', 'color': Colors.redAccent.shade400};
    }
  }
}

class NotificationsSheetWidget extends StatelessWidget {
  final List<AppNotification> notifications;
  const NotificationsSheetWidget({Key? key, required this.notifications}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData getIconForType(NotificationType type) {
      switch (type) {
        case NotificationType.offer: return Icons.local_offer_rounded;
        case NotificationType.status: return Icons.check_circle_outline_rounded;
        case NotificationType.alert: return Icons.warning_amber_rounded;
      }
    }

    Color getColorForType(NotificationType type) {
      switch (type) {
        case NotificationType.offer: return Colors.blue.shade400;
        case NotificationType.status: return Colors.green.shade400;
        case NotificationType.alert: return Colors.orange.shade400;
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6, minChildSize: 0.3, maxChildSize: 0.9, expand: false,
      builder: (_, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(0.8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Container(
                        width: 40, height: 5,
                        decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(12))),
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
                        final iconColor = getColorForType(notification.type);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: iconColor.withOpacity(0.2),
                            child: Icon(getIconForType(notification.type), color: iconColor),
                          ),
                          title: Text(notification.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notification.body, style: TextStyle(color: isUnread ? theme.textTheme.bodyMedium?.color?.withOpacity(0.8) : Colors.grey.shade500)),
                              const SizedBox(height: 6),
                              Text(DateFormat.yMMMd('ar').add_jm().format(notification.timestamp), style: theme.textTheme.bodySmall),
                            ],
                          ),
                          trailing: isUnread
                              ? Container(width: 10, height: 10,
                              decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle))
                              : null,
                        );
                      },
                    ),
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