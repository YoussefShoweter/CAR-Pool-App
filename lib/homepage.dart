import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';  // Import Provider
import 'helpers/usertype.dart';  // Import UserTypeProvider
import 'drivermain.dart';
import 'usermain.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login(BuildContext context) async {
    try {
      String email = emailController.text;
      String password = passwordController.text;

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Retrieve user type using UserTypeProvider
        String userType = Provider.of<UserTypeProvider>(context, listen: false).getUserType();

        if (userType == 'driver') {
          // Navigate to the DriverPage for driver users and pass the userCredential
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriverPage(userCredential: userCredential),
            ),
          );
        } else {
          // Navigate to the UserPage for regular users and pass the userCredential
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserPage(userCredential: userCredential),
            ),
          );
        }
      } else {
        // Authentication failed
        print("Authentication failed");
      }
    } catch (e) {
      // Handle login errors here
      print("Error: $e");
      print("Unsuccessful");
    }
  }



  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 0.1 * screenHeight),
            Text(
              'ASU To-Do List App',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: Colors.blueGrey,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 0.05 * screenHeight),
            Image.asset(
              'assets/images/logo.png',
              height: 150,
            ),
            Container(
              width: 300,
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 300,
              child: TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: _obscurePassword,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                fixedSize: MaterialStateProperty.all(Size(200, 30)),
                textStyle: MaterialStateProperty.all(TextStyle(
                  fontSize: 18,
                )),
              ),
              child: Text('Login'),
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text('Signup'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
