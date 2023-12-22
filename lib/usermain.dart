import 'dart:async';

import 'driverprofile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/ride.dart';
import 'models/reservation.dart';
import 'firestore_service.dart';
import 'reservationscreen.dart';
import 'package:date_format/date_format.dart';

class UserPage extends StatefulWidget {
  final UserCredential userCredential;

  UserPage({required this.userCredential});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Ride> availableRides = [];
  List<Reservation> userReservations = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startPeriodicFetching();
  }

  void _startPeriodicFetching() {
    // Use a timer to fetch data every 10 seconds
    Timer.periodic(Duration(seconds: 10), (Timer timer) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    try {
      await _fetchAvailableRides();
      await _fetchUserReservations();
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _fetchAvailableRides() async {
    List<Ride> rides = await FirestoreService().getAllRides();
    setState(() {
      availableRides = rides;
    });
  }

  Future<void> _fetchUserReservations() async {
    try {
      String userId = widget.userCredential.user?.uid ?? '';
      List<Reservation> reservations = await FirestoreService().getUserReservations(userId);

      setState(() {
        userReservations = reservations;
      });
    } catch (e) {
      print('Error fetching user reservations: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  bool _getAppropriate(DateTime rideDate,start) {
    DateTime currentTime = DateTime.now();
    int hoursDifference = rideDate.difference(currentTime).inHours;

    if(start =='Gate 3' || start=='Gate 4'){
      return hoursDifference >= 4.5;
    }
    else{
      return hoursDifference >= 9.5;

    }

  }

  Future<void> _reserveRide(BuildContext context, Ride ride) async {
    final bool reservationSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationScreen(ride: ride),
      ),
    );

    if (reservationSuccess == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Reservation successful!'),
      ));
      _fetchUserReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('User Page'),
          actions: [
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverProfilePage(userCredential: widget.userCredential),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Available Rides'),
              Tab(text: 'Reservations'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),

                  Text(
                    'Available Rides',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0), // Change the values based on your preference
                          blurRadius: 3.0,
                          color: Colors.grey, // Change the shadow color to your preference
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  Builder(
                    builder: (context) {
                      List<Ride> filteredRides = availableRides.where((element) => _getAppropriate(element.rideDateTime,element.startPoint)).toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredRides.length,
                        itemBuilder: (context, index) {
                          final ride = filteredRides[index];
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date: ${ride.rideDateTime.day} - ${ride.rideDateTime.month} - ${ride.rideDateTime.year}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Driver: ${ride.driverName}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'From: ${ride.startPoint}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'To: ${ride.destinationPoint}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Price: \$${ride.price.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _reserveRide(context, ride),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue, // Change the button color to your preference
                                ),
                                child: Text(
                                  'Reserve',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );

                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),

                  Text(
                    'Reservations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0), // Change the values based on your preference
                          blurRadius: 3.0,
                          color: Colors.grey, // Change the shadow color to your preference
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: userReservations.length,
                    itemBuilder: (context, index) {
                      final reservation = userReservations[index];
                      return FutureBuilder<Ride?>(
                        future: FirestoreService().getRideById(reservation.rideID),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data == null) {
                            return Text('Ride data not available');
                          }
                          final ride = snapshot.data!;

                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                'Date: ${ride.rideDateTime.day} - ${ride.rideDateTime.month} - ${ride.rideDateTime.year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Driver: ${ride.driverName}'),
                                  Text('From: ${ride.startPoint}'),
                                  Text('To: ${ride.destinationPoint}'),
                                  Text('Price: \$${ride.price.toStringAsFixed(2)}'),
                                ],
                              ),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: reservation.status == 'Pending' ? Colors.red : Colors.green,
                                ),
                                child: Text(
                                  'Status: ${reservation.status}',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );

                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
