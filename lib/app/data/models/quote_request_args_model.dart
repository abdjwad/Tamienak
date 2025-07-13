// مسار الملف: lib/app/data/models/quote_request_args_model.dart

import 'company_model.dart';
import 'insurance_product_model.dart';
import 'insurance_type_model.dart';
import 'pricing_plan_model.dart';

class QuoteRequestArgs {
  final InsuranceType insuranceType;
  final Company company;
  final InsuranceProduct product;
  final PricingPlan plan;

  QuoteRequestArgs({
    required this.insuranceType,
    required this.company,
    required this.product,
    required this.plan,
  });
}