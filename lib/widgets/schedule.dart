import 'package:flutter/material.dart';

class Schedule extends StatelessWidget {
  const Schedule({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      "Schedule",
      style: TextStyle(color: Colors.white, fontSize: 25),
    ));
  }
}