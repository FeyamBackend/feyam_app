import 'package:feyam/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.category,
    required super.relatedEntityType,
    required super.relatedEntityId,
    required super.isRead,
    required super.createdDate,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] as String,
      relatedEntityType: json['relatedEntityType'] as String?,
      relatedEntityId: json['relatedEntityId'] as String?,
      isRead: json['isRead'] as bool,
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }
}
