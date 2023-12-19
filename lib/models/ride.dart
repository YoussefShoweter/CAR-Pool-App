import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Ride {
  late String id;
  final String date;
  final String driverId;
  final String driverName;
  final String startPoint;
  final String destinationPoint;
  final double price;
  final DateTime rideDateTime; // Use DateTime for both date and time

  Ride({
    required this.id,
    required this.date,
    required this.driverId,
    required this.driverName,
    required this.startPoint,
    required this.destinationPoint,
    required this.price,
    required this.rideDateTime,
  });

  // Add the fromJson factory method
  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String,
      date: json['date'] as String,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String,
      startPoint: json['startPoint'] as String,
      destinationPoint: json['destinationPoint'] as String,
      price: json['price'] as double,
      rideDateTime: (json['rideDateAndTime'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    );
  }
}
