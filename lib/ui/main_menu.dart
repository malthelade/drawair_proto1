import 'dart:math';

import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/lobby_page.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final nameController = TextEditingController();
  late int playerID;

  createPlayer(newName) async {
    playerID = Random().nextInt(899999) + 100000;
    await supabase.from('player').insert({'id': playerID, 'name': newName});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('DrawAir'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(50),
                  child: TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter player name'),
                  )),
              ElevatedButton(
                child: const Text('Continue'),
                onPressed: () {
                  createPlayer(nameController.text);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LobbyPage(id: playerID)));
                },
              ),
            ],
          ),
        ));
  }
}
