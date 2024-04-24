import 'dart:ffi';
import 'dart:ui';
import 'dart:math';

import 'package:drawair_proto1/supabase/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'DrawAir',
      home: MainMenu(),
    );
  }
}

class GuessPage extends StatefulWidget {
  const GuessPage({super.key});

  @override
  State<GuessPage> createState() => _GuessPageState();
}

class _GuessPageState extends State<GuessPage> {
  final _future = Supabase.instance.client
      .from('prompt')
      .select('answer, chosen_prompt!inner(*)');

  final answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final prompts = snapshot.data!;
          var answer = prompts[0]['answer'];
          return Padding(
            padding: const EdgeInsets.all(100.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(answer),
                  TextField(
                    controller: answerController,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (answerController.text.toLowerCase() ==
                          answer.toLowerCase()) {
                        showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                                title: Text('Rigtigt'),
                                content: Text('Du svarede rigtigt')));
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                                title: Text('Forkert'),
                                content: Text('Du svarede forkert')));
                      }
                    },
                    child: const Text('Svar'),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Gå tilbage')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

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

class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  final _future = supabase.from('prompt').select();

  pushPrompt(promptId) async {
    await supabase
        .from('chosen_prompt')
        .update({'prompt_id': promptId}).match({'id': '1'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final prompts = snapshot.data!;
          prompts.shuffle();
          final prompt = prompts.removeLast();
          pushPrompt(prompt['id']);
          return Padding(
            padding: const EdgeInsets.all(100.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(prompt['draw_prompt']),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Gå tilbage')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key, required this.id});

  final int id;

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  createGame(playerID) async {}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(
                  top: 150.0, left: 100.0, right: 100.0, bottom: 50.0),
              child: Center(
                  child: ElevatedButton(
                      onPressed: null, child: Text('Create game')))),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Center(
                  child: ElevatedButton(
                      onPressed: null, child: Text('Join game')))),
        ],
      ),
    );
  }
}
