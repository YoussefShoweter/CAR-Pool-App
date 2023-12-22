import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'helpers/usertype.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        backgroundColor: Colors.blue, // Set your desired app bar color
        elevation: 0, // Remove app bar shadow
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your logo here
            Image.asset(
              'assets/images/logo.png', // Replace with your actual logo path
              height: 200, // Adjust the height as needed
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<UserTypeProvider>(context, listen: false).setUserType('driver');
                Navigator.pushNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Set your desired button color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Login as Driver',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Provider.of<UserTypeProvider>(context, listen: false).setUserType('user');
                Navigator.pushNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Set your desired button color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Login as User',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
