import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cone_drone/services/auth.dart';
import 'package:cone_drone/services/database.dart';
import 'package:cone_drone/screens/pilots/pilot_list.dart';
import 'package:cone_drone/screens/pilots/add_pilot.dart';
import 'package:cone_drone/models/pilot.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/components/bottom_sheet_template.dart';
import 'package:cone_drone/constants.dart';

class PilotScreen extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);

    return StreamProvider<List<Pilot>>.value(
      value: DatabaseService(instructorID: user.uid).pilots,
      catchError: (_, __) => null,
      child: Expanded(
          child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: PilotList(),
            ),
            FloatingActionButton(
              child: Text('+'),
              onPressed: () => bottomSheetTemplate(
                context: context,
                child: AddPilotForm(),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
