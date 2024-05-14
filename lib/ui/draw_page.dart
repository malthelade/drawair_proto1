import 'dart:async';

import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/score_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DrawPage extends StatefulWidget {
  final String playerName;
  final String playerID;
  final String roomID;
  final int roomCode;
  final int playerCount;

  const DrawPage(
      {super.key,
      required this.playerName,
      required this.playerID,
      required this.roomID,
      required this.roomCode,
      required this.playerCount});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  int remainingTime = 60;
  late RealtimeChannel _channelRoom;
  late final Timer _roundTime;

  @override
  void initState() {
    super.initState();
    _channelRoom = supabase.channel(widget.roomID);
    _channelRoom
        .onBroadcast(
            event: 'answer_guessed',
            callback: (payload) => answerGuessedRecieved())
        .onBroadcast(event: 'all_guessed', callback: (payload) => roundOver())
        .subscribe();
    _roundTime = Timer(const Duration(seconds: 60), handleTimeout);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime -= 1;
      setState(() {});
    });
  }

  answerGuessedRecieved() async {
    final currentPoints = await supabase
        .from('game')
        .select('points')
        .eq('playerID', widget.playerID);
    final int newPoints = currentPoints[0]['points'] + 1;
    await supabase
        .from('game')
        .update({'points': newPoints}).match({'playerID': widget.playerID});
  }

  roundOver() {
    _roundTime.cancel();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScorePage(
                playerName: widget.playerName,
                playerID: widget.playerID,
                roomID: widget.roomID,
                roomCode: widget.roomCode)));
  }

  handleTimeout() {
    _channelRoom.sendBroadcastMessage(
        event: 'round_over', payload: {'message': 'Time ran out'});
    roundOver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 100.0),
            child: Text('Time left:'),
          ),
          Text(remainingTime.toString())
        ],
      )),
    );
  }
}
