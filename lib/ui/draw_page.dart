import 'dart:async';

import 'package:drawair_proto1/ui/score_page.dart';
import 'package:flutter/material.dart';

class DrawPage extends StatefulWidget {
  final String playerName;
  final String playerID;
  final String roomID;
  final int roomCode;

  const DrawPage(
      {super.key,
      required this.playerName,
      required this.playerID,
      required this.roomID,
      required this.roomCode});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  int remainingTime = 60;

  handleTimeout() {
    //Broadcast runde færdig
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScorePage(
                playerName: widget.playerName,
                playerID: widget.playerID,
                roomID: widget.roomID,
                roomCode: widget.roomCode)));
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 60), handleTimeout);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime -= 1;
    });
    return Scaffold(
      body: Center(
          child: Column(
        children: <Widget>[
          const Text('Time left:'),
          Text(remainingTime.toString())
        ],
      )),
    );
  }
}
