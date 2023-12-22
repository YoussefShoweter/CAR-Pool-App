import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'drivermain.dart';
import 'models/userProfile.dart';
import 'usermain.dart';
import 'package:provider/provider.dart';
import 'helpers/usertype.dart';
import 'helpers/databaseHelper.dart';

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
        String userTypeFromProvider = Provider.of<UserTypeProvider>(context, listen: false).getUserType();
        String userTypeFromFirestore = await FirestoreService().getUserTypeById(userCredential.user!.uid);
        Map<String, dynamic> profileData = await FirestoreService().getProfile(userCredential.user!.uid);

        await DatabaseHelper().insertUserProfile(
          UserProfile(
            id: userCredential.user!.uid,
            fullName: profileData['fullName'],
            email: profileData['email'],
            phoneNumber: profileData['mobile'],
            userType: profileData['userType'],
          ),
        );

        if (userTypeFromProvider == userTypeFromFirestore) {
          if (userTypeFromProvider == 'driver') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverPage(userCredential: userCredential),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserPage(userCredential: userCredential),
              ),
            );
          }
        } else {
          // User types do not match, show alert
          _showAlert(context, "Error", "User types do not match");
        }
      } else {
        // Authentication failed, show alert
        _showAlert(context, "Error", "Invalid credentials");
      }
    } catch (e) {
      // Handle login errors here, show alert
      _showAlert(context, "Error", "Invalid Login ");
    }
  }

  // Function to show alerts
  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('ASU CarPool App'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 0.1 * screenHeight),
            Text(
              'ASU Car-Pool App',
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
