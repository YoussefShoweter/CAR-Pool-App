import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'helpers/usertype.dart'; // Import UserTypeProvider

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _signup(BuildContext context) async {
    try {
      String email = emailController.text;
      String password = passwordController.text;
      String confirmPassword = confirmPasswordController.text;
      String mobile = mobileController.text;
      String fullName = fullNameController.text;

      // Validate email format
      if (!email.endsWith('@eng.asu.edu.eg')) {
        _showAlert(context, 'Invalid Email Format', 'Email should end with @eng.asu.edu.eg');
        return;
      }

      // Validate phone number length
      if (mobile.length != 11) {
        _showAlert(context, 'Invalid Phone Number', 'Phone number should be 11 digits');
        return;
      }

      // Validate name is not empty
      if (fullName.isEmpty) {
        _showAlert(context, 'Empty Name', 'Please enter your full name');
        return;
      }

      // Validate password is not empty
      if (password.isEmpty) {
        _showAlert(context, 'Empty Password', 'Please enter a password');
        return;
      }

      if (password == confirmPassword) {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Set user type in Firestore based on userType from UserTypeProvider
        String userType = Provider.of<UserTypeProvider>(context, listen: false).getUserType();
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
          'email': email,
          'mobile': mobile,
          'fullName': fullName,
          'userType': userType,
        });

        Navigator.pushNamed(context, '/home');
      } else {
        _showAlert(context, 'Passwords Do Not Match', "Passwords don't match");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _showAlert(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
              'SignUp',
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
            SizedBox(height: 10),
            Container(
              width: 300,
              child: TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _toggleConfirmPasswordVisibility,
                  ),
                ),
                obscureText: _obscureConfirmPassword,
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 300,
              child: TextField(
                controller: mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile',
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 300,
              child: TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signup(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                fixedSize: MaterialStateProperty.all(Size(200, 30)),
                textStyle: MaterialStateProperty.all(TextStyle(
                  fontSize: 18,
                )),
              ),
              child: Text('Signup'),
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account ?",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
