import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../app/data/models/insurance_type_model.dart';
import '../../../app/data/models/user_policy_model.dart';
import '../../../app/data/models/notification_model.dart';

import '../controllers/home_controller.dart';
import '../../../app/routes/app_routes.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
              child: CircularProgressIndicator(color: colorScheme.primary)),
        );
      }

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Obx(() => UserAccountsDrawerHeader(
                    accountName: Text(
                      controller.currentUser?['displayName'] ?? 'مستخدم',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(color: Colors.white),
                    ),
                    accountEmail: Text(
                      controller.currentUser?['email'] ??
                          'لا يوجد بريد إلكتروني',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondary,
                      backgroundImage: controller.currentUser?['photoURL'] !=
                              null
                          ? NetworkImage(controller.currentUser!['photoURL']!)
                          : null,
                      child: controller.currentUser?['photoURL'] == null
                          ? Icon(Icons.person,
                              size: 50, color: theme.colorScheme.onSecondary)
                          : null,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, const Color(0xFF8367C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  )),
              Obx(() => SwitchListTile(
                    title: const Text('الوضع الليلي'),
                    secondary: Icon(
                        Get.isDarkMode
                            ? Icons.nightlight_round
                            : Icons.wb_sunny_rounded,
                        color: theme.colorScheme.onSurface),
                    value: Get.isDarkMode,
                    onChanged: (value) {
                      controller.toggleTheme();
                    },
                  )),
              const Divider(),
              ListTile(
                leading: Icon(Icons.home_outlined,
                    color: theme.colorScheme.onSurface),
                title: Text('الرئيسية',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onSurface)),
                onTap: () {
                  Get.back();
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_outlined,
                    color: theme.colorScheme.onSurface),
                title: Text('الإعدادات',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onSurface)),
                onTap: () {
                  Get.back();
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline,
                    color: theme.colorScheme.onSurface),
                title: Text('حول التطبيق',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onSurface)),
                onTap: () {
                  Get.back();
                },
              ),
              const Expanded(child: SizedBox()),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('تسجيل الخروج',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Get.back();
                  controller.logout();
                },
              ),
            ],
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: theme.appBarTheme.backgroundColor,
              elevation: theme.appBarTheme.elevation,
              title: Obx(() => Text("أهلاً بك، ${controller.userName.value}",
                  style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.appBarTheme.foregroundColor))),
              actions: [
                Obx(() => Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_outlined,
                              color: theme.appBarTheme.foregroundColor,
                              size: 28),
                          onPressed: controller.showNotificationsSheet,
                        ),
                        if (controller.notifications
                            .where((n) => !n.isRead)
                            .isNotEmpty)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 18, minHeight: 18),
                              child: Center(
                                child: Text(
                                  controller.notifications
                                      .where((n) => !n.isRead)
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),
                IconButton(
                  icon: Icon(Icons.logout,
                      color: theme.appBarTheme.foregroundColor),
                  onPressed: controller.logout,
                )
              ],
            ),

            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, const Color(0xFF8367C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("هل تبحث عن تأمين؟",
                          style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                          "احصل على أفضل العروض من شركات التأمين الرائدة في سوريا.",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.white.withOpacity(0.9))),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text("اطلب عرض سعر الآن"),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12)),
                      )
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(
                  begin: 0.1, duration: 600.ms, curve: Curves.easeOutCubic),
            ),

            // استخدام _buildSectionHeaderContent مباشرة هنا لأنه داخل SliverToBoxAdapter
            SliverToBoxAdapter(
              child: _buildSectionHeaderContent(context, "إجراءات سريعة"),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildQuickActionCard(
                        context, Icons.request_quote_outlined, "طلب عرض سعر"),
                    _buildQuickActionCard(
                        context, Icons.autorenew_outlined, "تجديد بوليصة"),
                    _buildQuickActionCard(
                        context, Icons.sticky_note_2_outlined, "تقديم شكوى"),
                    _buildQuickActionCard(
                        context, Icons.help_outline, "المساعدة"),
                  ]
                      .animate(interval: 50.ms)
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.1, duration: 300.ms),
                ),
              ),
            ),

            Obx(() => controller.userPolicies.isNotEmpty
                ? SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // استخدام _buildSectionHeaderContent هنا
                        _buildSectionHeaderContent(
                            context, "بوالص التأمين الخاصة بك",
                            onViewAll: () {}),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: controller.userPolicies.length,
                            itemBuilder: (context, index) {
                              return _UserPolicyCard(
                                      policy: controller.userPolicies[index])
                                  .animate()
                                  .fadeIn(
                                      delay: (100 * index).ms, duration: 400.ms)
                                  .moveY(
                                      begin: 10,
                                      delay: (100 * index).ms,
                                      duration: 400.ms);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const SliverToBoxAdapter(child: SizedBox.shrink())),

            // استخدام _buildSectionHeaderContent مباشرة هنا
            SliverToBoxAdapter(
              child: _buildSectionHeaderContent(context, "اكتشف أنواع التأمين",
                  onViewAll: () {}),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.25,
                ),
                itemCount: controller.insuranceTypes.length,
                itemBuilder: (context, index) {
                  return _InsuranceTypeCard(
                          type: controller.insuranceTypes[index])
                      .animate()
                      .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                      .moveX(
                          begin: 20,
                          delay: (100 * index).ms,
                          duration: 400.ms,
                          curve: Curves.easeOut);
                },
              ),
            ),

            Obx(() => controller.featuredArticles.isNotEmpty
                ? SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // استخدام _buildSectionHeaderContent هنا
                        _buildSectionHeaderContent(
                            context, "أخبار ومقالات مميزة",
                            onViewAll: () {}),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: controller.featuredArticles.length,
                            itemBuilder: (context, index) {
                              return _ArticleCard(
                                      article:
                                          controller.featuredArticles[index])
                                  .animate()
                                  .fadeIn(
                                      delay: (100 * index).ms, duration: 400.ms)
                                  .moveY(
                                      begin: 10,
                                      delay: (100 * index).ms,
                                      duration: 400.ms);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const SliverToBoxAdapter(child: SizedBox.shrink())),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      );
    });
  }

  // تم تعديل هذه الدالة لتعيد Widget عادي (وليس SliverToBoxAdapter)
  Widget _buildSectionHeaderContent(BuildContext context, String title,
      {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (onViewAll != null)
            TextButton(onPressed: onViewAll, child: const Text("عرض الكل")),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.secondary.withOpacity(0.5),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: colorScheme.primary),
              const SizedBox(height: 8),
              Text(label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsuranceTypeCard extends StatelessWidget {
  final InsuranceType type;

  const _InsuranceTypeCard({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {

          Get.toNamed(Routes.COMPANY_LIST, arguments: type);

        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(type.icon,
                  size: 32, color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              Text(type.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserPolicyCard extends StatelessWidget {
  final UserPolicy policy;

  const _UserPolicyCard({Key? key, required this.policy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    switch (policy.status) {
      case PolicyStatus.active:
        statusColor = Colors.green;
        statusText = "فعّالة";
        break;
      case PolicyStatus.pending:
        statusColor = Colors.orange;
        statusText = "قيد المراجعة";
        break;
      case PolicyStatus.expired:
        statusColor = Colors.red;
        statusText = "منتهية";
        break;
    }

    final theme = Theme.of(context);
    return SizedBox(
      width: 250,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Card(
          margin: const EdgeInsets.only(right: 16),
          elevation: 2,
          shadowColor: Colors.grey.withOpacity(0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          color: theme.colorScheme.primary, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(policy.policyName,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const Spacer(),
                  Text(policy.companyName,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(statusText,
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;

  const _ArticleCard({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 280,
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        elevation: 3,
        shadowColor: Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                article.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported,
                      color: Colors.grey.shade400),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.readTime,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsSheetWidget extends StatelessWidget {
  final List<AppNotification> notifications;

  const NotificationsSheetWidget({Key? key, required this.notifications})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData _getIconForType(NotificationType type) {
      switch (type) {
        case NotificationType.offer:
          return Icons.local_offer;
        case NotificationType.status:
          return Icons.check_circle_outline;
        case NotificationType.alert:
          return Icons.warning_amber_rounded;
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("الإشعارات",
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(child: Text("لا توجد إشعارات حالياً."))
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          const Divider(indent: 70, height: 1),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.1),
                            child: Icon(_getIconForType(notification.type),
                                color: theme.colorScheme.primary),
                          ),
                          title: Text(notification.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: notification.isRead
                                      ? Colors.grey.shade600
                                      : Colors.black)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification.body,
                                  style: TextStyle(
                                      color: notification.isRead
                                          ? Colors.grey.shade500
                                          : Colors.black87)),
                              const SizedBox(height: 4),
                              Text(
                                  DateFormat.yMMMd('ar')
                                      .add_jm()
                                      .format(notification.timestamp),
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                          trailing: !notification.isRead
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
        );
      },
    );
  }
}
