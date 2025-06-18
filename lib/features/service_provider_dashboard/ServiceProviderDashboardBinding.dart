// lib/features/service_provider_dashboard/bindings/service_provider_dashboard_binding.dart
import 'package:get/get.dart';

import 'ServiceProviderDashboardController.dart';

class ServiceProviderDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceProviderDashboardController>(
          () => ServiceProviderDashboardController(),
    );
  }
}