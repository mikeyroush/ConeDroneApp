import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade500,
      child: Center(
        child: SpinKitFoldingCube(
          color: Colors.white70,
          size: 50.0,
        ),
      ),
    );
  }
}
