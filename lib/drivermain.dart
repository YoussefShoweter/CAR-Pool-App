import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'driverprofile.dart';
import 'createtrip.dart';
import 'models/reservation.dart';
import 'models/ride.dart';

class DriverPage extends StatefulWidget {
  final UserCredential userCredential;

  DriverPage({required this.userCredential});

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Ride> _historyRides;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _historyRides = [];

    _loadHistoryRides();
  }

  Future<void> _loadHistoryRides() async {
    List<Ride> rides = await FirestoreService().getRidesByDriverId();
    setState(() {
      _historyRides = rides;
    });
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  void _approveRequest(Reservation reservation) async {
    try {
      // Update reservation status to 'approved'
      await FirestoreService().updateReservationStatus(reservation.id, 'approved');

      // Reload the requests to make the approved reservation disappear
      await _loadHistoryRides();
    } catch (e) {
      print("Error approving request: $e");
      // Handle the error as needed
    }
  }

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
      ),
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'History'),
                Tab(text: 'Requests'),
                Tab(text: 'Create Trip'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // History Tab
              RefreshIndicator(
                onRefresh: () async {
                  await _loadHistoryRides();
                },
                child: _buildHistoryTab(),
              ),

              // Requests Tab
              FutureBuilder<List<Reservation>>(
                future: FirestoreService().getReservationsByDriverIdAndStatus(widget.userCredential.user!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No pending requests.'));
                  } else {
                    List<Reservation> reservations = snapshot.data!;
                    return ListView.builder(
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];

                        return FutureBuilder<Ride?>(
                          future: FirestoreService().getRideById(reservation.rideID),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.data == null) {
                              return Text('Error: Ride details not found');
                            } else {
                              Ride rideDetails = snapshot.data!;

                              return Card(
                                elevation: 3,
                                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  title: FutureBuilder<Map<String, dynamic>>(
                                    // Assuming getDriverProfile returns a Future<Map<String, dynamic>> for the driver's profile
                                    future: FirestoreService().getProfile(reservation.userId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Text('User Name: Loading...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
                                      } else if (snapshot.hasError) {
                                        return Text('User Name: Error: ${snapshot.error}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
                                      } else {
                                        String username = snapshot.data?['fullName'] ?? 'Unknown User';
                                        return Text(
                                          'User Name: $username',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        );
                                      }
                                    },
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 12),
                                      Text('Payment Method: ${reservation.paymentMethod}', style: TextStyle(fontSize: 16)),
                                      Text('Ride Details: ${rideDetails.startPoint} to ${rideDetails.destinationPoint}', style: TextStyle(fontSize: 16)),
                                      Text(
                                        'Status: ${reservation.status}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: reservation.status.toLowerCase() == 'pending' ? FontWeight.bold : FontWeight.normal,
                                          color: reservation.status.toLowerCase() == 'pending' ? Colors.red : Colors.green,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text('User Comments: ${reservation.additionalComments}', style: TextStyle(fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      _approveRequest(reservation);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                    ),
                                    child: Text(
                                      'Approve',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );





                  }
                },
              ),

              // Create Trip Tab
              CreateTripForm(
                userCredential: widget.userCredential,
                onTripAdded: () async {
                  await _loadHistoryRides();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_historyRides.isEmpty) {
      return Center(child: Text('No history data available.'));
    }

    return ListView.builder(
      itemCount: _historyRides.length,
      itemBuilder: (context, index) {
        final ride = _historyRides[index];
        return Card(
          elevation: 2, // Add some elevation for a card-like appearance
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              'Date: ${ride.rideDateTime}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8), // Add some spacing between title and subtitle
                Text('From: ${ride.startPoint}'),
                Text('To: ${ride.destinationPoint}'),
                SizedBox(height: 8), // Add some spacing between subtitle items
                Text(
                  'Price: \$${ride.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green, // Customize text color for price
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

  }
}
