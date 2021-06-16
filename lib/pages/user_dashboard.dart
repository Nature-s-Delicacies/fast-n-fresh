import 'dart:math';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:natures_delicacies/models/page_model.dart';
import 'package:natures_delicacies/models/user_profile_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String name;
  String fname;
  String lname;
  String username;
  Random random = new Random();

  SharedPreferences prefs;

  void setupDetails() async {
    prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name');
    Provider.of<UserProfileModel>(context, listen: false).setName(name);
    fname = name.substring(0, name.indexOf(' '));
    Provider.of<UserProfileModel>(context, listen: false).setFirstName(fname);
    lname = name.substring(name.indexOf(' '), name.length);
    Provider.of<UserProfileModel>(context, listen: false).setLastName(lname);
    username = prefs.getString('username');
    Provider.of<UserProfileModel>(context, listen: false).setUsername(username);
  }

  @override
  void initState() {
    super.initState();
    setupDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      bottomNavigationBar: CurvedNavigationBar(
        items: tabs,
        backgroundColor: Theme.of(context).colorScheme.background,
        color: Theme.of(context).colorScheme.secondary,
        animationCurve: Curves.easeInOut,
        index: Provider.of<PageModel>(context, listen: true).currentIndex,
        onTap: (val) {
          Provider.of<PageModel>(context, listen: false).setCurrentPage(val);
        },
        height: 75,
        animationDuration: Duration(milliseconds: 500),
      ),
      body: Consumer<PageModel>(
        builder: (context, model, _) {
          return model.currentPage(model.currentIndex);
        },
      ),
    );
  }
}

List<Widget> tabs = [
  Icon(
    Icons.home,
    color: Colors.grey[200],
  ),
  Icon(
    Icons.shopping_bag,
    color: Colors.grey[200],
  ),
  Icon(
    Icons.shopping_cart,
    color: Colors.grey[200],
  ),
  Icon(
    Icons.person,
    color: Colors.grey[200],
  ),
];
