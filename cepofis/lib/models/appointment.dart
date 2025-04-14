import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String clientId;
  final List<String> portfolioIds;
  final DateTime date;
  final String notes;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    this.id = '',
    required this.clientId,
    required this.portfolioIds,
    required this.date,
    required this.notes,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id.isNotEmpty) map['id'] = id;
    map['clientId'] = clientId;
    map['portfolioIds'] = portfolioIds;
    map['date'] = Timestamp.fromDate(date);
    map['notes'] = notes;
    map['userId'] = userId;
    map['createdAt'] = Timestamp.fromDate(createdAt);
    map['updatedAt'] = Timestamp.fromDate(updatedAt);
    return map;
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      clientId: map['clientId'] ?? '',
      portfolioIds: List<String>.from(map['portfolioIds'] ?? []),
      date: map['date'] != null 
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      notes: map['notes'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
} 