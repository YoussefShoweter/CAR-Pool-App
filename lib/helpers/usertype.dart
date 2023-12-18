import 'package:flutter/material.dart';

class UserTypeProvider with ChangeNotifier {
  String _userType = ''; // Default user type is an empty string

  // Getter for user type
  String getUserType() {
    return _userType;
  }

  // Setter for user type
  void setUserType(String userType) {
    _userType = userType;
    notifyListeners(); // Notify listeners about the change
  }
}
