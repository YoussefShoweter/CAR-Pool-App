import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/ride.dart';
import 'firestore_service.dart';
import 'models/reservation.dart';

class ReservationScreen extends StatefulWidget {
  final Ride ride;

  ReservationScreen({required this.ride});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  String paymentMethod = '';
  late TextEditingController reviewController;

  @override
  void initState() {
    super.initState();
    reviewController = TextEditingController();
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Trip Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Date: ${widget.ride.date}'),
              Text('Driver ID: ${widget.ride.driverId}'),
              Text('Driver: ${widget.ride.driverName}'),
              Text('From: ${widget.ride.startPoint}'),
              Text('To: ${widget.ride.destinationPoint}'),
              Text('Price: \$${widget.ride.price.toStringAsFixed(2)}'),
              SizedBox(height: 20),
              Text('Choose Payment Method', style: TextStyle(fontSize: 18)),
              Row(
                children: [
                  Radio(
                    value: 'Cash',
                    groupValue: paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value as String;
                      });
                    },
                  ),
                  Text('Cash'),
                  SizedBox(width: 20),
                  Radio(
                    value: 'Visa',
                    groupValue: paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value as String;
                      });
                    },
                  ),
                  Text('Visa'),
                ],
              ),
              SizedBox(height: 20),
              Text('Review the Trip', style: TextStyle(fontSize: 18)),
              TextFormField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Any comments to the rider'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _sendReservationRequest(context, widget.ride.driverId,widget.ride.id);
                },
                child: Text('Send Reservation Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendReservationRequest(BuildContext context, String driverId ,String rideID) async {
    try {
      // Get the current user ID (assuming you have a user ID stored in FirebaseAuth)
      String userId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Replace with the actual way you get the user ID
      String paymentMethod = this.paymentMethod;
      String additionalComments = reviewController.text;

      // Create a Reservation object
      Reservation newReservation = Reservation(
        id: '', // Leave empty for Firestore to generate a unique ID
        userId: userId,
        driverId: driverId,
        paymentMethod: paymentMethod,
        additionalComments: additionalComments,
        status: 'Pending',
        rideID:rideID,
      );

      // Add the reservation to the database
      await FirestoreService().addReservation(newReservation);

      // Return to the UserPage and indicate that the reservation was successful
      Navigator.pop(context, true);
    } catch (e) {
      print('Error sending reservation request: $e');
      // Handle error as needed
    }
  }
}