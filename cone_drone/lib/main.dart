import 'package:flutter/material.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/screens/wrapper.dart';
import 'package:cone_drone/services/auth.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<MyUser>(
      create: (_) {
        return AuthService().user;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}
