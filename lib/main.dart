import 'dart:ffi';
import 'dart:ui';
import 'dart:math';

import 'package:drawair_proto1/supabase/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _future = Supabase.instance.client.from('prompt').select();

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
          prompts.shuffle();
          final prompt = prompts.removeLast();
          return Padding(
            padding: const EdgeInsets.all(100.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(prompt['answer']),
                  TextField(
                    controller: answerController,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (answerController.text.toLowerCase() ==
                          prompt['answer'].toLowerCase()) {
                        print('rigtigt');
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('DrawAir'),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text('Gæt'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const GuessPage()));
            },
          ),
        ));
  }
}
