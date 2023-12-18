import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

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
}
