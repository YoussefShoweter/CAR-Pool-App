import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class DriverProfilePage extends StatelessWidget {
  final UserCredential userCredential;

  DriverProfilePage({required this.userCredential});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: FirestoreService().getDriverProfile(userCredential.user?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          final Map<String, dynamic> driverData = snapshot.data ?? {};
          final String fullName = driverData['fullName'] ?? 'N/A';
          final String email = driverData['email'] ?? 'N/A';
          final String id = userCredential.user?.uid ?? 'N/A';
          final String phoneNumber = driverData['mobile'] ?? 'N/A';

          return Scaffold(
            appBar: AppBar(
              title: Text('My Profile'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue, // You can change the color based on your design
                    ),
                    child: Icon(
                      Icons.person,
                      size: 80.0,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Full Name:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  Text(
                    fullName,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Email:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'ID:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  Text(
                    id,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Phone Number:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  Text(
                    phoneNumber,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
