import 'package:cloud_firestore/cloud_firestore.dart';

class VisitNote {
  final String id;
  final String title;
  final String notes;
  final DateTime date;
  final String clientId;
  final String portfolioId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  VisitNote({
    required this.id,
    required this.title,
    required this.notes,
    required this.date,
    required this.clientId,
    required this.portfolioId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id.isNotEmpty) map['id'] = id;
    map['title'] = title;
    map['notes'] = notes;
    map['date'] = Timestamp.fromDate(date);
    map['clientId'] = clientId;
    map['portfolioId'] = portfolioId;
    map['userId'] = userId;
    map['createdAt'] = Timestamp.fromDate(createdAt);
    map['updatedAt'] = Timestamp.fromDate(updatedAt);
    map['status'] = status;
    return map;
  }

  factory VisitNote.fromMap(Map<String, dynamic> map) {
    return VisitNote(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      notes: map['notes'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      clientId: map['clientId'] ?? '',
      portfolioId: map['portfolioId'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'active',
    );
  }
} 