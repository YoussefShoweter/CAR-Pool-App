import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'helpers/usertype.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Provider.of<UserTypeProvider>(context, listen: false).setUserType('driver');
                Navigator.pushNamed(context, '/home');
              },
              child: Text('Login as Driver'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<UserTypeProvider>(context, listen: false).setUserType('user');
                Navigator.pushNamed(context, '/home');
              },
              child: Text('Login as User'),
            ),
          ],
        ),
      ),
    );
  }
}
