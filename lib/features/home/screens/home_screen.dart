// مسار الملف: lib/features/home/screens/home_screen.dart

import 'dart:ui'; // ضروري لتأثير الضبابية
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart' show Slidable, ActionPane, StretchMotion, BehindMotion, SlidableAction;
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../app/data/models/article_model.dart';
import '../../../app/data/models/insurance_type_model.dart';
import '../../../app/data/models/notification_model.dart';
import '../../../app/data/models/partner_company_model.dart';
import '../../../app/data/models/profile_task_model.dart';
import '../../../app/data/models/user_policy_model.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingScreen(context);
      }
      return Scaffold(
        drawer: _buildAppDrawer(context),
        // استخدام Stack لوضع الزر العائم فوق كل شيء
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _PolishedSliverHeader(controller: controller),
                _buildProfileCompletionSection(context),
                _buildUserPoliciesSection(context),
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                      context, "ابدأ طلب تأمين جديد", "اختر نوع التأمين الذي تحتاجه"),
                ),
                _buildInsuranceTypesGrid(context),
                _buildPartnerCompaniesSection(context),
                _buildFeaturedArticlesSection(context),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ).animate().fadeIn(duration: 600.ms).saturate(delay: 200.ms),
            // بناء الزر العائم التفاعلي الجديد
            _buildSpeedDialFab(context),
          ],
        ),
      );
    });
  }

  // ============== [ ويدجتس البناء الرئيسية ] ==============

  Widget _buildProfileCompletionSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverToBoxAdapter(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        elevation: 4,
        shadowColor: colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Obx(() => CircularPercentIndicator(
                    radius: 40.0,
                    lineWidth: 8.0,
                    percent: controller.profileCompletionPercentage.value,
                    center: Text(
                      "${(controller.profileCompletionPercentage.value * 100).toInt()}%",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: colorScheme.primary,
                    backgroundColor: colorScheme.primary.withOpacity(0.2),
                    animation: true,
                    animationDuration: 800,
                  )),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("مستوى الأمان", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                          controller.profileCompletionPercentage.value > 0.7
                              ? "رائع! ملفك التأميني شبه مكتمل."
                              : "أكمل ملفك لتحصل على أفضل حماية.",
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, thickness: 1),
              ...controller.profileTasks.map((task) => _ProfileTaskItem(task: task)).toList(),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildUserPoliciesSection(BuildContext context) {
    return Obx(() => controller.userPolicies.isEmpty
        ? const SliverToBoxAdapter(child: SizedBox.shrink())
        : SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              context, "بوالص التأمين الخاصة بك", "نظرة سريعة على وثائقك الفعالة",
              onViewAll: () {}),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.userPolicies.length,
              itemBuilder: (context, index) {
                return _UserPolicyCard(
                    policy: controller.userPolicies[index])
                    .animate()
                    .fadeIn(delay: (150 * index).ms)
                    .moveX(
                    begin: 30,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic);
              },
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildInsuranceTypesGrid(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      sliver: Obx(() => SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => _InsuranceTypeCard(
              type: controller.insuranceTypes[index])
              .animate()
              .fadeIn(delay: (100 * index).ms)
              .scale(
              begin: const Offset(0.8, 0.8),
              curve: Curves.easeOutBack),
          childCount: controller.insuranceTypes.length,
        ),
      )),
    );
  }

  Widget _buildPartnerCompaniesSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            "شركاؤنا في النجاح",
            "نخبة من أفضل شركات التأمين",
            onViewAll: () => Get.toNamed(Routes.COMPANY_LIST),
          ),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.partnerCompanies.length,
              itemBuilder: (context, index) {
                return _PartnerCompanyLogo(
                    company: controller.partnerCompanies[index])
                    .animate()
                    .fadeIn(delay: (100 * index).ms)
                    .slideX(begin: 0.5, curve: Curves.easeOutCubic);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedArticlesSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          _buildSectionHeader(
              context, "مقالات ومستجدات", "ابق على اطلاع بآخر أخبار التأمين"),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.featuredArticles.length,
              itemBuilder: (context, index) =>
                  _ArticleCard(article: controller.featuredArticles[index])
                      .animate()
                      .fadeIn(delay: (150 * index).ms)
                      .moveX(begin: 30),
            ),
          ),
        ],
      ),
    );
  }

  // ============== [ ويدجتس مساعدة وهيكلية ] ==============

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle,
      {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey.shade600)),
                ]
              ],
            ),
          ),
          if (onViewAll != null)
            TextButton(
                onPressed: onViewAll,
                child: const Text("عرض الكل"),
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }

