import 'dart:async';

import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/score_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GuessPage extends StatefulWidget {
  final String playerName;
  final String playerID;
  final String roomID;
  final int roomCode;
  final int playerCount;

  const GuessPage(
      {super.key,
      required this.playerName,
      required this.playerID,
      required this.roomID,
      required this.roomCode,
      required this.playerCount});

  @override
  State<GuessPage> createState() => _GuessPageState();
}

class _GuessPageState extends State<GuessPage> {
  final answerController = TextEditingController();
  late int playersLeft;
  late RealtimeChannel _channelRoom;

  @override
  void initState() {
    super.initState();
    playersLeft = widget.playerCount - 1;
    _channelRoom = supabase.channel(widget.roomID,
        opts: const RealtimeChannelConfig(self: true));
    _channelRoom
        .onBroadcast(
            event: 'answer_guessed',
            callback: (payload) => answerGuessedRecieved())
        .onBroadcast(event: 'round_over', callback: (payload) => toScoreboard())
        .subscribe();
  }

  answerGuessedRecieved() {
    playersLeft -= 1;
    if (playersLeft == 0) {
      _channelRoom.sendBroadcastMessage(
          event: 'all_guessed',
          payload: {'message': 'all players have guessed the drawing'});
    }
  }

  awardPoints() async {
    final currentPoints = await supabase
        .from('game')
        .select('points')
        .eq('playerID', widget.playerID);
    final int newPoints = currentPoints[0]['points'] + playersLeft;
    await supabase
        .from('game')
        .update({'points': newPoints}).match({'playerID': widget.playerID});
  }

  toScoreboard() {
    if (!mounted) return;
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
    final future = supabase
        .from('prompt')
        .select('answer, current_prompt!inner(*)')
        .eq('current_prompt.roomID', widget.roomID);
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
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
                  TextField(
                    controller: answerController,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (answerController.text.toLowerCase() ==
                          answer.toLowerCase()) {
                        showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                                title: Text('Rigtigt'),
                                content: Text('Du svarede rigtigt')));
                        await awardPoints();
                        await _channelRoom.sendBroadcastMessage(
                            event: 'answer_guessed',
                            payload: {
                              'message': 'a player guessed the answer'
                            });
                        Timer(const Duration(seconds: 2), toScoreboard);
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
