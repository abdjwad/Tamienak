enum PolicyStatus { active, pending, expired }

class UserPolicy {
  final String policyName;
  final String companyName;
  final PolicyStatus status;
  final String iconAsset; // e.g., 'assets/icons/car.png'

  UserPolicy({
    required this.policyName,
    required this.companyName,
    required this.status,
    required this.iconAsset,
  });
}