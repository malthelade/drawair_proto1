import 'dart:math';

import 'package:drawair_proto1/main.dart';
import 'package:flutter/material.dart';

import 'draw_page.dart';

class LobbyPage extends StatefulWidget {
  final int id;

  const LobbyPage({super.key, required this.id});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  createGame(playerID) async {
    final int roomCode = Random().nextInt(899999) + 100000;
    await supabase.from('room').insert({'id': roomCode});
    await supabase.from('game').insert({
      'roomID': roomCode,
      'playerID': playerID,
      'role': 'host',
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
                      onPressed: () {
                        createGame(widget.id);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DrawPage()));
                      },
                      child: const Text('Create game')))),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Center(
                  child: ElevatedButton(
                      onPressed: null, child: Text('Join game')))),
        ],
      ),
    );
  }
}
