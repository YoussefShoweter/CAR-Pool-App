import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/ride.dart';
class UserPage extends StatelessWidget {
  final UserCredential userCredential;

  UserPage({required this.userCredential});

  final List<Ride> availableRides = [
    Ride(
      date: '2023-01-01',
      driverId: 'driver123',
      driverName: 'John Doe',
      startPoint: 'Start Point 1',
      destinationPoint: 'Destination 1',
      price: 20.0,
    ),
    // Add more rides
  ];

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamed(context, '/welcome');
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
        actions: [
          // Logout Button
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Available Rides',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: availableRides.length,
              itemBuilder: (context, index) {
                final ride = availableRides[index];
                return ListTile(
                  title: Text('Date: ${ride.date}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Driver ID: ${ride.driverId}'),
                      Text('Driver: ${ride.driverName}'),
                      Text('From: ${ride.startPoint}'),
                      Text('To: ${ride.destinationPoint}'),
                      Text('Price: \$${ride.price.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Handle reservation logic here
                      print('Reserved ride: ${ride.driverName}');
                    },
                    child: Text('Reserve'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.logout),
      onPressed: () {
        Navigator.pushNamed(context, '/welcome');
      },
    );
  }
}
