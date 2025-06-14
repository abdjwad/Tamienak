import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:tamienk/app/data/models/insurance_offer_model.dart';
import 'package:tamienk/app/routes/app_routes.dart';

class OffersComparisonController extends GetxController {
  final RxList<InsuranceOffer> offers = <InsuranceOffer>[].obs;
  var isLoading = true.obs; // سنستخدم هذا للتحميل

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>;
    final fetchedOffers = arguments['offers'] as List<InsuranceOffer>;

    // محاكاة تحميل
    Future.delayed(const Duration(milliseconds: 500), () {
      offers.assignAll(fetchedOffers);
      isLoading.value = false;
    });
  }

  void selectOffer(InsuranceOffer offer) {
    Get.toNamed(Routes.OFFER_DETAILS, arguments: offer);

  }
}