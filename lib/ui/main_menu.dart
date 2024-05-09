import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/lobby_page.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final nameController = TextEditingController();
  late String playerID;

  createPlayer(newName) async {
    playerID = uuid.v4();
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
                onPressed: () async {
                  await createPlayer(nameController.text);
                  if (!context.mounted) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LobbyPage(
                              playerID: playerID,
                              playerName: nameController.text)));
                },
              ),
            ],
          ),
        ));
  }
}
