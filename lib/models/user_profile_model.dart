import 'package:flutter/cupertino.dart';

class UserProfileModel extends ChangeNotifier {
  String fname;
  String lname;
  String name;
  String username;

  void setFirstName(String fname) {
    this.fname = fname;
    notifyListeners();
  }

  void setLastName(String lname) {
    this.lname = lname;
    notifyListeners();
  }

  void setName(String name) {
    this.name = name;
    notifyListeners();
  }

  void setUsername(String username) {
    this.username = username;
    notifyListeners();
  }
}
