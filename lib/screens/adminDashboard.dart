import 'package:flutter/material.dart';
import 'package:login_demo/provider/authProvider.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Admin Dashboard"),
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
