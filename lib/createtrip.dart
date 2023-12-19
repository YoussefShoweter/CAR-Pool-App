import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'models/ride.dart';

class CreateTripForm extends StatefulWidget {
  final UserCredential userCredential;
  final VoidCallback onTripAdded;

  CreateTripForm({required this.userCredential, required this.onTripAdded});

  @override
  _CreateTripFormState createState() => _CreateTripFormState();
}

class _CreateTripFormState extends State<CreateTripForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController startPointController = TextEditingController();
  final TextEditingController destinationPointController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _addTrip() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String driverId = widget.userCredential.user?.uid ?? '';
      final String driverName = await FirestoreService().getUserName(driverId);
      final String startPoint = startPointController.text;
      final String destinationPoint = destinationPointController.text;
      final double price = double.parse(priceController.text);

      // Combine selected date and time into a DateTime object
      DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      Ride newRide = Ride(
        id: '',
        date: DateTime.now().toLocal().toString(),
        driverId: driverId,
        driverName: driverName,
        startPoint: startPoint,
        destinationPoint: destinationPoint,
        price: price,
        rideDateTime: selectedDateTime, // Use a single DateTime property
      );

      // Convert DateTime to Timestamp
      Timestamp rideDateTime = Timestamp.fromDate(selectedDateTime);

      // Add the new ride to Firestore with the combined DateTime
      await FirestoreService().addTrip(newRide, rideDateTime);

      startPointController.clear();
      destinationPointController.clear();
      priceController.clear();

      widget.onTripAdded(); // Call the callback function
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: startPointController,
              decoration: InputDecoration(labelText: 'Start Point'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a start point';
                }
                return null;
              },
            ),
            TextFormField(
              controller: destinationPointController,
              decoration: InputDecoration(labelText: 'Destination Point'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a destination point';
                }
                return null;
              },
            ),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Price'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Select Ride Date:'),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    '${selectedDate.toLocal()}'.split(' ')[0],
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('Select Ride Time:'),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text(
                    '${selectedTime.format(context)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addTrip();
                widget.onTripAdded(); // Call the callback function
              },
              child: Text('Add Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
