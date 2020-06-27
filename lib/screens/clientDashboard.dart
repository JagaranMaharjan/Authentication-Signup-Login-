import 'package:flutter/material.dart';
import 'package:login_demo/provider/authProvider.dart';
import 'package:provider/provider.dart';

class ClientDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Client Dashboard"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Client Dashboard"),
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
