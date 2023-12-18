import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
class DriverPage extends StatelessWidget {
  final UserCredential userCredential;

  DriverPage({required this.userCredential});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverProfilePage(userCredential: userCredential),
                ),
              );
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: 'History'),
                Tab(text: 'Requests'),
                Tab(text: 'Create Trip'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // History Tab (You can replace this with actual data)
              Center(child: Text('Driver History Data')),

              // Requests Tab
              Center(child: Text('Driver Requests Data')),

              // Create Trip Tab
              Center(child: Text('Create Trip')),
            ],
          ),
        ),
      ),
    );
  }
}


class DriverProfilePage extends StatelessWidget {
  final UserCredential userCredential;

  DriverProfilePage({required this.userCredential});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: FirestoreService().getDriverProfile(userCredential.user?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // You can replace this with a loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final Map<String, dynamic> driverData = snapshot.data ?? {};
          final String fullName = driverData['fullName'] ?? 'N/A';
          final String email = driverData['email'] ?? 'N/A';
          final String id = driverData['id'] ?? 'N/A';
          final String phoneNumber = driverData['phoneNumber'] ?? 'N/A';

          return Scaffold(
            appBar: AppBar(
              title: Text('Driver Profile'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Name: $fullName'),
                  Text('Email: $email'),
                  Text('ID: $id'),
                  Text('Phone Number: $phoneNumber'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

