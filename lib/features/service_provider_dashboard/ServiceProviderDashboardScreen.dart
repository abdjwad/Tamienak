// lib/features/service_provider_dashboard/screens/service_provider_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tamienk/app/data/models/insurance_offer_model.dart';
import 'package:tamienk/features/service_provider_dashboard/ServiceProviderDashboardController.dart';
import '../../../app/data/models/service_request_model.dart';

class ServiceProviderDashboardScreen extends GetView<ServiceProviderDashboardController> {
  const ServiceProviderDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, Color.lerp(colorScheme.primary, Colors.black, 0.4)!],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout), onPressed: controller.logout),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          indicatorColor: colorScheme.secondary,
          indicatorWeight: 4.0,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'الرئيسية'),
            Tab(icon: Icon(Icons.list_alt_outlined), text: 'الطلبات'),
            Tab(icon: Icon(Icons.local_offer_outlined), text: 'عروضي'),
            Tab(icon: Icon(Icons.person_outline), text: 'ملفي'),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }
        return TabBarView(
          controller: controller.tabController,
          children: [
            _buildDashboardTab(context),
            _buildRequestsTab(context),
            _buildMyOffersTab(context),
            _buildProfileTab(context),
          ],
        );
      }),
    );
  }

  // --- التبويب الأول: لوحة التحكم ---
  Widget _buildDashboardTab(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () => controller.fetchDashboardData(),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(controller.providerImageUrl.value)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أهلاً بعودتك،',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: Colors.grey.shade600)),
                  Text(controller.providerName.value,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).slide(begin: const Offset(-0.2, 0)),
          const SizedBox(height: 32),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _buildStatCard(
                context, "طلبات جديدة", controller.newRequestsCount.value.toString(),
                Icons.inbox_outlined, [Colors.orange.shade600, Colors.amber.shade700],
                onTap: () => controller.goToRequestsTabWithFilter(ServiceRequestStatus.pending),
              ),
              _buildStatCard(
                context, "قيد المراجعة", controller.inProgressRequestsCount.value.toString(),
                Icons.hourglass_empty_rounded, [Colors.blue.shade600, Colors.lightBlue.shade700],
                onTap: () => controller.goToRequestsTabWithFilter(ServiceRequestStatus.inProgress),
              ),
            ].animate(interval: 100.ms).fadeIn(duration: 400.ms).scaleXY(begin: 0.8, curve: Curves.easeOutBack),
          ),
          const SizedBox(height: 32),

          _buildSectionHeader(context, "أداء الأسبوع", Icons.bar_chart_outlined),
          SizedBox(
            height: 200,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildBarChart(context),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
        ],
      ),
    );
  }

  // --- التبويب الثاني: الطلبات ---
  Widget _buildRequestsTab(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          color: theme.scaffoldBackgroundColor.withAlpha(240),
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
        Expanded(
          child: Obx(() {
            if (controller.filteredRequests.isEmpty) {
              return Center(child: Text("لا توجد طلبات تطابق هذا الفلتر.", style: theme.textTheme.bodyLarge));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.filteredRequests.length,
              itemBuilder: (context, index) {
                final request = controller.filteredRequests[index];
                return _ServiceRequestCard(
                  request: request,
                  onTap: () {},
                  onActionsPressed: () => _showRequestActions(context, request),
                ).animate().fadeIn(duration: 300.ms).slide(begin: const Offset(0, 0.1));
              },
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
        label: const Text('إضافة عرض'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.black87,
      ).animate().slide(begin: const Offset(0, 2), curve: Curves.easeOut).fadeIn(),
      body: Obx(() {
        if (controller.categorizedOffers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text("لم تقم بإضافة أي عروض بعد", style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text("انقر على زر 'إضافة عرض' للبدء.", style: TextStyle(color: Colors.grey)),
              ],
            ).animate().fadeIn().scale(),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(value: 'نشط', label: Text('العروض النشطة'), icon: Icon(Icons.check_circle_outline)),
                  ButtonSegment<String>(value: 'غير نشط', label: Text('العروض غير النشطة'), icon: Icon(Icons.pause_circle_outline)),
                ],
                selected: <String>{controller.offerStatusFilter.value},
                onSelectionChanged: (Set<String> newSelection) {
                  controller.setOfferStatusFilter(newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  foregroundColor: theme.colorScheme.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: controller.categorizedOffers.length,
                itemBuilder: (context, index) {
                  final category = controller.categorizedOffers[index];
                  final filteredOffers = category.offers.where((offer) {
                    return controller.offerStatusFilter.value == 'نشط' ? offer.isActive : !offer.isActive;
                  }).toList();

                  if (filteredOffers.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(category.categoryIcon, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              category.categoryName,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(),
                      ...filteredOffers.map((offer) {
                        return _buildOfferCard(context, offer);
                      }).toList().animate(interval: 80.ms).fadeIn(duration: 400.ms).slide(begin: const Offset(0.1, 0)),
                    ],
                  );
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text("الملف الشخصي", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text("هنا يمكنك تعديل بياناتك وإعدادات حسابك.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  // --- ويدجتس مساعدة ---

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (onViewAll != null)
            TextButton(onPressed: onViewAll, child: const Text("عرض الكل")),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, List<Color> gradientColors, {required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: gradientColors.first.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 36, color: Colors.white.withOpacity(0.8)),
                const Spacer(),
                Text(value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, ServiceRequestStatus? status, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          controller.filterRequests(status);
        },
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor:
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 0: weekDay = 'السبت'; break;
                case 1: weekDay = 'الأحد'; break;
                case 2: weekDay = 'الاثنين'; break;
                case 3: weekDay = 'الثلاثاء'; break;
                case 4: weekDay = 'الأربعاء'; break;
                case 5: weekDay = 'الخميس'; break;
                case 6: weekDay = 'الجمعة'; break;
                default: throw Error();
              }
              return BarTooltipItem(
                '$weekDay\n',
                const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.toY - 1).toString(),
                    style: TextStyle(
                        color: colorScheme.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
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
                const style = TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14);
                String text;
                switch (value.toInt()) {
                  case 0: text = 'س'; break;
                  case 1: text = 'ح'; break;
                  case 2: text = 'ن'; break;
                  case 3: text = 'ث'; break;
                  case 4: text = 'ر'; break;
                  case 5: text = 'خ'; break;
                  case 6: text = 'ج'; break;
                  default: text = ''; break;
                }
                return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 16,
                    child: Text(text, style: style));
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: controller.weeklyChartData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble() + 1,
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 22,
                borderRadius: BorderRadius.circular(8),
              )
            ],
          );
        }).toList(),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  void _showRequestActions(BuildContext context, ServiceRequest request) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: const Text('الموافقة على الطلب'),
              onTap: () {
                Get.back();
                controller.updateRequestStatus(request.id, ServiceRequestStatus.approved);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Colors.red),
              title: const Text('رفض الطلب'),
              onTap: () {
                Get.back();
                controller.updateRequestStatus(request.id, ServiceRequestStatus.rejected);
              },
            ),
            ListTile(
              leading: const Icon(Icons.hourglass_empty, color: Colors.blue),
              title: const Text('تحديد كـ "قيد المعالجة"'),
              onTap: () {
                Get.back();
                controller.updateRequestStatus(request.id, ServiceRequestStatus.inProgress);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.orange),
              title: const Text('طلب معلومات إضافية'),
              onTap: () {
                Get.back();
                Get.snackbar('إجراء', 'سيتم فتح شاشة مراسلة لطلب معلومات إضافية.');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOfferCard(BuildContext context, InsuranceOffer offer) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isInactive = !offer.isActive;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: isInactive ? 0.5 : 4,
      shadowColor: colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isInactive ? Colors.grey.shade400 : colorScheme.primary,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.offerId,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isInactive ? Colors.grey : null),
                ),
                const SizedBox(height: 4),
                Text(
                  "السعر: ${offer.annualPrice.toStringAsFixed(0)} ل.س/سنة",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isInactive ? Colors.grey : colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 24),
                ...offer.coverageDetails.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(children: [
                    Icon(Icons.check_circle, size: 20, color: isInactive ? Colors.grey.shade400 : Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(child: Text(detail, style: TextStyle(color: isInactive ? Colors.grey : null))),
                  ]),
                )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: Text(offer.isActive ? 'نشط' : 'غير نشط', style: const TextStyle(fontWeight: FontWeight.bold)),
                        value: offer.isActive,
                        onChanged: (bool value) => controller.toggleOfferStatus(offer.offerId),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                          onPressed: () => controller.goToEditOffer(offer),
                          tooltip: 'تعديل',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                          onPressed: () => controller.deleteOffer(offer.offerId),
                          tooltip: 'حذف',
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          if (isInactive)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: (theme.brightness == Brightness.light ? Colors.white : Colors.black).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
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
  final VoidCallback onTap;
  final VoidCallback? onActionsPressed;

  const _ServiceRequestCard({
    Key? key,
    required this.request,
    required this.onTap,
    this.onActionsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: request.status.color.withOpacity(0.5), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: request.status.color.withOpacity(0.1),
          backgroundImage: request.applicantImageUrl != null
              ? NetworkImage(request.applicantImageUrl!)
              : null,
          child: request.applicantImageUrl == null
              ? Text(
              request.applicantName.isNotEmpty ? request.applicantName.substring(0, 1) : '?',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: request.status.color
              )
          )
              : null,
        ),
        title: Text(
          request.applicantName,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${request.insuranceType} - ${request.formattedRequestDate}",
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        trailing: onActionsPressed != null
            ? IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: onActionsPressed,
          color: Colors.grey.shade600,
        )
            : null,
      ),
    );
  }
}