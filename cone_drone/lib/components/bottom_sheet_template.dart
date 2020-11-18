import 'package:flutter/material.dart';

void bottomSheetTemplate({BuildContext context, Widget child}) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.blueGrey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: ListView(
          children: [
            child,
          ],
        ),
      );
    },
  );
}
