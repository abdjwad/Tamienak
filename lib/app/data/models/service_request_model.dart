// lib/app/data/models/service_request_model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ... (ServiceRequestStatus و ServiceRequestStatusExtension كما هي) ...
enum ServiceRequestStatus {
  pending,
  inProgress,
  approved,
  rejected,
  completed,
}

extension ServiceRequestStatusExtension on ServiceRequestStatus {
  String get displayName {
    switch (this) {
      case ServiceRequestStatus.pending: return 'بانتظار المراجعة';
      case ServiceRequestStatus.inProgress: return 'قيد المعالجة';
      case ServiceRequestStatus.approved: return 'تمت الموافقة';
      case ServiceRequestStatus.rejected: return 'تم الرفض';
      case ServiceRequestStatus.completed: return 'تم الإنجاز';
    }
  }

  Color get color {
    switch (this) {
      case ServiceRequestStatus.pending: return Colors.orange.shade700;
      case ServiceRequestStatus.inProgress: return Colors.blue.shade700;
      case ServiceRequestStatus.approved: return Colors.green.shade700;
      case ServiceRequestStatus.rejected: return Colors.red.shade700;
      case ServiceRequestStatus.completed: return Colors.grey.shade700;
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceRequestStatus.pending: return Icons.hourglass_empty;
      case ServiceRequestStatus.inProgress: return Icons.settings_applications;
      case ServiceRequestStatus.approved: return Icons.check_circle_outline;
      case ServiceRequestStatus.rejected: return Icons.cancel_outlined;
      case ServiceRequestStatus.completed: return Icons.done_all;
    }
  }
}

class ServiceRequest {
  final String id;
  final String applicantName;
  final String? applicantImageUrl; // <--- أضف هذا الحقل
  final String insuranceType;
  final DateTime requestDate;
  final ServiceRequestStatus status;
  final String? notes;

  ServiceRequest({
    required this.id,
    required this.applicantName,
    this.applicantImageUrl, // <--- اجعله اختيارياً
    required this.insuranceType,
    required this.requestDate,
    this.status = ServiceRequestStatus.pending,
    this.notes,
  });

  String get formattedRequestDate => DateFormat('dd MMM yyyy', 'ar').format(requestDate);
}