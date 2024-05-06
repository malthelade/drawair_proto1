import 'package:drawair_proto1/main.dart';
import 'package:flutter/material.dart';

class ScoreboardPage extends StatefulWidget {
  final String roomID;
  final int roomCode;

  const ScoreboardPage(
      {super.key, required this.roomID, required this.roomCode});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  @override
  Widget build(BuildContext context) {
    final future = supabase
        .from('game')
        .select('playerID, points, player!inner(*)')
        .eq('roomID', widget.roomID);

    return Scaffold(
        body: FutureBuilder<List<Map<String, dynamic>>>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final game = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: ListView(
                    padding: const EdgeInsets.all(40.0),
                    children: [
                      ListTile(
                        title: Text('Code: ${widget.roomCode}'),
                      ),
                      for (var player in game)
                        ListTile(
                          title: Text(
                              '${player['player']['name']}: ${player['points']}'),
                          tileColor: Colors.amber,
                        ),
                    ],
                  ),
                ),
              );
            }));
  }
}
