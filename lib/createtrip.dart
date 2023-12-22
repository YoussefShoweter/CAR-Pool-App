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
  String tabTitle = ''; // Declare tabTitle variable

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final TextEditingController startPointController1 = TextEditingController();
  final TextEditingController destinationPointController1 = TextEditingController();
  final TextEditingController priceController1 = TextEditingController();
  final TextEditingController startPointController2 = TextEditingController();
  final TextEditingController destinationPointController2 = TextEditingController();
  final TextEditingController priceController2 = TextEditingController();
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


  void _addTrip(formkey,startPointController ,destinationPointController,priceController,direction) async {
    print("Came here");

    if (formkey.currentState?.validate() ?? false) {
      print("Came here");

      final String driverId = widget.userCredential.user?.uid ?? '';
      final String driverName = await FirestoreService().getUserName(driverId);
      final String startPoint = startPointController.text;
      final String destinationPoint = destinationPointController.text;
      final double price = double.parse(priceController.text);


      DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        17, // Default hour for 'From College'
        30, // Default minute for 'From College'
      );

      if (direction == 'to') {
        selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          7, // Default hour for 'To College'
          30, // Default minute for 'To College'
        );
      }


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

      Timestamp rideDateTime = Timestamp.fromDate(selectedDateTime);
      print("Came here");

      await FirestoreService().addTrip(newRide, rideDateTime);


      startPointController.clear();
      destinationPointController.clear();
      priceController.clear();

      widget.onTripAdded(); // Call the callback function
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: TabBar(
            tabs: [
              Tab(text: 'From College'),
              Tab(text: 'To College'),
            ],
            onTap: (index) {
              setState(() {
                // Set tabTitle based on the selected tab
                tabTitle = index == 0 ? 'From College' : 'To College';
              });
            },
          ),
        ),
        body: TabBarView(
          children: [
            _buildForm(),
            _buildForm2(),
          ],
        ),
      ),
    );
  }
  Widget _buildForm() {
    List<String> dropdownValues = ['Gate 3', 'Gate 4'];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: 'Gate 3',
                      decoration: InputDecoration(labelText: 'Start Point '),
                      items: dropdownValues.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        startPointController1.text = value!;
                      },
                    ),
                    TextFormField(
                      controller: destinationPointController1,
                      decoration: InputDecoration(labelText: 'Destination Point'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a destination point';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              TextFormField(
                controller: priceController1,
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
                    Text(
                      '5:30 PM',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _addTrip(_formKey,startPointController1,destinationPointController1,priceController1,"from");
                  widget.onTripAdded(); // Call the callback function
                },
                child: Text('Add Trip '),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildForm2() {
    List<String> dropdownValues = ['Gate 3', 'Gate 4'];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Column(
                  children: [
                    TextFormField(
                      controller: startPointController2,
                      decoration: InputDecoration(labelText: 'Start Point'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a start point';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: 'Gate 3',
                      decoration: InputDecoration(labelText: 'Destination Point'),
                      items: dropdownValues.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        destinationPointController2.text = value!;
                      },
                    ),

                  ],
                ),

              TextFormField(
                controller: priceController2,
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
                    Text(
                      '7:30 AM',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _addTrip(_formKey2,startPointController2,destinationPointController2,priceController2,"to");
                  widget.onTripAdded(); // Call the callback function
                },
                child: Text('Add Trip to'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
