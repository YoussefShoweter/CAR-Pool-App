import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models/ride.dart';
import 'models/reservation.dart';

class FirestoreService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference _tripsCollection = FirebaseFirestore.instance.collection('trips');
  final CollectionReference _reservationCollection = FirebaseFirestore.instance.collection('reservations');


  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await _usersCollection.doc(userId).get();
      if (userSnapshot.exists) {
        return userSnapshot['fullName']; // Replace 'fullName' with your actual field name
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      print("Error getting user data: $e");
      return 'Unknown User';
    }
  }
  Future<Map<String, dynamic>> getDriverProfile(String driverId) async {
    try {
      DocumentSnapshot driverSnapshot = await _usersCollection.doc(driverId).get();
      if (driverSnapshot.exists) {
        return driverSnapshot.data() as Map<String, dynamic>;
      } else {
        return {}; // Return an empty map or handle accordingly
      }
    } catch (e) {
      print("Error getting driver profile: $e");
      return {}; // Return an empty map or handle accordingly
    }
  }
  Future<String> getUserTypeById(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await _usersCollection.doc(userId).get();
      if (userSnapshot.exists) {
        return userSnapshot['userType'] ?? 'Unknown User Type'; // Replace 'userType' with your actual field name
      } else {
        return 'Unknown User Type';
      }
    } catch (e) {
      print("Error getting user type: $e");
      return 'Unknown User Type';
    }
  }
  Future<void> addTrip(Ride ride, Timestamp rideDateTime) async {
    try {
      await _tripsCollection.add({
        'date': ride.date,
        'driverId': ride.driverId,
        'driverName': ride.driverName,
        'startPoint': ride.startPoint,
        'destinationPoint': ride.destinationPoint,
        'price': ride.price,
        'rideDateAndTime': rideDateTime,
      });
    } catch (e) {
      print("Error adding trip to Firestore: $e");
    }
  }
  Future<List<Ride>> getRidesByDriverId() async {
    try {
      QuerySnapshot rideQuery = await _tripsCollection
          .where('driverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      List<Ride> rides = rideQuery.docs.map((DocumentSnapshot doc) {
        Timestamp rideDateTimeStamp = doc['rideDateAndTime'];
        DateTime rideDateTime = rideDateTimeStamp.toDate();

        return Ride(
          id: doc.id,
          date: doc['date'],
          driverId: doc['driverId'],
          driverName: doc['driverName'],
          startPoint: doc['startPoint'],
          destinationPoint: doc['destinationPoint'],
          price: doc['price'].toDouble(),
          rideDateTime: rideDateTime,
        );
      }).toList();

      return rides;
    } catch (e) {
      print("Error getting rides by driverId: $e");
      return [];
    }
  }
  Future<List<Ride>> getAllRides() async {
    try {
      QuerySnapshot rideQuery = await _tripsCollection.get();

      List<Ride> rides = rideQuery.docs.map((DocumentSnapshot doc) {
        Timestamp rideDateTimeStamp = doc['rideDateAndTime'];
        DateTime rideDateTime = rideDateTimeStamp.toDate();

        return Ride(
          id: doc.id,
          date: doc['date'],
          driverId: doc['driverId'],
          driverName: doc['driverName'],
          startPoint: doc['startPoint'],
          destinationPoint: doc['destinationPoint'],
          price: doc['price'].toDouble(),
          rideDateTime: rideDateTime,
        );
      }).toList();

      return rides;
    } catch (e) {
      print("Error getting all rides: $e");
      return [];
    }
  }
  Future<void> addReservation(Reservation reservation) async {
    try {
      await _reservationCollection.add({
        'userId': reservation.userId,
        'driverId': reservation.driverId,
        'paymentMethod': reservation.paymentMethod,
        'additionalComments': reservation.additionalComments,
        'status': reservation.status,
        'rideID':reservation.rideID,
      });
    } catch (e) {
      print('Error adding reservation to Firestore: $e');
      // Handle error as needed
    }
  }
  Future<List<Reservation>> getUserReservations(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _reservationCollection.where('userId', isEqualTo: userId).get();

      List<Reservation> reservations = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Reservation(
          id: doc.id,
          userId: data['userId'],
          driverId: data['driverId'],
          paymentMethod: data['paymentMethod'],
          additionalComments: data['additionalComments'],
          status: data['status'],
          rideID: data['rideID'],
        );
      }).toList();

      return reservations;
    } catch (e) {
      print('Error fetching user reservations: $e');
      return [];
    }
  }
  Future<Ride?> getRideById(String rideId) async {
    try {
      DocumentSnapshot rideSnapshot = await _tripsCollection.doc(rideId).get();
      if (rideSnapshot.exists) {
        Map<String, dynamic> rideData = rideSnapshot.data() as Map<String, dynamic>;
        rideData['id'] = rideSnapshot.id;
        return Ride.fromJson(rideData);
      } else {
        return null; // Ride with the given ID not found
      }
    } catch (e) {
      print('Error getting ride by ID: $e');
      return null;
    }
  }
  Future<List<Reservation>> getReservationsByDriverIdAndStatus(String driverId) async {
      try {
        QuerySnapshot querySnapshot = await _reservationCollection
            .where('driverId', isEqualTo: driverId)
            .where('status', isEqualTo: 'Pending')
            .get();

        List<Reservation> reservations = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          return Reservation(
            id: doc.id,
            userId: data['userId'],
            driverId: data['driverId'],
            paymentMethod: data['paymentMethod'],
            additionalComments: data['additionalComments'],
            status: data['status'],
            rideID: data['rideID'],
          );
        }).toList();

        return reservations;
      } catch (e) {
        print("Error getting reservations: $e");
        return [];
      }
    }
  Future<void> updateReservationStatus(String reservationId, String newStatus) async {
    try {
      await _reservationCollection.doc(reservationId).update({'status': newStatus});
    } catch (e) {
      print("Error updating reservation status: $e");
      // Handle the error as needed
    }
  }

}







