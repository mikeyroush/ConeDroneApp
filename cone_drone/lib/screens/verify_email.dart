import 'package:flutter/material.dart';
import 'package:cone_drone/components/rounded_button.dart';
import 'package:cone_drone/services/auth.dart';
import 'package:cone_drone/constants.dart';

class Verify extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Check your email for a verification link.',
                style: kTitleTextStyle.copyWith(color: Colors.white70),
              ),
              SizedBox(height: 8.0),
              RoundedButton(
                title: 'Resend Email',
                backgroundColor: Colors.lightBlueAccent,
                onPress: () {
                  _auth.sendVerificationEmail();
                  _auth.signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
