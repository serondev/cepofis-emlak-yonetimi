import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String name;
  final String phone;
  final List<String> interestedTypes;
  final String notes;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    this.id = '',
    required this.name,
    required this.phone,
    required this.interestedTypes,
    required this.notes,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id.isNotEmpty) map['id'] = id;
    map['name'] = name;
    map['phone'] = phone;
    map['interestedTypes'] = interestedTypes;
    map['notes'] = notes;
    map['userId'] = userId;
    map['createdAt'] = Timestamp.fromDate(createdAt);
    map['updatedAt'] = Timestamp.fromDate(updatedAt);
    return map;
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      interestedTypes: List<String>.from(map['interestedTypes'] ?? []),
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