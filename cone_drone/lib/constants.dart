import 'package:flutter/material.dart';

enum kScreenState { logIn, register, cone, pilot, record }
enum kState { initialized, loading, error }

String kFormatMilli(int milli) {
  return (milli / (60 * 1000) % 60).floor().toString().padLeft(2, '0') +
      ":" +
      (milli / 1000 % 60).floor().toString().padLeft(2, '0') +
      "." +
      ((milli % 1000) / 100).floor().toString();
}

const kTimerTextStyle = TextStyle(
  fontWeight: FontWeight.w900,
  fontSize: 50.0,
  fontFamily: 'Inconsolata',
);

const kTitleTextStyle = TextStyle(
  fontWeight: FontWeight.w900,
  fontSize: 45.0,
);

const kMenuTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 25.0,
  color: Colors.white70,
);

const kTextFieldStyle = TextStyle(color: Colors.white70);

const kTextErrorStyle = TextStyle(color: Colors.redAccent);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  hintStyle: TextStyle(color: Colors.white54),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
