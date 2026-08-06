import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.relatedEntityType,
    required this.relatedEntityId,
    required this.isRead,
    required this.createdDate,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final bool isRead;
  final DateTime createdDate;

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
    id: id,
    title: title,
    body: body,
    category: category,
    relatedEntityType: relatedEntityType,
    relatedEntityId: relatedEntityId,
    isRead: isRead ?? this.isRead,
    createdDate: createdDate,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    category,
    relatedEntityType,
    relatedEntityId,
    isRead,
    createdDate,
  ];
}
