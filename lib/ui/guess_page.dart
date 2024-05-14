import 'dart:async';

import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/score_page.dart';
import 'package:flutter/material.dart';

class GuessPage extends StatefulWidget {
  final String playerName;
  final String playerID;
  final String roomID;
  final int roomCode;

  const GuessPage(
      {super.key,
      required this.playerName,
      required this.playerID,
      required this.roomID,
      required this.roomCode});

  @override
  State<GuessPage> createState() => _GuessPageState();
}

class _GuessPageState extends State<GuessPage> {
  final _future =
      supabase.from('prompt').select('answer, chosen_prompt!inner(*)');

  final answerController = TextEditingController();

  handleTimeout() {
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
                        //Broadcast rigtigt svar
                        Timer(const Duration(seconds: 3), handleTimeout);
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