// في ملف home_screen.dart

  Drawer _buildAppDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // هذا هو كائن بناء العنصر الواحد في القائمة، لتجنب تكرار الكود
    Widget _buildDrawerItem({
      required IconData icon,
      required String text,
      required bool isSelected,
      required VoidCallback onTap,
      Color? color,
    }) {
      return AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? colorScheme.primary.withOpacity(0.15) : Colors.transparent,
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            icon,
            color: isSelected ? colorScheme.primary : (color ?? theme.iconTheme.color),
          ),
          title: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? colorScheme.primary : (color ?? theme.textTheme.bodyLarge?.color),
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    return Drawer(
      child: Stack(
        children: [
          // 1. الخلفية المتدرجة والضبابية
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.surface.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 2. المحتوى
          SafeArea(
            child: Column(
              children: [
                // 3. رأس القائمة بتصميم جديد
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: colorScheme.surface,
                        child: CircleAvatar(
                          radius: 42,
                          backgroundImage: controller.currentUser?['photoURL'] != null
                              ? NetworkImage(controller.currentUser!['photoURL']!)
                              : null,
                          child: controller.currentUser?['photoURL'] == null
                              ? Icon(Icons.person, size: 50, color: colorScheme.primary)
                              : null,
                        ),
                      ).animate().scale(delay: 100.ms, duration: 400.ms),
                      const SizedBox(height: 12),
                      Text(
                        controller.currentUser?['displayName'] ?? 'مستخدم',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        controller.currentUser?['email'] ?? 'لا يوجد بريد إلكتروني',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),

                // 4. عناصر القائمة الرئيسية
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        icon: Icons.home_rounded,
                        text: 'الرئيسية',
                        isSelected: true,
                        onTap: () => Get.back(),
                      ).animate().slideX(delay: 200.ms, duration: 300.ms, begin: -0.5),

                      _buildDrawerItem(
                        icon: Icons.person_2_rounded,
                        text: 'الملف الشخصي',
                        isSelected: false,
                        onTap: () {},
                      ).animate().slideX(delay: 250.ms, duration: 300.ms, begin: -0.5),

                      _buildDrawerItem(
                        icon: Icons.shield_rounded,
                        text: 'بوالص التأمين',
                        isSelected: false,
                        onTap: () {},
                      ).animate().slideX(delay: 300.ms, duration: 300.ms, begin: -0.5),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        child: Divider(),
                      ),

                      // 5. مفتاح الوضع الليلي بتصميم محسن
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SwitchListTile(
                          title: const Text('الوضع الليلي'),
                          secondary: Icon(
                            isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                            color: isDark ? Colors.yellow.shade700 : Colors.orange,
                          ),
                          value: isDark,
                          onChanged: (value) {
                            // تأكد من أن هذه الوظيفة موجودة في المتحكم الخاص بك
                            controller.toggleTheme();
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          tileColor: colorScheme.surfaceVariant.withOpacity(0.2),
                        ),
                      ).animate().slideX(delay: 350.ms, duration: 300.ms, begin: -0.5),

                    ],
                  ),
                ),

                // 6. عنصر تسجيل الخروج
                const Divider(height: 1),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  text: 'تسجيل الخروج',
                  isSelected: false,
                  color: Colors.redAccent,
                  onTap: () {
                    Get.back();
                    controller.logout();
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 20),
            Text("جاري تحميل البيانات...",
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ).animate().fadeIn(),
      ),
    );
  }

  // ============== [ الزر العائم التفاعلي الجديد ] ==============

  Widget _buildSpeedDialFab(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() => Stack(
      alignment: Alignment.bottomLeft,
      children: [
        // الخلفية المعتمة التي تظهر عند فتح القائمة
        if (controller.isDialOpen.value)
          GestureDetector(
            onTap: controller.toggleDial,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                constraints: const BoxConstraints.expand(),
              ),
            ),
          ).animate().fadeIn(duration: 250.ms),

        // قائمة الأزرار الفرعية
        Positioned(
          bottom: 100,
          left: 28,
          child: AnimatedOpacity(
            duration: 250.ms,
            opacity: controller.isDialOpen.value ? 1 : 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _speedDialOption(
                  context,
                  label: "محادثة مباشرة",
                  icon: Icons.chat_bubble_rounded,
                  onTap: () {},
                  index: 2,
                ),
                const SizedBox(height: 16),
                _speedDialOption(
                  context,
                  label: "اتصال هاتفي",
                  icon: Icons.call_rounded,
                  onTap: () {},
                  index: 1,
                ),
                const SizedBox(height: 16),
                _speedDialOption(
                  context,
                  label: "الأسئلة الشائعة",
                  icon: Icons.quiz_rounded,
                  onTap: () {},
                  index: 0,
                ),
              ],
            ),
          ),
        ),

        // الزر الرئيسي
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            onPressed: controller.toggleDial,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            tooltip: "الدعم السريع",
            child: AnimatedRotation(
              turns: controller.isDialOpen.value ? 0.125 : 0, // 45 درجة
              duration: 250.ms,
              child: Icon(controller.isDialOpen.value ? Icons.close : Icons.support_agent_rounded, size: 28),
            ),
          ).animate().slide(duration: 300.ms, begin: const Offset(-2, 0), curve: Curves.easeOut),
        ),
      ],
    ));
  }

  Widget _speedDialOption(BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required int index
  }) {
    return IgnorePointer(
      ignoring: !controller.isDialOpen.value,
      child: InkWell(
        onTap: () {
          controller.toggleDial();
          onTap();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10
                    )
                  ]
              ),
              child: Text(label),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
              child: Icon(icon),
            ),
          ],
        ),
      ).animate().moveY(
        delay: (index * 50).ms,
        duration: 250.ms,
        begin: 50,
        curve: Curves.easeOutCubic,
      ).fadeIn(
        delay: (index * 50).ms,
        duration: 250.ms,
      ),
    );
  }
}

