import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/userProfile.dart';
import 'helpers/databaseHelper.dart';

class DriverProfilePage extends StatelessWidget {
  final UserCredential userCredential;

  DriverProfilePage({required this.userCredential});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: DatabaseHelper().getUserProfile(userCredential.user?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          final UserProfile userProfile = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text('Driver Profile'),
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
                    userProfile.fullName,
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
                    userProfile.email,
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
                    'Phone Number:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  Text(
                    userProfile.phoneNumber,
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
