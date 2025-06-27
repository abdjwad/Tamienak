// lib/features/service_provider_dashboard/screens/service_provider_dashboard_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tamienk/app/data/models/insurance_offer_model.dart';
import '../../../app/data/models/service_request_model.dart';
import 'ServiceProviderDashboardController.dart';

class ServiceProviderDashboardScreen extends GetView<ServiceProviderDashboardController> {
  const ServiceProviderDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }
        return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text('لوحة تحكم ${controller.providerName.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                pinned: true, floating: true, forceElevated: innerBoxIsScrolled, expandedHeight: 120.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, Color.lerp(colorScheme.primary, colorScheme.surface, 0.3)!],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.logout_rounded), onPressed: controller.logout),
                ],
                bottom: TabBar(
                  controller: controller.tabController,
                  indicatorColor: colorScheme.secondary, indicatorWeight: 3.5,
                  labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
                  unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'الرئيسية'), Tab(text: 'الطلبات'),
                    Tab(text: 'عروضي'), Tab(text: 'ملفي'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: controller.tabController,
            children: [
              _buildDashboardTab(context),
              _buildRequestsTab(context),
              _buildMyOffersTab(context),
              _buildProfileTab(context),
            ],
          ),
        );
      }),
    );
  }

  // --- التبويب الأول: لوحة التحكم ---
  Widget _buildDashboardTab(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () => controller.fetchDashboardData(),
      color: theme.colorScheme.secondary,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(controller.providerImageUrl.value)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مرحباً بعودتك،', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                    Text(controller.providerName.value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              IconButton(onPressed: (){}, icon: Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 28,))
            ],
          ).animate().fadeIn(duration: 500.ms).slide(begin: const Offset(-0.2, 0)),
          const SizedBox(height: 24),
          _buildSectionHeader(context, "نظرة عامة سريعة", Icons.insights_rounded),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildHorizontalStatCard(context, "طلبات جديدة", controller.newRequestsCount.value.toString(), Icons.move_to_inbox_rounded, Colors.orange.shade700, onTap: () => controller.goToRequestsTabWithFilter(ServiceRequestStatus.pending)),
                _buildHorizontalStatCard(context, "قيد المعالجة", controller.inProgressRequestsCount.value.toString(), Icons.autorenew_rounded, Colors.blue.shade600, onTap: () => controller.goToRequestsTabWithFilter(ServiceRequestStatus.inProgress)),
                _buildHorizontalStatCard(context, "طلبات موافق عليها", controller.approvedRequestsCount.value.toString(), Icons.check_circle_outline_rounded, Colors.green.shade600, onTap: () => controller.goToRequestsTabWithFilter(ServiceRequestStatus.approved)),
              ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slide(begin: const Offset(0.2, 0)),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, "أداء الطلبات الأسبوعي", Icons.stacked_bar_chart_rounded),
          SizedBox(
            height: 220,
            child: Card(
              elevation: 2, color: theme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: _buildBarChart(context), // <--- تم تمرير context هنا بشكل صحيح
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms).scaleXY(begin: 0.95),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- التبويب الثاني: الطلبات ---
  Widget _buildRequestsTab(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withOpacity(0.9),
                border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.3), width: 1)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Obx(() => Row(
                  children: [
                    _buildFilterChip(context, "الكل", null, controller.selectedStatusFilter.value == null),
                    ...ServiceRequestStatus.values.map((status) {
                      return _buildFilterChip(context, status.displayName, status, controller.selectedStatusFilter.value == status);
                    }).toList(),
                  ],
                )),
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.filteredRequests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.filteredRequests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text("لا توجد طلبات تطابق هذا الفلتر.", style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600)),
                  ],
                ).animate().fadeIn().scale(delay: 200.ms),
              );
            }
            return SlidableAutoCloseBehavior(
              child: ListView.builder(
                key: ValueKey(controller.selectedStatusFilter.value?.index ?? -1),
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = controller.filteredRequests[index];
                  return _ServiceRequestCard(request: request)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (80 * index).ms)
                      .slide(begin: const Offset(0, 0.2), curve: Curves.easeOutCubic);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- التبويب الثالث: عروضي ---
  Widget _buildMyOffersTab(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.goToAddOffer,
        label: const Text('إضافة عرض جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_circle_outline_rounded),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        elevation: 6,
      ).animate().slide(begin: const Offset(0, 2), duration: 500.ms, curve: Curves.easeInOutBack).fadeIn(delay: 200.ms),
      body: Obx(() {
        if (controller.categorizedOffers.isEmpty && !controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined, size: 100, color: Colors.grey.shade400),
                const SizedBox(height: 20),
                Text("لم تقم بإضافة أي عروض بعد", style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600)),
                const SizedBox(height: 10),
                Text("ابدأ بإضافة أول عرض تأمين خاص بك!", style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
              ],
            ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(value: 'نشط', label: Text('النشطة'), icon: Icon(Icons.play_circle_outline_rounded)),
                  ButtonSegment<String>(value: 'غير نشط', label: Text('غير النشطة'), icon: Icon(Icons.pause_circle_outline_rounded)),
                ],
                selected: <String>{controller.offerStatusFilter.value},
                onSelectionChanged: (Set<String> newSelection) {
                  controller.setOfferStatusFilter(newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    selectedBackgroundColor: theme.colorScheme.primaryContainer,
                    selectedForegroundColor: theme.colorScheme.onPrimaryContainer,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo', fontSize: 13),
                    padding: const EdgeInsets.symmetric(vertical: 10)
                ),
              ).animate().fadeIn(delay: 100.ms),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: controller.categorizedOffers.length,
                itemBuilder: (context, categoryIndex) {
                  final category = controller.categorizedOffers[categoryIndex];
                  final offersToShow = category.offers.where((offer) {
                    return controller.offerStatusFilter.value == 'نشط' ? offer.isActive : !offer.isActive;
                  }).toList();

                  if (offersToShow.isEmpty && controller.categorizedOffers.any((cat) => cat.offers.isNotEmpty)) {
                    return const SizedBox.shrink();
                  }

                  return Obx(() => ExpansionTile(
                    key: PageStorageKey(category.categoryName + categoryIndex.toString()),
                    initiallyExpanded: category.isExpanded.value,
                    onExpansionChanged: (isExpanding) => controller.toggleCategoryExpansion(categoryIndex),
                    leading: Icon(category.categoryIcon, color: theme.colorScheme.primary, size: 28),
                    title: Text(
                      category.categoryName,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    childrenPadding: const EdgeInsets.only(top: 0.0, bottom: 8.0, left: 8.0, right: 8.0),
                    children: offersToShow.map((offer) {
                      return _buildOfferCard(context, offer, category.categoryIcon, theme.colorScheme.primary)
                          .animate(delay: (100 * offersToShow.indexOf(offer)).ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.2, curve: Curves.easeOut);
                    }).toList(),
                  )).animate().fadeIn(delay: (100 * categoryIndex).ms);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- التبويب الرابع: الملف الشخصي ---
  Widget _buildProfileTab(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(controller.providerImageUrl.value),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(controller.providerName.value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))
                .animate().fadeIn(delay: 200.ms),
            Text("مقدم خدمة تأمين", style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600))
                .animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 40),
            _buildProfileOption(context, Icons.edit_note_rounded, "تعديل معلومات الحساب", (){}),
            _buildProfileOption(context, Icons.lock_outline_rounded, "تغيير كلمة المرور", (){}),
            _buildProfileOption(context, Icons.settings_outlined, "إعدادات الإشعارات", (){}),
            _buildProfileOption(context, Icons.help_outline_rounded, "المساعدة والدعم", (){}),
          ].animate(interval: 100.ms).slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut),
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Cairo')),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: onTap,
      ),
    );
  }

  // --- ويدجتس مساعدة ---
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, {VoidCallback? onViewAll}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          if (onViewAll != null)
            TextButton(onPressed: onViewAll, child: const Text("عرض الكل")),
        ],
      ),
    );
  }

  Widget _buildHorizontalStatCard(BuildContext context, String title, String value, IconData icon, Color color, {required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Container(
      width: 170,
      margin: const EdgeInsets.only(left: 12),
      child: Card(
        elevation: 0.8,
        color: color.withOpacity(0.15),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withOpacity(0.4), width: 1)
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withOpacity(0.9),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
                      Text(title, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'Cairo'), overflow: TextOverflow.ellipsis,),
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

  Widget _buildFilterChip(BuildContext context, String label, ServiceRequestStatus? status, bool isSelected) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontFamily: 'Cairo', fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selected: isSelected,
        onSelected: (selected) => controller.filterRequests(status),
        selectedColor: theme.colorScheme.primary,
        labelStyle: TextStyle(color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyLarge?.color),
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() => BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: controller.weeklyChartData.isNotEmpty ? controller.weeklyChartData.reduce((a, b) => a > b ? a : b) * 1.2 + 2 : 20,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 0: weekDay = 'السبت'; break; case 1: weekDay = 'الأحد'; break;
                case 2: weekDay = 'الاثنين'; break; case 3: weekDay = 'الثلاثاء'; break;
                case 4: weekDay = 'الأربعاء'; break; case 5: weekDay = 'الخميس'; break;
                case 6: weekDay = 'الجمعة'; break;
                default: return null;
              }
              return BarTooltipItem(
                '$weekDay\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'),
                children: <TextSpan>[
                  TextSpan(text: rod.toY.toStringAsFixed(0), style: TextStyle(color: colorScheme.secondary, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Cairo')),
                  const TextSpan(text: ' طلب', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Cairo')),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Cairo');
                String text;
                switch (value.toInt()) {
                  case 0: text = 'س'; break; case 1: text = 'ح'; break;
                  case 2: text = 'ن'; break; case 3: text = 'ث'; break;
                  case 4: text = 'ر'; break; case 5: text = 'خ'; break;
                  case 6: text = 'ج'; break;
                  default: text = ''; break;
                }
                return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: Text(text, style: style));
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true, reservedSize: 30, interval: 5,
                  getTitlesWidget: (value, meta) {
                    if (value == 0 || value == meta.max || value % 5 != 0) return Container();
                    return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Cairo'));
                  }
              )
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: controller.weeklyChartData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                gradient: LinearGradient(
                  colors: [colorScheme.primary.withOpacity(0.7), colorScheme.secondary.withOpacity(0.7)],
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                ),
                width: 18,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              )
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        ),
      ),
    ));
  }

  Widget _buildOfferCard(BuildContext context, InsuranceOffer offer, IconData categoryIcon, Color categoryColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isInactive = !offer.isActive;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      elevation: isInactive ? 1 : 5,
      shadowColor: isInactive ? Colors.grey.shade300 : categoryColor.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: isInactive ? Colors.grey.shade300 : categoryColor.withOpacity(0.7), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isInactive ? [Colors.grey.shade400, Colors.grey.shade300] : [categoryColor, Color.lerp(categoryColor, colorScheme.surface, 0.3)!],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(categoryIcon, color: Colors.white.withOpacity(0.9), size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(offer.offerId, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'), overflow: TextOverflow.ellipsis),
                    ),
                    Switch(
                      value: offer.isActive,
                      onChanged: (bool value) => controller.toggleOfferStatus(offer.offerId),
                      activeColor: colorScheme.secondary,
                      inactiveThumbColor: Colors.grey.shade600,
                      inactiveTrackColor: Colors.grey.shade300.withOpacity(0.5),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "السعر السنوي: ${offer.annualPrice.toStringAsFixed(0)} ل.س",
                      style: theme.textTheme.titleLarge?.copyWith(color: isInactive ? Colors.grey.shade600 : colorScheme.secondary, fontWeight: FontWeight.bold, letterSpacing: -0.5, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 12),
                    Text("أبرز مزايا التغطية:", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                    const SizedBox(height: 8),
                    if (offer.coverageDetails.isNotEmpty)
                      ...offer.coverageDetails.take(3).map((detail) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.verified_user_outlined, size: 18, color: isInactive ? Colors.grey.shade500 : Colors.teal.shade600),
                            const SizedBox(width: 8),
                            Expanded(child: Text(detail, style: TextStyle(fontSize: 13, color: isInactive ? Colors.grey.shade600 : null, fontFamily: 'Cairo'))),
                          ],
                        ),
                      ))
                    else
                      Text("لا توجد تفاصيل تغطية لهذا العرض.", style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic, fontFamily: 'Cairo')),
                    if (offer.coverageDetails.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text("+ ${offer.coverageDetails.length - 3} مزايا أخرى...", style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontFamily: 'Cairo')),
                      ),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.edit_note_rounded, color: isInactive ? Colors.grey.shade400 : theme.colorScheme.primary),
                          label: Text('تعديل', style: TextStyle(color: isInactive ? Colors.grey.shade400 : theme.colorScheme.primary, fontFamily: 'Cairo')),
                          onPressed: isInactive ? null : () => controller.goToEditOffer(offer),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: Icon(Icons.delete_forever_rounded, color: theme.colorScheme.error),
                          label: Text('حذف', style: TextStyle(color: theme.colorScheme.error, fontFamily: 'Cairo')),
                          onPressed: () => controller.deleteOffer(offer.offerId),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isInactive)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                  child: Container(color: (theme.brightness == Brightness.light ? Colors.white : Colors.black).withOpacity(0.3)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceRequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback? onTap;

  const _ServiceRequestCard({
    Key? key,
    required this.request,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ServiceProviderDashboardController>();

    return Slidable(
      key: ValueKey(request.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(), extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => controller.updateRequestStatus(request.id, ServiceRequestStatus.rejected),
            backgroundColor: Colors.red.shade700, foregroundColor: Colors.white,
            icon: Icons.cancel_rounded, label: 'رفض', borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const BehindMotion(), extentRatio: request.status == ServiceRequestStatus.pending ? 0.5 : 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => controller.updateRequestStatus(request.id, ServiceRequestStatus.approved),
            backgroundColor: Colors.green.shade600, foregroundColor: Colors.white,
            icon: Icons.check_circle_rounded, label: 'موافقة', borderRadius: BorderRadius.circular(12),
          ),
          if (request.status == ServiceRequestStatus.pending)
            SlidableAction(
              onPressed: (context) => controller.updateRequestStatus(request.id, ServiceRequestStatus.inProgress),
              backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white,
              icon: Icons.autorenew_rounded, label: 'معالجة', borderRadius: BorderRadius.circular(12),
            ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0), elevation: 2.5,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: onTap ?? () {},
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            radius: 26, backgroundColor: request.status.color.withOpacity(0.15),
            backgroundImage: request.applicantImageUrl != null ? NetworkImage(request.applicantImageUrl!) : null,
            child: request.applicantImageUrl == null ? Icon(request.status.icon, color: request.status.color, size: 28) : null,
          ),
          title: Text(request.applicantName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.insuranceType, style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Cairo')),
              const SizedBox(height: 4),
              Text(request.formattedRequestDate, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontFamily: 'Cairo')),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: request.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(request.status.displayName, style: TextStyle(color: request.status.color, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Cairo')),
              ),
              if(request.status == ServiceRequestStatus.pending || request.status == ServiceRequestStatus.inProgress)
                const Padding(padding: EdgeInsets.only(top: 4.0), child: Icon(Icons.swipe_rounded, color: Colors.grey, size: 18))
            ],
          ),
        ),
      ),
    );
  }
}