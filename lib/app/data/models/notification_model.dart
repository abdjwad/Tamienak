// مسار الملف: lib/app/data/models/notification_model.dart

enum NotificationType { offer, status, alert }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  bool isRead; // <-- [FIX] تم إزالة كلمة `final` من هنا

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false, // القيمة الافتراضية هي "غير مقروء"
  });
}