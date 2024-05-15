import 'dart:math';

import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/score_page.dart';
import 'package:drawair_proto1/ui/join_page.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class LobbyPage extends StatefulWidget {
  final String playerID;
  final String playerName;

  const LobbyPage(
      {super.key, required this.playerID, required this.playerName});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  late String roomID;
  late int roomCode;

  createGame() async {
    final String id = uuid.v4();
    roomID = id;
    roomCode = Random().nextInt(899999) + 100000;
    await supabase.from('room').insert({'id': id, 'code': roomCode});
    await supabase.from('game').insert({
      'roomID': id,
      'playerID': widget.playerID,
      'host': 'true',
      'playerName': widget.playerName
    });
    await supabase
        .from('current_prompt')
        .insert({'roomID': roomID, 'playerID': widget.playerID});
    supabase.channel(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(
                  top: 150.0, left: 100.0, right: 100.0, bottom: 50.0),
              child: Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        await createGame();
                        if (!context.mounted) return;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ScorePage(
                                    playerName: widget.playerName,
                                    playerID: widget.playerID,
                                    roomID: roomID,
                                    roomCode: roomCode)));
                      },
                      child: const Text('Create game')))),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Center(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JoinPage(
                                    playerID: widget.playerID,
                                    playerName: widget.playerName)));
                      },
                      child: const Text('Join game')))),
        ],
      ),
    );
  }
}
