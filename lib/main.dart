import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_demo/screens/adminDashboard.dart';
import 'package:login_demo/screens/clientDashboard.dart';
import 'package:login_demo/screens/staffDashboard.dart';
import 'package:provider/provider.dart';

import 'provider/authProvider.dart';
import 'screens/loginScreen.dart';
import 'screens/registerScreen.dart';

void main() {
  runApp(LoginDemo());
}

class LoginDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Auth(),
      child: Consumer<Auth>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: "Authentication (Sign Up & Login)",
            home: auth.isAuth && auth.userType == "client"
                ? ClientDashboard()
                : auth.isAuth && auth.userType == "admin"
                    ? AdminDashboard()
                    : auth.isAuth && auth.userType == "staff"
                        ? StaffDashboard()
                        : FutureBuilder(
                            future: auth.autoLogin(),
                            builder: (ctx, snapShotData) =>
                                snapShotData.connectionState ==
                                        ConnectionState.waiting
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : LoginScreen(),
                          ),
            routes: {
              LoginScreen.routeName: (ctx) => LoginScreen(),
              RegisterScreen.routeName: (ctx) => RegisterScreen(),
            },
          );
        },
      ),
    );
  }
}
