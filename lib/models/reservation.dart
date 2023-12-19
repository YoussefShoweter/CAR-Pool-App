import 'package:flutter/foundation.dart';

class Reservation {
  late String id; // Auto-generated ID from Firestore
  final String userId;
  final String driverId;
  final String paymentMethod;
  final String additionalComments;
  final String status;
  final String rideID;

  Reservation({
    required this.id,
    required this.userId,
    required this.driverId,
    required this.paymentMethod,
    required this.additionalComments,
    required this.status,
    required this.rideID
  });

}
