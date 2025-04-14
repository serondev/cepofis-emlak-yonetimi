import 'package:cloud_firestore/cloud_firestore.dart';

class Portfolio {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double price;
  final String location;
  final double area;
  final int roomCount;
  final String type; // satilik/kiralik
  final String propertyType; // daire, villa, arsa vb.
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  Portfolio({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.area,
    required this.roomCount,
    required this.type,
    required this.propertyType,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'area': area,
      'roomCount': roomCount,
      'type': type,
      'propertyType': propertyType,
      'images': images,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Portfolio.fromMap(Map<String, dynamic> map) {
    return Portfolio(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      location: map['location'] ?? '',
      area: (map['area'] ?? 0).toDouble(),
      roomCount: map['roomCount']?.toInt() ?? 0,
      type: map['type'] ?? '',
      propertyType: map['propertyType'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
} 