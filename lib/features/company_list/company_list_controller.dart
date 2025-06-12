import 'package:get/get.dart';
import '../../../app/data/models/company_model.dart';
import '../../../app/data/models/insurance_type_model.dart';

class CompanyListController extends GetxController {
  // متغيرات حالة
  var isLoading = true.obs;

  // بيانات
  late InsuranceType selectedInsuranceType;
  final RxList<Company> allCompanies = <Company>[].obs;
  final RxList<Company> filteredCompanies = <Company>[].obs;

  @override
  void onInit() {
    super.onInit();
    // استلام نوع التأمين الذي تم الضغط عليه من الصفحة الرئيسية
    selectedInsuranceType = Get.arguments as InsuranceType;
    _fetchAllCompanies();
  }

  void _fetchAllCompanies() async {
    isLoading.value = true;
    // محاكاة جلب البيانات من السيرفر
    await Future.delayed(const Duration(milliseconds: 800));

    allCompanies.assignAll([
      Company(id: '1', name: 'الشركة السورية للتأمين', logoUrl: 'https://via.placeholder.com/150/5603AD/FFFFFF?text=SCI', rating: 4.5, description: 'رائدة في تأمين السيارات والممتلكات.', supportedInsuranceTypes: ['car', 'property']),
      Company(id: '2', name: 'الثقة للتأمين', logoUrl: 'https://via.placeholder.com/150/8367C7/FFFFFF?text=ATI', rating: 4.8, description: 'خبرة طويلة في التأمين الصحي والحياة.', supportedInsuranceTypes: ['health', 'life']),
      Company(id: '3', name: 'العقيلة للتأمين', logoUrl: 'https://via.placeholder.com/150/B3E9C7/000000?text=AQI', rating: 4.2, description: 'متخصصة في تأمين الشحن والبضائع.', supportedInsuranceTypes: ['cargo', 'travel']),
      Company(id: '4', name: 'الاتحاد التعاوني للتأمين', logoUrl: 'https://via.placeholder.com/150/C2F8CB/000000?text=UCI', rating: 4.6, description: 'حلول تأمينية متكاملة للأفراد والشركات.', supportedInsuranceTypes: ['car', 'health', 'life']),
      Company(id: '5', name: 'الضامنون العرب', logoUrl: 'https://via.placeholder.com/150/F0FFF1/000000?text=AGI', rating: 4.0, description: 'تغطية واسعة لتأمين السفر والمسؤولية.', supportedInsuranceTypes: ['travel', 'responsibility']),
    ]);

    _filterCompanies();
    isLoading.value = false;
  }

  void _filterCompanies() {
    var results = allCompanies.where((company) {
      return company.supportedInsuranceTypes.contains(selectedInsuranceType.id);
    }).toList();
    filteredCompanies.assignAll(results);
  }
}