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
    _fetchAvailableRides();
    _fetchUserReservations();
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
  bool _getAppropriate(DateTime rideDate) {
    // Get the current time
    DateTime currentTime = DateTime.now();

    // Calculate the difference in hours
    int hoursDifference = rideDate.difference(currentTime).inHours;

    // Check if the difference is at least 6 hours
    return hoursDifference >= 6;
  }


  Future<void> _reserveRide(BuildContext context, Ride ride) async {
    // Navigate to the reservation screen
    final bool reservationSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationScreen(ride: ride),
      ),
    );

    if (reservationSuccess == true) {
      // Handle logic after successful reservation, e.g., show a confirmation message.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Reservation successful!'),
      ));
      // Refresh reservations after a successful reservation
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
            // Logout Button
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
                  Text(
                    'Available Rides',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Builder(
                    builder: (context) {
                      List<Ride> filteredRides=availableRides.where((element) => _getAppropriate(element.rideDateTime)).toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredRides.length,
                        itemBuilder: (context, index) {
                          final ride = filteredRides[index];
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
                              onPressed: () => _reserveRide(context, ride),
                              child: Text('Reserve'),
                            ),
                          );
                        },
                      );
                    }
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Reservations',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                            child: ListTile(
                              title: Text('Date and Time: ${ride.rideDateTime}'), // Use DateFormat to format DateTime
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Driver ID: ${reservation.driverId}'),
                                  Text('Driver: ${ride.driverName}'),
                                  Text('From: ${ride.startPoint}'),
                                  Text('To: ${ride.destinationPoint}'),
                                  Text('Price: \$${ride.price.toStringAsFixed(2)}'),
                                ],
                              ),
                              trailing: Text('Status: ${reservation.status}'),
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
