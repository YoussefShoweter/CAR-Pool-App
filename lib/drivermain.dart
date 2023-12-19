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
                        return ListTile(
                          title: Text('User ID: ${reservation.userId}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Trip ID: ${reservation.rideID}'),
                              Text('Status: ${reservation.status}'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _approveRequest(reservation);
                            },
                            child: Text('Approve'),
                          ),
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
        return ListTile(
          title: Text('Date: ${ride.date}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: ${ride.startPoint}'),
              Text('To: ${ride.destinationPoint}'),
              Text('Price: \$${ride.price.toStringAsFixed(2)}'),
            ],
          ),
        );
      },
    );
  }
}