// ============== [ الويدجتس المساعدة والمتخصصة ] ==============

class _ProfileTaskItem extends StatelessWidget {
  final ProfileTask task;
  const _ProfileTaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: task.isCompleted ? null : task.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              task.isCompleted ? Icons.check_circle : task.icon,
              color: task.isCompleted ? Colors.green : Get.theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  color: task.isCompleted ? Colors.grey.shade600 : Get.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (!task.isCompleted) const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
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
    final statusColor = status['color'] as Color;

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(policy.policyName,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(policy.iconData,
                        size: 22, color: colorScheme.primary),
                  ),
                ],
              ),
              Text(policy.companyName,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey.shade600)),
              const Spacer(),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(status['text'],
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              )
            ],
          ),
        ),
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
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.QUOTE_REQUEST, arguments: type);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [colorScheme.primary, Colors.transparent],
                  stops: const [0.5, 1.0],
                ).createShader(bounds),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(type.icon, size: 32, color: Colors.white),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(type.description,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerCompanyLogo extends StatelessWidget {
  final PartnerCompany company;
  const _PartnerCompanyLogo({required this.company});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Image.network(
          company.logoUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.business_center_rounded),
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
      width: 200,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outline.withOpacity(0.2))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                article.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey.shade400)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(article.title,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold, height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(article.readTime,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade600)),
                        ],
                      ),
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

class _PolishedSliverHeader extends StatelessWidget {
  final HomeController controller;
  const _PolishedSliverHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 220.0,
      backgroundColor: colorScheme.surface,
      pinned: true,
      stretch: true,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          "أهلاً، ${controller.userName.value}",
          style:
          TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            controller.currentUser?['photoURL'] != null
                ? Image.network(
              controller.currentUser!['photoURL']!,
              fit: BoxFit.cover,
              color: colorScheme.primary.withOpacity(0.1),
              colorBlendMode: BlendMode.darken,
            )
                : Container(color: colorScheme.primary.withOpacity(0.05)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    colorScheme.surface.withOpacity(0.7),
                    colorScheme.surface
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.6, 1],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.showNotificationsSheet,
          icon: Obx(() {
            final hasUnread = controller.allNotifications.any((n) => !n.isRead);
            return Badge(
              isLabelVisible: hasUnread,
              child: const Icon(Icons.notifications_outlined),
            );
          }),
        ),
        const SizedBox(width: 8),
      ],
    );
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

