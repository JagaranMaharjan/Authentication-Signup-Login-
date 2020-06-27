import 'package:flutter/material.dart';
import 'package:login_demo/provider/authProvider.dart';
import 'package:provider/provider.dart';

class StaffDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Staff Dashboard"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Staff Dashboard"),
            RaisedButton.icon(
              onPressed: () {
                Provider.of<Auth>(context, listen: false).logout();
              },
              icon: Icon(Icons.remove_from_queue),
              label: Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}
