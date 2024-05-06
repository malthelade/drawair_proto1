import 'dart:math';

import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/scoreboard_page.dart';
import 'package:drawair_proto1/ui/join_page.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class LobbyPage extends StatefulWidget {
  final String playerID;

  const LobbyPage({super.key, required this.playerID});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  late String roomID;
  late int roomCode;

  createGame(playerID) async {
    final String id = uuid.v4();
    roomID = id;
    roomCode = Random().nextInt(899999) + 100000;
    await supabase.from('room').insert({'id': id, 'code': roomCode});
    await supabase.from('game').insert({
      'roomID': id,
      'playerID': playerID,
      'host': 'true',
      'drawing': 'true'
    });
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
                        await createGame(widget.playerID);
                        Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                                builder: (context) => ScoreboardPage(
                                    roomID: roomID, roomCode: roomCode)));
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
                                builder: (context) =>
                                    JoinPage(playerID: widget.playerID)));
                      },
                      child: Text('Join game')))),
        ],
      ),
    );
  }
}