class NotificationsSheetWidget extends StatelessWidget {
  final HomeController controller;
  const NotificationsSheetWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.8, // زيادة الحجم الافتراضي
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // 1. شريط السحب ورأس الصفحة
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text("الإشعارات",
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              // 2. تبويبات الفلترة
              _buildFilterTabs(context),

              const Divider(height: 1),

              // 3. قائمة الإشعارات
              Expanded(
                child: Obx(() => controller.filteredNotifications.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = controller.filteredNotifications[index];
                    return _NotificationCard(
                      notification: notification,
                      controller: controller,
                    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.5);
                  },
                )
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ويدجت خاصة بتبويبات الفلترة
  Widget _buildFilterTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _filterChip(
            context,
            label: 'الكل',
            isSelected: controller.activeNotificationFilter.value == NotificationFilter.all,
            onTap: () => controller.filterNotifications(NotificationFilter.all),
          ),
          _filterChip(
            context,
            label: 'العروض',
            isSelected: controller.activeNotificationFilter.value == NotificationFilter.offers,
            onTap: () => controller.filterNotifications(NotificationFilter.offers),
          ),
          _filterChip(
            context,
            label: 'التنبيهات',
            isSelected: controller.activeNotificationFilter.value == NotificationFilter.alerts,
            onTap: () => controller.filterNotifications(NotificationFilter.alerts),
          ),
        ],
      )),
    );
  }

  // ويدجت مساعدة لبناء زر التبويب
  Widget _filterChip(BuildContext context, {required String label, required bool isSelected, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) { if(selected) onTap(); },
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
          color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      ),
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      shape: StadiumBorder(side: BorderSide(color: isSelected ? Colors.transparent : theme.colorScheme.outline.withOpacity(0.2))),
    );
  }

  // ويدجت لحالة عدم وجود إشعارات
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_active_outlined,
              size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text("لا توجد إشعارات جديدة",
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "سنعلمك عند وجود أي مستجدات.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

// ويدجت جديدة لبطاقة الإشعار مع الإجراءات
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final HomeController controller;

  const _NotificationCard({
    Key? key,
    required this.notification,
    required this.controller,
  }) : super(key: key);

  // دالة مساعدة لتحديد الأيقونة واللون بناءً على نوع الإشعار
  Map<String, dynamic> _getAppearance(BuildContext context, NotificationType type) {
    final theme = Theme.of(context);
    switch (type) {
      case NotificationType.offer:
        return {'icon': Icons.local_offer_rounded, 'color': Colors.blue.shade400};
      case NotificationType.status:
        return {'icon': Icons.check_circle_outline_rounded, 'color': Colors.green.shade500};
      case NotificationType.alert:
        return {'icon': Icons.warning_amber_rounded, 'color': Colors.orange.shade600};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;
    final appearance = _getAppearance(context, notification.type);

    return Slidable(
      key: ValueKey(notification.id),
      // إجراءات السحب من اليسار
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => controller.deleteNotification(notification.id),
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            icon: Icons.delete_forever,
            label: 'حذف',
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
          ),
        ],
      ),
      // إجراءات السحب من اليمين
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          if (isUnread)
            SlidableAction(
              onPressed: (context) => controller.markAsRead(notification.id),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.mark_email_read_rounded,
              label: 'مقروءة',
              borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isUnread ? 4 : 1,
        shadowColor: isUnread ? appearance['color'].withOpacity(0.3) : Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isUnread
              ? BorderSide(color: appearance['color'].withOpacity(0.5), width: 1.5)
              : BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الأيقونة
              CircleAvatar(
                radius: 22,
                backgroundColor: appearance['color'].withOpacity(0.1),
                child: Icon(appearance['icon'], color: appearance['color'], size: 24),
              ),
              const SizedBox(width: 16),
              // المحتوى النصي
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isUnread ? theme.textTheme.bodyLarge?.color : Colors.grey.shade700
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(notification.body, style: TextStyle(color: isUnread ? Colors.grey.shade700 : Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    Text(DateFormat.yMMMd('ar').add_jm().format(notification.timestamp), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              // النقطة للإشارة إلى غير مقروء
              if(isUnread)
                Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: appearance['color'], shape: BoxShape.circle))
            ],
          ),
        ),
      ),
    );
  }}